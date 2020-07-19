import matplotlib.pyplot as plt
import time
import numpy as np
import obspy
from obspy.signal.cross_correlation import correlate
from obspy.signal.cross_correlation import xcorr_max
import h5py
from matplotlib.dates import date2num
from matplotlib.dates import DateFormatter

# read in waveforms
# define path to data and templates
path = "/media/Data/Data/PIG/MSEED/noIR/"
templatePath = "/home/setholinger/Documents/Projects/PIG/detections/templateMatch/multiTemplate/run3/"
fs = 2
numCluster = 10;

# load matrix of waveforms
prefiltFreq = [0.05,1]
waves = obspy.read(templatePath + 'short_waveforms_' + str(prefiltFreq[0]) + "-" + str(prefiltFreq[1]) + 'Hz.h5')

# load clustering results
outFile = h5py.File(templatePath + "clustering/" + str(numCluster) + "/" + str(numCluster) + "_cluster_predictions_" + str(prefiltFreq[0]) + "-" + str(prefiltFreq[1]) + "Hz.h5","r")
pred = list(outFile["cluster_index"])
outFile.close()

# for each cluster, cross correlate, align and plot each event in the cluster in reference to the centroid
medAmpArray = []
for c in range(numCluster):

    # get events in current cluster
    clusterEvents = []
    for i in range(len(waves)):
        if pred[i] == c:
            clusterEvents.append(waves[i])

    # make empty array for storage
    maxAmps = np.zeros((len(clusterEvents)))
    detTimes = []

    # iterate through all waves in the current cluster
    for w in range(len(clusterEvents)):
        detTimes.append(clusterEvents[w].stats.starttime.datetime)
        maxAmps[w] = np.max(clusterEvents[w].data)

    # get median of waveform max amplitudes
    medAmp = np.median(maxAmps)
    medAmpArray.append(medAmp)

    # make simple histogram of max amplitudes
    plt.hist(maxAmps,100)
    ax = plt.gca()
    plt.title("Histogram of max amplitudes for events in cluster " + str(c))
    plt.xlabel("Max amplitude (m/s)")
    plt.ylabel("Detection count")
    plt.xlim([min(maxAmps),max(maxAmps)/2])
    ax.axvline(x=medAmp,color='red',linestyle='dashed')
    plt.text(3/2*medAmp,len(clusterEvents)/5,"Median amplitude: " + str(medAmp) + " m/s")
    plt.savefig(templatePath + "clustering/" + str(numCluster) + "/" + "cluster_" + str(c) + "_amplitude_distribution.png")
    plt.close()

    # make simple histogram of times
    startTime = waves[0].stats.starttime.datetime
    endTime = waves[-1].stats.starttime.datetime
    numDays = (endTime-startTime).days+1
    plotDates = date2num(detTimes)
    plt.hist(plotDates,numDays)
    ax = plt.gca()
    ax.xaxis.set_major_formatter(DateFormatter('%Y-%m-%d'))
    plt.title("Histogram of events in cluster " + str(c))
    plt.xlabel("Date")
    plt.ylabel("Detection count")
    plt.gcf().autofmt_xdate()
    plt.savefig(templatePath + "clustering/" + str(numCluster) + "/" + "cluster_" + str(c) + "_time_distribution.png")
    plt.close()

# save median amplitudes as hdf5 file
medFile = h5py.File(templatePath + "clustering/" + str(numCluster) + "/" + str(numCluster) + "_cluster_median_amplitudes.h5","w")
medFile.create_dataset("median_amplitudes",data=medAmpArray)
medFile.close()
