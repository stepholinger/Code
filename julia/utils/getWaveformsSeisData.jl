using SeisIO
using Distributed
using Dates
using Glob
using DelimitedFiles
using JLD2
include("filterData.jl")

function getWaves(dir::String,stas::Array{String},chans::Array{String},filterType::String="none",freq::Array{Float64,1}=1,corners::Int=4)

    #read in list of detections
    detections = readdlm("/home/setholinger/Documents/Projects/PIG/detections/run2/stalta/detections.txt")

    #set path
    #path = "/media/setholinger/Data/Data/PIG/SAC/noIR/"

    #set staion and components
    #sta = ["PIG1","PIG2","PIG3","PIG4","PIG5"]
    #chan = ["HHZ","HHN","HHE"]

    #choose filter band and type for output waveforms
    #freq = [4.,10.]
    #filterType = "Bandpass"

    numTrace = length(stas)*length(chans)
    numDetections = length(detections)
    numChans = length(chans)
    numStas = length(stas)

    #restructure and make a couple useful variables
    channels = []
    for n = 1:numStas
        append!(channels,chans)
    end
    chans = permutedims(channels)

    stations = stas
    for n = 1:numChans-1
        stations = hcat(stations,stas)
    end
    stas = reshape(permutedims(stations),numTrace,1)

    #set range of dates
    startDate = Date(2012,01,11)
    endDate = Date(2012,01,12)
    dateRange = startDate:Day(1):endDate

    #set samplerate and desired snippet length
    snippetLength = 8
    bufferLength = 2

    #open JLD2 file for saving
    outFile = jldopen("waveforms.jld2","a+")

    for d = 1:length(dateRange)-1

        #find all detections on the current day
    	detectionsToday = []
    	for t in detections
    		if Dates.unix2datetime(t) > dateRange[d] && Dates.unix2datetime(t) < dateRange[d+1]
    			detectionsToday = vcat(detectionsToday,Dates.unix2datetime(t))
    		end
    	end
        print(length(detectionsToday))

        #make empty seisData object
        data = SeisData()

        #fill with trace for each station and component
    	for f = 1:numTrace
        	fname = dir * stas[f] * "/" * chans[f] * "/" * string(dateRange[d]) * "." * stas[f] * "." * chans[f] * ".noIR.SAC"
            ch = SeisIO.read_data("sac", fname)

            #only push into SeisData if not empty
            if isempty(ch) == false
                append!(data,ch)
            end
        end

        #filter to desired band
		data = filterData(data,filterType,freq,corners)

		#extract and save each event
		for n = 1:length(detectionsToday)
            #copy and trim data
            snippet = deepcopy(data)
            startTime = detectionsToday[n] - Dates.Second(bufferLength)
            endTime = detectionsToday[n] + Dates.Second(snippetLength)
            sync!(snippet,s = startTime,t = endTime)

            #save into jld2 structure
            outName = string(dateRange[d]) * "_" * string(n)
            write(outFile,outName,snippet)

        end

        #give some output so we know the code is working
        print("Successfully returned waveforms from detections on " * string(dateRange[d]) * ".\n")
    end

end
