include("readList.jl")
using Dates
files = readdir("/home/setholinger/Data/PIG/detections/PIG5/")
allDetections=Float64[];
	for f in files
		if occursin("HHN",f)==false
           		startDay = DateTime(split(f,".")[1])
           		detections = readList("/home/setholinger/Data/PIG/detections/PIG5/"*f)
          		if isnothing(detections) ==false
               			detections = Dates.Second.(round.(detections))+startDay
           		end
          		global allDetections= vcat(allDetections,detections)
		end
       end
write("pig5Detect.txt",string(allDetections))

