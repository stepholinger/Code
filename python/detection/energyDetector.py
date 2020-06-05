import glob
import time
import numpy as np
from scipy.signal import find_peaks
import matplotlib.pyplot as plt
import obspy
import obspyh5

path = "/media/Data/Data/PIG/MSEED/noIR/"
outPath = "/home/setholinger/Documents/Projects/PIG/detections/energy/run2/"
stat = "PIG2"
chan = "HHZ"
fileType = "MSEED"
fs = 100

# specify two frequency bands for energy calculation
freqLow = 0.5
freqHigh = [1,10]

# specify initial search parameters
prominenceHigh = 0.1
prominenceLow = 0.1

# allowable distance between low and high frequency detections, in seconds
tolerance = 120

# specify window to pull template around detection
buffFrontBase = 2*60
buffEndBase = 3*60

# get all files of desired station and channel
files = glob.glob(path + stat + "/" + chan + "/*", recursive=True)
files.sort()

# first day is garbage, so remove it
files = files[1:]

# scan a specific day (for testing)
#day = "2012-05-20"
#dayFile = path + stat + "/" + chan + "/" + day + "." + stat + "." + chan + ".noIR.MSEED"
#files = [dayFile]

for f in files:

    # give some output
    print("Scanning " + f + "...")

    # reset search parameters
    threshHigh = prominenceHigh
    threshLow = prominenceLow

    # start timer
    t = time.time()

	# read in one data file
    st = obspy.read(f)

    # basic preprocessing
    st.detrend("demean")
    st.detrend("linear")
    st.taper(max_percentage=0.01, max_length=10.)

    # copy for other bands
    stLow = st.copy()
    stHigh = st.copy()

    # filter the data
    stLow.filter("lowpass",freq=freqLow)
    stHigh.filter("bandpass",freqmin=freqHigh[0],freqmax=freqHigh[1])

    # square trace to get kinetic energy
    energyLow = np.square(np.array(stLow[0].data,dtype='float64'))
    energyHigh = np.square(np.array(stHigh[0].data,dtype='float64'))

    # normalize amplitudes (helps with peak finding)
    energyLow = energyLow/np.max(energyLow)
    energyHigh = energyHigh/np.max(energyHigh)

    # find maxima in both bands
    peaksLow,_ = find_peaks(energyLow,prominence=threshLow,distance=fs*tolerance)
    peaksHigh,_ = find_peaks(energyHigh,prominence=threshHigh,distance=fs*tolerance)

    # plot trace and energy peaks (for testing)
    #st.plot()
    #plt.plot(energyHigh)
    #plt.plot(energyLow)
    #plt.plot(peaksHigh,energyHigh[peaksHigh],"^")
    #plt.plot(peaksLow,energyLow[peaksLow],"v")
    #plt.show()

    # check if peaks are concurrent in each band
    for h in range(len(peaksHigh)):
        for l in range(len(peaksLow)):

            # reset buffers
            buffFront = buffFrontBase
            buffEnd = buffEndBase

            # reset detection flag
            flag = 0

            # skip to next iteration if low frequency detection is first
            if peaksLow[l] - peaksHigh[h] < 0:
                continue

            # check if biggest low freq peak of day
            if energyLow[peaksLow[l]]/np.max(energyLow) == 1:

                # check if at least two low freq peaks are within tolerance*10*fs seconds of the high freq peak
                if peaksLow[l] - peaksHigh[h] < tolerance*10*fs and peaksLow[l+1] - peaksHigh[h] < tolerance*10*fs:

                     # increase bounds for large event
                     buffFront = 5*buffFront
                     buffEnd = 5*buffFront

                     # set detection flag and filename parameter
                     flag = 1
                     type = 'long'

                # if not, check if normal detection criteria is met
                else:
                    if peaksLow[l] - peaksHigh[h] < tolerance*fs:

                        # set detection flag and filename parameter
                        flag = 1
                        type = 'short'

            # if not, check if normal detection criteria is met
            else:
                if peaksLow[l] - peaksHigh[h] < tolerance*fs:

                    # set detection flag and filename parameter
                    flag = 1
                    type = 'short'

            # if flag is set, pull out and save data
            if flag:

                # make bounds around detection
                winStart = st[0].stats.starttime + peaksHigh[h]/fs - buffFront
                winEnd = st[0].stats.starttime + peaksHigh[h]/fs + buffEnd

                # make plot of detection (for testing)
                #st.plot(starttime=winStart,endtime=winEnd)

                # extract detected event waveform
                det = st.slice(starttime=winStart,endtime=winEnd)

                # write the stream to hdf5
                det.write(outPath + type + '_waveforms.h5','H5',mode='a')
