using SeisIO
using Distributed
using Dates
using DelimitedFiles
using HDF5
include("../filterData.jl")

function getTrainingData(detections::String,dir::String,stas::Array{String},chans::Array{String},
    startDate::String,endDate::String,filterType::String="none",freq::Array{Float64,1}=1,
    corners::Int=4,bufferLength::Int=2,snippetLength::Int=8,outName::String="waveforms.h5")

    # read in list of detections
    detections = readdlm(detections)

    # determine frequency of downsampled data
    #sampFreq = freq[2] * 2
    sampFreq = 100
    
    numTrace = length(stas)*length(chans)
    numDetections = length(detections)
    numChans = length(chans)
    numStas = length(stas)

    # restructure and make a couple useful variables
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

    # set range of dates
    startDate = Date(startDate)
    endDate = Date(endDate)
    dateRange = startDate:Day(1):endDate

    # set ssnippet lengths to samples
    snippetLength = Int(snippetLength * sampFreq)
    bufferLength = Int(bufferLength * sampFreq)
    waveforms = Array{Float64}(undef,snippetLength+bufferLength,numTrace,0)
    snippet = Array{Float64}(undef,snippetLength+bufferLength,numTrace,1)

    for d = 1:length(dateRange)-1

        # find all detections on the current day
    	detectionsToday = []
    	for t in detections
    		if Dates.unix2datetime(t) > dateRange[d] && Dates.unix2datetime(t) < dateRange[d+1]
    			detectionsToday = vcat(detectionsToday,Dates.unix2datetime(t))
    		end
    	end

        # make empty seisData object
        data = SeisData()

        # fill with trace for each station and component
    	for f = 1:numTrace
        	fname = dir * stas[f] * "/" * chans[f] * "/" * string(dateRange[d]) * "." * stas[f] * "." * chans[f] * ".noIR.SAC"
            SeisIO.read_data!(data,"sac", fname)
        end

        # only continue if there was data for that day on all stations and components
        if length(data) == numTrace

            # filter to desired band
            data = filterData(data,filterType,freq,corners)

            # downsample to 2*(top bound of pass band)
            #SeisIO.resample!(data,fs=sampFreq)

    		# extract and save each event
    		for n = 1:length(detectionsToday)

                # find index for detection
                detSec = Dates.value(detectionsToday[n]-Dates.DateTime(dateRange[d]))*0.001
                detIndex = floor(detSec * sampFreq)
                detIndex = convert(Int64,detIndex)

                # only pull for training set if a full 10 seconds of data can be extracted
                if detIndex-bufferLength > 0 && detIndex+snippetLength < 86400 * sampFreq
                    for l = 1:numTrace
                        snippet[:,l] = data[l].x[detIndex-bufferLength:detIndex+snippetLength-1]
                    end
                end

                # load into waveform matrix
                waveforms = cat(waveforms,snippet,dims=3)

            end

            # give some output so we know the code is working
            print("Successfully returned waveforms from detections on " * string(dateRange[d]) * ".\n")

        else
            print("No data on " * string(dateRange[d]) * ".\n")
        end

    end

    h5write(outName,"events",waveforms)

    return waveforms

end
