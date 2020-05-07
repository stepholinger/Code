import glob
import time
import numpy as np
from scipy.signal import find_peaks
import matplotlib.pyplot as plt
import obspy
import obspyh5

path = "/media/Data/Data/PIG/MSEED/noIR/"
outPath = "/home/setholinger/Documents/Projects/PIG/detections/energy/"
stat = "PIG2"
chan = "HHZ"
fileType = "MSEED"
fs = 100

# specify two frequency bands for energy calculation
freqLow = 0.5
freqHigh = [1,10]

# specify initial search parameters
prominenceHigh = 0.25
prominenceLow = 0.25

# allowable distance between low and high frequency detections, in seconds
tolerance = 60

# specify window to pull template around detection
buffFront = 2*60
buffEnd = 3*60

# get all files of desired station and channel
files = glob.glob(path + stat + "/" + chan + "/*", recursive=True)
files.sort()
print(files)

# scan a specific day (use for tuning)
#day = "2012-02-23"
#dayFile = path + stat + "/" + chan + "/" + day + "." + stat + "." + chan + ".noIR.MSEED"
#files[0] = dayFile

for f in files:

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
    peaksLow,_ = find_peaks(energyLow,prominence=threshLow,distance=fs*60)
    peaksHigh,_ = find_peaks(energyHigh,prominence=threshHigh,distance=fs*60)

    # development features below
    print(f)
    #plt.plot(energyHigh)
    #plt.plot(energyLow)
    #plt.plot(peaksHigh,energyHigh[peaksHigh],"^")
    #plt.plot(peaksLow,energyLow[peaksLow],"v")

    # check if peaks are concurrent in each band
    for pH in peaksHigh:
        for pL in peaksLow:

            # widen tolerance if max energy of the day (biggest events are longer duration)
            if energyHigh[pH]/np.max(energyHigh) == 1 and energyLow[pL]/np.max(energyLow) == 1:
                 if pL - pH < tolerance*10*fs and pL - pH > 0:

                     # make bounds around detection
                     winStart = st[0].stats.starttime + pH/fs - buffFront*10
                     winEnd = st[0].stats.starttime + pH/fs + buffEnd*10

                     # extract detected event waveform
                     det = st.slice(starttime=winStart,endtime=winEnd)

                     # write the stream to hdf5
                     det.write(path + 'waveforms.h5','H5',mode='a')

                     #plt.plot(pH,energyHigh[pH],"*")

            else:
                if pL - pH < tolerance*fs and pL - pH > 0:

                    # make bounds around detection
                    winStart = st[0].stats.starttime + pH/fs - buffFront
                    winEnd = st[0].stats.starttime + pH/fs + buffEnd
                    print(winStart)

                    # extract detected event waveform
                    det = st.slice(starttime=winStart,endtime=winEnd)

                    # write the stream to hdf5
                    det.write(outPath + 'conservativeWaveforms.h5','H5',mode='a')

                    #plt.plot(pH,energyHigh[pH],"*")

    #print(detections)
