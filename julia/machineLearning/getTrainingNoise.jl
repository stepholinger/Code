using FFTW
using DSP
using HDF5

function getTrainingNoise(numSignals::Int,numStat::Int,numChans::Int,signalLength::Int,fs::Int,
    freq::Array{Int,1}=[1,100],corners::Int=4,outName::String="waveforms.h5")

    # set a buffer length for eliminating filter edge effects
    bufferLength = 100

    # consolidate into total number of components
    numChans = numStat*numChans

    # make blank array to store noise
    waveforms = zeros(signalLength,numChans,numSignals)

    # design filter
    responsetype = Bandpass(freq[1], freq[2]; fs=fs)
    designmethod = Butterworth(corners)

    for n = 1:numSignals
        for c = 1:numChans

            # make random signal
            noise = rand(signalLength + bufferLength * 2)

            # filter noise to desired band
            filtNoise = filt(digitalfilter(responsetype, designmethod), noise)

            # fill matrix of waveforms
            waveforms[:,c,n] = filtNoise[bufferLength:end-bufferLength-1]
        end

    end

    #h5write(outName,"noise",waveforms)

    return waveforms

end
