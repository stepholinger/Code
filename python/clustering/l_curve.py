import tslearn
from tslearn.generators import random_walks
from tslearn.preprocessing import TimeSeriesScalerMeanVariance
from tslearn.clustering import KShape
import matplotlib.pyplot as plt
import time
import numpy as np
import obspy
from obspy.signal.cross_correlation import correlate
from obspy.signal.cross_correlation import xcorr_max
import h5py

# read in waveforms
# define path to data and templates
path = "/media/Data/Data/PIG/MSEED/noIR/"
templatePath = "/home/setholinger/Documents/Projects/PIG/detections/templateMatch/multiTemplate/run3/"

prefiltFreq = [0.05,1]

numClusters = range(2,16)
inertia_vect = np.zeros((len(numClusters),1))
d_inertia_dt = np.zeros((len(numClusters),1))

for f in range(len(numClusters)):
    outFile = h5py.File(templatePath + "clustering/" + str(numClusters[f]) + "_cluster_predictions_" + str(prefiltFreq[0]) + "-" + str(prefiltFreq[1]) + "Hz.h5","r")
    inertia = outFile['inertia']
    inertia_vect[f] = inertia[()]
    if f > 0:
        d_inertia_dt[f-1] = inertia_vect[f]-inertia_vect[f-1]
    outFile.close()

plt.plot(numClusters,inertia_vect)
plt.xlabel("Number of clusters")
plt.ylabel("Inertia")
plt.show()

plt.plot(numClusters,d_inertia_dt)
plt.show()
