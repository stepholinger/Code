using SeisIO
using Distributed
using Dates
using Glob
using DelimitedFiles
using HDF5
include("../filterData.jl")

function getTestData(fileList::String="fileList.txt",filterType::String="none",
    freq::Array{Float64,1}=1,corners::Int=4,outName::String="testData.h5")

    # determine frequnecy of downsampled data
    sampFreq = freq[2] * 2

    # set desired file length (almost always one day)
    fileLength = Int(86400*sampFreq)

    # make list of files for training
    files = readdlm(fileList)

    # initialize blank SeisData
    data = SeisData()

    # fill with data from each file
    for f in files
        SeisIO.read_data!(data,"sac", String(f))
    end

    # filter data
    data = filterData(data,filterType,freq,corners)

    # downsample to 2*(top bound of pass band)
    SeisIO.resample!(data,fs=sampFreq)

    # put into one big matrix
    testData = zeros(fileLength,1)
    for i = 1:length(files)
    	testData = hcat(testData,data[i].x[1:fileLength])
    end
    testData = testData[:,2:size(testData,2)]

    # write to hdf5 file
    h5write(outName,"data",testData)

    return testData

end
