using SeisIO
include("julDetect.jl")
include("filterData.jl")

#PIG1
#get filenames
files = readdir("/home/setholinger/Data/PIG/SAC/PIG1")

for n in files
    
    #read data
    sac = SeisIO.readsac("/home/setholinger/Data/PIG/SAC/PIG1/" * n)
    
    #filter data
    filtSac = filterData(sac,"Highpass",[10.],4)

    #run detector
    detections = detect(filtSac,60,1,6.,1)
    
    fname = "/home/setholinger/Data/PIG/detections/PIG1/" * split(n,".n")[1] * ".detect.txt"
    outFile = open(fname,"w")
    write(outFile,string(detections))
end

#PIG2
#get filenames
files = readdir("/home/setholinger/Data/PIG/SAC/PIG2")

for n in files
    
    #read data
    sac = SeisIO.readsac("/home/setholinger/Data/PIG/SAC/PIG2/" * n)
    
    #filter data
    filtSac = filterData(sac,"Highpass",[10.],4)

    #run detector
    detections = detect(filtSac,60,1,6.,1)
    
    fname = "/home/setholinger/Data/PIG/detections/PIG2/" * split(n,".n")[1] * ".detect.txt"
    outFile = open(fname,"w")
    write(outFile,string(detections))
end

#PIG3
#get filenames
files = readdir("/home/setholinger/Data/PIG/SAC/PIG3")

for n in files
    
    #read data
    sac = SeisIO.readsac("/home/setholinger/Data/PIG/SAC/PIG3/" * n)
    
    #filter data
    filtSac = filterData(sac,"Highpass",[10.],4)

    #run detector
    detections = detect(filtSac,60,1,6.,1)
    
    fname = "/home/setholinger/Data/PIG/detections/PIG3/" * split(n,".n")[1] * ".detect.txt"
    outFile = open(fname,"w")
    write(outFile,string(detections))
end

#PIG4
#get filenames
files = readdir("/home/setholinger/Data/PIG/SAC/PIG4")

for n in files
    
    #read data
    sac = SeisIO.readsac("/home/setholinger/Data/PIG/SAC/PIG4/" * n)
    
    #filter data
    filtSac = filterData(sac,"Highpass",[10.],4)

    #run detector
    detections = detect(filtSac,60,1,6.,1)
    
    fname = "/home/setholinger/Data/PIG/detections/PIG4/" * split(n,".n")[1] * ".detect.txt"
    outFile = open(fname,"w")
    write(outFile,string(detections))
end

#PIG5
#get filenames
files = readdir("/home/setholinger/Data/PIG/SAC/PIG5")

for n in files
    
    #read data
    sac = SeisIO.readsac("/home/setholinger/Data/PIG/SAC/PIG5/" * n)
    
    #filter data
    filtSac = filterData(sac,"Highpass",[10.],4)

    #run detector
    detections = detect(filtSac,60,1,6.,1)
    
    fname = "/home/setholinger/Data/PIG/detections/PIG5/" * split(n,".n")[1] * ".detect.txt"
    outFile = open(fname,"w")
    write(outFile,string(detections))
end




