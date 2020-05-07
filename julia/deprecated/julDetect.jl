# code for STA/LTA detections
using Plots
using Statistics
using SeisIO

#TO DO:
#Plot with seconds on time axis

#ADD THE FOLLOWING ERROR MESSAGES:
#window must be shorter than data length
#short window must be shorter than long window
#threshold must be greater than 1

function detect(data::SeisData,longWinLength::Float64=60.,shortWinLength::Float64=5.,
                threshold::Float64=3.,overlap::Float64=30.)

    #convert window lengths from seconds to samples
    longWin = trunc(Int,longWinLength * data[1].fs)
    shortWin = trunc(Int,shortWinLength * data[1].fs)
    overlap = trunc(Int,overlap * data[1].fs)

    #calculate how much to move beginning of window each iteration
    slide = longWin-overlap
    detections = Float64[]
    numChan = data.n
    staLta = Float64[]
    STALTA = Array{Float64,2}(undef,8640000,numChan)

    #start count of total number of detections
    numTrig = 0

    #loop through SeisChannels in SeisData object
    for c = 1:numChan

        #set long window length to user input since last window of previous channel will have been adjusted
        longWin = trunc(Int,longWinLength * data[1].fs)

        #reset long window counter and triggers for current channel
        trigger = Float64[]
        i = 0

        #loop through current channel by sliding
        while i < length(data[c].x)

            #check if last window and change long window length if so
            if length(data[c].x) - i < longWin
                longWin = length(data[c].x)-i
            end

            #define chunk of data based on long window length and calculate long-term average
            longTrace = data[c].x[i+1:i+longWin]
            lta = mean(abs.(longTrace))

            #reset short window counter
            n = 0

            #loop through long window in short windows
            while n <= longWin - shortWin

                #define chunk of data based on short window length and calculate short-term average
                shortTrace = data[c].x[i+n+1:i+n+shortWin]
                sta = mean(abs.(shortTrace))

                #calculate sta/lta ration
                staLta = sta/lta

                #record sta/lta ratio for plotting
                STALTA[i+n+1,c] = staLta

                #record detection time if sta/lta ratio exceeds threshold

                #FIX BEFORE LEAVING
                #if staLta > threshold && lta > 0.00000001
                if staLta > threshold
                    trigTime = i + n + 1
                    trigger = vcat(trigger,trigTime)
                    numTrig = numTrig + 1
                end

                #advance short window
                n = n + shortWin
            end

            #advance long window
            i = i + slide

        end

        #fill detections matrix with trigger times and pad with zeros to make trigger vectors equal length
        if length(detections) == 0
            detections = vcat(detections,trigger)
        else
            diff = size(detections)[1]-size(trigger)[1]
            if diff > 0
                trigger = vcat(trigger,zeros(abs(diff)))
            end
            if diff < 0
                detections = vcat(detections,zeros(abs(diff),c-1))
            end
        detections = hcat(detections,trigger)
        end
    end

    #plot all 3 traces
    #tracePlot = plot(data.x,layout=(1,numChan),title=reshape((data.id),(1,numChan)),linewidth=1,size=(1000,200),legend=false)

    #plot sta/lta ratio
    #staPlot = plot(STALTA,label="STA/LTA Ratio",linewidth=1)

    #plot detections unless there are none
    #if numTrig > 0
    #    detPlot = plot(detections, layout=(1,numChan), seriestype="vline",linewidth=0.5,color = :red)
    #end

    #display and save plot
    #plotOut = plot(tracePlot,detPlot,layout = (2,1))
    #display(plotOut)
    #display(tracePlot)
    #convert detections from samples to seconds
    detections = detections/data.fs[1]

    #convert detections to unix time
    unixDetections = zeros(size(detections)[1],size(detections)[2])
    for c = 1:numChan
        for n = 1:size(detections)[1]
            if detections[n,c] != 0
                unixDetections[n,c] = detections[n,c] .+ data[c].t[1,2]
            end
        end
    end

    println(numTrig," detections")

    return unixDetections

end
