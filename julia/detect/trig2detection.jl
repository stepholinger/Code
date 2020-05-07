function trig2detection(trigArray,numSta::Int,numChan::Int,numSamples::Int,detectionWindow::Int,compThresh::Int,staThresh::Int)


    #loop through number of samples
    detections = Int[]
    quality = Int[]
    x=1
    while x<numSamples

        #make array to store number of triggers on each station
        trigSta = zeros(numSta)

        #loop through number of stations
        for s=1:numSta
	    
            #make array to store number of triggers channel
            trigChan = zeros(numChan)

            #loop through number of channels
            for c=1:numChan
        
                #record whether each component has triggers in the current window
                if sum(trigArray[s,c][x:x+detectionWindow-1]) > 0
                    trigChan[c] = 1
                end

            end

            #check if each station has triggers on at least 2 components
            if sum(trigChan) >= compThresh
                trigSta[s] = 1
            end

        end

        #check if at least 3 stations have triggers on at least 2 components
        if sum(trigSta) >= staThresh
            append!(detections,x)
	    append!(quality,sum(trigSta))
        end

        #advance counter
        x = x + detectionWindow

    end

    return detections,quality

end
