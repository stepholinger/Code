using SeisIO
using Distributed
using Dates

function getDateRange(stas,chans,dir)

    #find range of days to iterate through
    startArray = Array{Int}(undef,length(stas),length(chans))
    endArray = Array{Int}(undef,length(stas),length(chans))

    for s=1:length(stas)
        for c=1:length(chans)
              files = readdir(dir*stas[s]*"/"*chans[c]*"/")
              startArray[s,c]= Dates.value(Date(split(files[1],".")[1]))
              endArray[s,c]= Dates.value(Date(split(files[end],".")[1]))
        end
    end

    dayRange = Date(Dates.UTD(minimum(startArray))):Day(1):Date(Dates.UTD(maximum(endArray)))

    return dayRange

end

function getFilenames(d,stas,chans,dir)

    files = Array{String}(undef,length(stas)*length(chans))
    dayString = Dates.format(d,"yyyy-mm-dd")
    i = 1
    for s in stas
        for c in chans
            f = glob("*"*dayString*"*"*c*"*",dir*s*"/"*c*"/")

            if isempty(f) == false
                files[i] = f[1]
            else
                files[i] = ""
            end

            i = i+1
        end
    end

    return files
end

function convertToUnixTime(detections,fs,day)
    #convert detectionsfrom samples to seconds and then add SeisData starttime after converting from microseconds to seconds
    detections = detections./fs
    unixDetections = detections .+ datetime2unix(DateTime(day))
    return unixDetections
end
