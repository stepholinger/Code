import obspy
import scipy
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from scipy import signal as sig

def smooth(x,window_len=11,window='hanning'):

    if x.ndim != 1:
        raise ValueError("smooth only accepts 1 dimension arrays.")

    if x.size < window_len:
        raise ValueError("Input vector needs to be bigger than window size.")

    if window_len<3:
        return x

    if not window in ['flat', 'hanning', 'hamming', 'bartlett', 'blackman']:
        raise ValueError("Window is on of 'flat', 'hanning', 'hamming', 'bartlett', 'blackman'")

    s=np.r_[x[window_len-1:0:-1],x,x[-2:-window_len-1:-1]]

    if window == 'flat':
        w = np.ones(window_len,'d')
    else:
        w = eval('np.'+window+'(window_len)')

    y = np.convolve(w/w.sum(),s,mode='valid')

    return y

# set network and station parameters
network = "PIG"
statChan = ["PIG2","HHZ"]
fileType = "MSEED"
fs = 100

# set filter parameters
filt = 0
freq = [1,10]

f = open('lists/freqMagInput.txt','r')
#f = open("test.txt")
detections = f.readlines()

# preallocate some arrays
amplitudes = np.zeros((len(detections),2))
eventDurations = np.zeros((len(detections),2))
frequenciesExcited = np.zeros(len(detections))

# make a counter
n = 0;

for d in detections:

    # get string for day of detection
    dateStr = d[0:10]
    yearStr	= d[0:4]
    monthStr = d[5:7]
    dayStr = d[8:10]
    hourStr = d[11:13]
    minStr = d[14:16]
    secStr = d[17:19]
    try:
        scanDuration = d[20:22]
        scanDuration = int(scanDuration)
    except:
        scanDuration  = 160

    st = obspy.read()
    st.clear()

    try:
    	# construct path for given network and station
    	path = "/media/Data/Data/" + network + "/" + fileType + "/noIR/" + statChan[0] + "/"

    	# read and filter data
    	st += obspy.read(path + statChan[1] + "/" + dateStr + "." + statChan[0] + "." + statChan[1] + ".noIR." + fileType)

    except:
    	print("Missing data!")

    # get unfiltered data for the day
    rawTrace = st.copy()[0].data

    # filter whole day of data
    st.filter('bandpass',freqmin=freq[0],freqmax=freq[1])
    filtTrace = st[0].data

    # extract raw and filtered data just for event
    rawEventTrace = rawTrace[((int(hourStr) * 60 + int(minStr)) * 60 + int(secStr)) * fs:((int(hourStr) * 60 + int(minStr) + scanDuration) * 60 + int(secStr)) * fs]
    filtEventTrace = filtTrace[((int(hourStr) * 60 + int(minStr)) * 60 + int(secStr)) * fs:((int(hourStr) * 60 + int(minStr) + scanDuration) * 60 + int(secStr)) * fs]

    # calculate envelope of raw and filtered data for event period
    rawEventTraceEnv = np.abs(sig.hilbert(rawEventTrace))
    filtEventTraceEnv = np.abs(sig.hilbert(filtEventTrace))

    # smooth the envelopes and shift to compensate for acausal lag
    winLenLow = scanDuration*60*10
    winLenHigh = scanDuration*60
    shiftLow = int(np.floor(winLenLow/2))
    shiftHigh = int(np.floor(winLenHigh/2))
    smoothedRawEventTraceEnv = smooth(rawEventTraceEnv,window_len=winLenLow,window='hanning')
    smoothedRawEventTraceEnv = smoothedRawEventTraceEnv[shiftLow:]
    smoothedFiltEventTraceEnv = smooth(filtEventTraceEnv,window_len=winLenHigh,window='hanning')
    smoothedFiltEventTraceEnv = smoothedFiltEventTraceEnv[shiftHigh:]

    # calculate mean value of day
    meanAmpLow  = np.mean(np.abs(rawTrace))
    meanAmpHigh  = np.mean(np.abs(filtTrace))

    # define event duration threshold
    threshLow = 2 * meanAmpLow
    threshHigh = 3 * meanAmpHigh

    # get index of max value
    maxIdxLow = np.where(rawEventTrace == np.max(rawEventTrace))[0][0]
    maxIdxHigh = np.where(filtEventTrace == np.max(filtEventTrace))[0][0]

    # find where smoothed envelope crosses threshold after max value is reached
    try:
        crossPointLow = np.where(smoothedRawEventTraceEnv[maxIdxLow:] < threshLow)[0][0] + maxIdxLow
        eventDurationLow = crossPointLow
    except:
        eventDurationLow = 0
    try:
        crossPointHigh = np.where(smoothedFiltEventTraceEnv[maxIdxHigh:] < threshHigh)[0][0] + maxIdxHigh
        eventDurationHigh = crossPointHigh
    except:
        eventDurationHigh = 0

    # get power spectra of event and frequency vector
    mag = np.fft.rfft(rawEventTrace)
    p = np.abs(mag)**2
    freqs = np.fft.rfftfreq(rawEventTrace.size, 1/fs)

    # estimate spectral centroid using frequency and amplitude vectors
    centroid = np.average(freqs,weights=p)

    frequencyExcited = freqs[np.where(p == np.max(p))[0][0]]

    # save the info we need
    amplitudes[n,0] = np.max(rawEventTrace)
    amplitudes[n,1] = np.max(filtEventTrace)
    eventDurations[n,0] = eventDurationLow/fs
    eventDurations[n,1] = eventDurationHigh/fs
    frequenciesExcited[n] = centroid

    # provide output before plotting (for development)
    #print(d)

    # plot normalized curves together (for development)
    plt.plot(rawEventTrace/np.max(rawEventTrace))
    plt.plot(smoothedRawEventTraceEnv/np.max(smoothedRawEventTraceEnv))
    plt.plot(filtEventTrace/np.max(filtEventTrace))
    plt.plot(smoothedFiltEventTraceEnv/np.max(smoothedFiltEventTraceEnv))
    plt.vlines([eventDurationLow,eventDurationHigh],-1,1)
    plt.hlines([threshLow/np.max(smoothedRawEventTraceEnv),threshHigh/np.max(smoothedFiltEventTraceEnv)],0,len(rawEventTrace))
    plt.savefig("/home/setholinger/Documents/Projects/PIG/freqMagPlots/" + d + ".png")
    plt.clf()
    #plt.show()

    # plot power spectrum (for development)
    #plt.plot(freqs,p)
    #plt.yscale("log")
    #plt.xscale("log")
    #plt.vlines(frequenciesExcited[n],np.min(p),np.max(p))
    #plt.show()

    # advance counter
    n += 1

f.close()

# make empty figure
fig = plt.figure(1)

# set up subplot grid
gridspec.GridSpec(3,2)

# plot event duration and frequency
ax1 = plt.subplot2grid((3,2), (0,0), colspan=1, rowspan=1)
plt.scatter(eventDurations[:,1],frequenciesExcited)
ax1.set_xlabel("High-Frequency Event Duration (s)")
ax1.set_ylabel("Spectral Centroid (Hz)")
plt.yscale("log")
plt.xlim(0,np.max(eventDurations[:,1]))
plt.ylim(0.001,0.1)

# plot amplitude and frequency
ax2 = plt.subplot2grid((3,2), (1,0), colspan=1, rowspan=1)
plt.scatter(amplitudes[:,1],frequenciesExcited)
ax2.set_xlabel("High-Frequency Event Amplitude (m/s)")
ax2.set_ylabel("Spectral Centroid (Hz)")
ax2.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
plt.yscale("log")
plt.xlim(0,np.max(amplitudes[:,1]))
plt.ylim(0.001,0.1)

# plot amplitude and frequency
ax3 = plt.subplot2grid((3,2), (2,0), colspan=1, rowspan=1)
plt.scatter(amplitudes[:,1],eventDurations[:,0])
ax3.set_xlabel("High-Frequency Event Amplitude (m/s)")
ax3.set_ylabel("Low-Frequency Event Duration (s)")
ax3.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
plt.xlim(0,np.max(amplitudes[:,1]))
plt.ylim(0,np.max(eventDurations[:,0]))

#plot event duration and frequency
ax4 = plt.subplot2grid((3,2), (0,1), colspan=1, rowspan=1)
plt.scatter(eventDurations[:,0],frequenciesExcited)
ax4.set_xlabel("Low-Frequency Event Duration (s)")
ax4.set_ylabel("Spectral Centroid (Hz)")
plt.yscale("log")
plt.xlim(0,np.max(eventDurations[:,0]))
plt.ylim(0.001,0.1)

# plot amplitude and frequency
ax5 = plt.subplot2grid((3,2), (1,1), colspan=1, rowspan=1)
plt.scatter(amplitudes[:,0],frequenciesExcited)
ax5.set_xlabel("Low-Frequency Event Amplitude (m/s)")
ax5.set_ylabel("Spectral Centroid (Hz)")
ax5.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
plt.yscale("log")
plt.xlim(0,np.max(amplitudes[:,0]))
plt.ylim(0.001,0.1)

# plot amplitude and frequency
ax6 = plt.subplot2grid((3,2), (2,1), colspan=1, rowspan=1)
plt.scatter(amplitudes[:,0],eventDurations[:,0])
ax6.set_xlabel("Low-Frequency Event Amplitude (m/s)")
ax6.set_ylabel("Low-Frequency Event Duration (s)")
ax6.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
plt.xlim(0,np.max(amplitudes[:,0]))
plt.ylim(0,np.max(eventDurations[:,0]))

plt.show()
