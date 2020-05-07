#plot traces at all PIG stations for a given interval of time

using SeisIO
include("filterData.jl")

#set time window
day = "2013-09-05"
startSample = 7891500
startSec = startSample/100
endSample = 7894000


floorSec = floor(startSec/60)
sec = startSec-floorSec*60
floorMin = floor(floorSec/60)
min = floorSec-floorMin*60
hr = floorMin


path = "/home/setholinger/Data/PIG/SAC/" 

filtFreq = [5.,25.]
filtType = "Bandpass"

#PIG1
#read each station and combine into SeisData
PIG1HHZ= SeisIO.readsac(path*"PIG1/"*day*".PIG1.HHZ.noIR.SAC")
PIG1HHN= SeisIO.readsac(path*"PIG1/"*day*".PIG1.HHN.noIR.SAC")
PIG1HHE= SeisIO.readsac(path*"PIG1/"*day*".PIG1.HHE.noIR.SAC")
PIG1 = SeisIO.SeisData(PIG1HHZ,PIG1HHN,PIG1HHE)

#filter SeisData
filterData(PIG1,filtType,filtFreq,4)


#PIG2
#read each station and combine into SeisData
PIG2HHZ= SeisIO.readsac(path*"PIG2/"*day*".PIG2.HHZ.noIR.SAC")
PIG2HHN= SeisIO.readsac(path*"PIG2/"*day*".PIG2.HHN.noIR.SAC")
PIG2HHE= SeisIO.readsac(path*"PIG2/"*day*".PIG2.HHE.noIR.SAC")
PIG2 = SeisIO.SeisData(PIG2HHZ,PIG2HHN,PIG2HHE)

#filter SeisData
filterData(PIG2,filtType,filtFreq,4)


#PIG3
#read each station and combine into SeisData
PIG3HHZ= SeisIO.readsac(path*"PIG3/"*day*".PIG3.HHZ.noIR.SAC")
PIG3HHN= SeisIO.readsac(path*"PIG3/"*day*".PIG3.HHN.noIR.SAC")
PIG3HHE= SeisIO.readsac(path*"PIG3/"*day*".PIG3.HHE.noIR.SAC")
PIG3 = SeisIO.SeisData(PIG3HHZ,PIG3HHN,PIG3HHE)

#filter SeisData
filterData(PIG3,filtType,filtFreq,4)


#PIG4
#read each station and combine into SeisData
PIG4HHZ= SeisIO.readsac(path*"PIG4/"*day*".PIG4.HHZ.noIR.SAC")
PIG4HHN= SeisIO.readsac(path*"PIG4/"*day*".PIG4.HHN.noIR.SAC")
PIG4HHE= SeisIO.readsac(path*"PIG4/"*day*".PIG4.HHE.noIR.SAC")
PIG4 = SeisIO.SeisData(PIG4HHZ,PIG4HHN,PIG4HHE)

#filter SeisData
filterData(PIG4,filtType,filtFreq,4)



#PIG5
#read each station and combine into SeisData
PIG5HHZ= SeisIO.readsac(path*"PIG5/"*day*".PIG5.HHZ.noIR.SAC")
PIG5HHN= SeisIO.readsac(path*"PIG5/"*day*".PIG5.HHN.noIR.SAC")
PIG5HHE= SeisIO.readsac(path*"PIG5/"*day*".PIG5.HHE.noIR.SAC")
PIG5 = SeisIO.SeisData(PIG1HHZ,PIG1HHN,PIG1HHE)

#filter SeisData
filterData(PIG5,filtType,filtFreq,4)

traceGrid = hcat(hcat(PIG1.x[1][startSample:endSample,:],PIG1.x[2][startSample:endSample,:],PIG1.x[3][startSample:endSample,:]),hcat(PIG2.x[1][startSample:endSample,:],PIG2.x[2][startSample:endSample,:],PIG2.x[3][startSample:endSample,:]),hcat(PIG3.x[1][startSample:endSample,:],PIG3.x[2][startSample:endSample,:],PIG3.x[3][startSample:endSample,:]),hcat(PIG4.x[1][startSample:endSample,:],PIG4.x[2][startSample:endSample,:],PIG4.x[3][startSample:endSample,:]),hcat(PIG5.x[1][startSample:endSample,:],PIG5.x[2][startSample:endSample,:],PIG5.x[3][startSample:endSample,:]))

tracePlot = plot(traceGrid,layout=(5,3),linewidth=1,size=(2000,1000),legend=false)
savefig(string(day,"_",Int(floor(hr)),":",Int(floor(min)),":",Int(floor(sec))))
