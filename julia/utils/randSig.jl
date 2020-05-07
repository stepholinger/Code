#makes random signal in sampleData object

struct sampleData
    trace
    sampleRate
    startTime
end

function randSig()
    length = rand(1:100000)
    signal = sampleData(rand(length).- 0.5,10,0)

    #add random coherent signals
    for i = 1:rand(1:100)
        amp = rand(1:10)
        ind = rand(1:length)
        signal.trace[ind] = amp
        signal.trace[ind+1] = -amp

    end

    plot(signal.trace)
    return signal
end
