using SeisIO
using Dates

function testParallel(day::Date)
    dir = "/media/setholinger/Data/Data/PIG/SAC/noIR/"
    fname = dir * "PIG2/HHZ/" * string(day) * ".PIG2.HHZ.noIR.SAC"
    data = SeisData()
    SeisIO.read_data!(data,"sac", fname)
    max = maximum(data[1].x)
    return max
end
