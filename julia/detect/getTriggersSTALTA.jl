# code for STA/LTA detections
using Statistics
using SeisIO

function getTriggersSTALTA(trace::Array{Float32,1},fs::Int=100,longWinLength::Float64=60.,shortWinLength::Float64=5.,
                threshold::Float64=3.,overlap::Float64=30.)

    #convert window lengths from seconds to samples
    longWin = trunc(Int,longWinLength * fs)
    shortWin = trunc(Int,shortWinLength * fs)
    overlap = trunc(Int,overlap * fs)

    #calculate how much to move beginning of window each iteration
    slide = longWin-overlap

    #set long window length to user input since last window of previous channel will have been adjusted
    longWin = trunc(Int,longWinLength * fs)

    #define long window counter and empty trigger vector
    triggers = zeros(length(trace))
    i = 1

    #loop through current channel by sliding
    while i < length(trace)

        #check if last window and change long window length if so
        if length(trace) - i < longWin
            longWin = length(trace)-i
        end

        #define chunk of data based on long window length and calculate long-term average
        longTrace = trace[i:i+longWin]
        lta = mean(abs.(longTrace))

        #reset short window counter
        n = 0

        #loop through long window in short windows
        while n <= longWin - shortWin

            #define chunk of data based on short window length and calculate short-term average
            shortTrace = trace[i+n:i+n+shortWin]
            sta = mean(abs.(shortTrace))

            #calculate sta/lta ration
            staLta = sta/lta

            #record detection time if sta/lta ratio exceeds threshold
            if staLta > threshold
                triggers[i+n] = 1
            end

            #advance short window
            n = n + shortWin
        end

        #advance long window
        i = i + slide

    end

    return triggers

end
