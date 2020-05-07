using SeisIO
using Distributed
using Dates
using Glob
using DelimitedFiles

include("getTriggersKurtosis.jl")
include("filterData.jl")
include("trig2detection.jl")
include("util.jl")

#CHANGE INPUTS TO KURTOSIS
function kurtosisDetect(dir::String,stas::Array{String},chans::Array{String},fs::Int=100,timeWinLength::Float64=60.,sparseWinLength::Float64=5.,
    threshold::Float64=3.,filterType::String="none",freq::Array{Float64,1}=1,corners::Int=4,dates::Array{String}=[""])

    #define useful variables
    numChan = length(chans)
    numSta = length(stas)
    numSamples = Dates.value(Second(Day(1)))*fs

    #define function with only one input that will be called by pmap
    function readAndGetTriggers(filename::String)

        #create seisData from filename
        data = SeisIO.read_data("sac",filename)

        #if data exists, filter and get triggers
        if isempty(data) == false

            #filter data to specified band
            filtData = filterData(data,filterType,freq,corners)

            #extract raw timeseries
            trace = filtData[1].x

            #if file is shorter than one day, pad with zeros to 8640000 samples
            if length(trace) < numSamples
                pad = numSamples-length(trace)
                trace = vcat(trace,zeros(Float32,pad))
            end

            #if file is longer than one day, trim to 8640000 samples
            if length(trace) > numSamples
                trim = length(trace)-numSamples
                trace = trace[1:end-trim]
            end

	    #CHANGE INPUTS TO KURTOSIS
            #get staLta triggers
            triggers = getTriggersKurtosis(trace,fs,timeWinLength,sparseWinLength,threshold)

        #if no data, make empty trigger vector
        else
            triggers = zeros(numSamples)
        end

        #println("Detector triggered ", sum(triggers)," times")

        return triggers
    end

    #get range of dates to iterate through by checking filenames
    dayRange = getDateRange(stas,chans,dir)

    #override above if date vector is provided manually
    if dates[1] != ""
	dayRange = map(Date,dates)
    end
    
    #define arrays to store file names for each day and binary detection vectors
    trigArray = []
    allDetections = []

    #loop over days
    for d in dayRange

        files = getFilenames(d,stas,chans,dir)

        #println("Finding events on "*Dates.format(d,"yyyy-mm-dd")*"...")

        trigArray = pmap(readAndGetTriggers,files)
        trigArray = reshape(trigArray,numChan,numSta)'

        #call trig2detection to consolidate raw triggers into events
        detections,quality = trig2detection(trigArray,numSta,numChan,numSamples,500,2,2)

        #convert to unix time
        unixDetections = convertToUnixTime(detections,fs,d)

        #open file for writing detections
        open("detections.txt","a") do x
            writedlm(x,unixDetections)
        end

        #open file for writing 
        open("detectionQuality.txt","a") do x
            writedlm(x,quality)
        end
	
	println("Found "*string(length(detections))*" events on "*Dates.format(d,"yyyy-mm-dd")*".")

        append!(allDetections,unixDetections)
    end

    return allDetections

#return
	#check which stations and channels are available for that day
	#for each station, combine channels into one SeisData object

	#pmap with filter and each channel of each SeisData object
	#pmap with getTrigger() and each channel of each SeisData object


	#call trig2detection to consolidate raw triggers into event detection (criteria should be variables eventually but do 2 components, 3 stations to start)

	#output waveform snippet using the sample number from the binary vector- choose how long each snippet should be before and after sample (maybe call another code to do so)
	#convert binary detections into unix time using seisData.t[1][1,2]

	#save new snippet and detection times in unix format into jld2 structure



end






#    trigArray = fill(Float64[],size(chans)[1],size(stas)[1])
#    trigVect = Float64[]
#
#    for s = 1:size(stas)[1]
#        for c = 1:size(chans)[1]
#            files = readdir(dir*stas[s]*"/"*chans[c]*"/")
#            for f in files
#                data = SeisIO.read_data("sac",dir*stas[s]*"/"*chans[c]*"/"*f)
#		filtData = filterData(data,filterType,freq,corners)
#                trigs = getTriggers(filtData,longWinLength,shortWinLength,threshold,overlap)
#		trigVect = vcat(trigVect,trigs)
#            end
#        trigArray[c,s] = trigVect
#        end
#    end
#    return trigArray
#end
