import obspy
import collections
from obspy.signal.cross_correlation import correlation_detector
import glob
import numpy as np
import multiTemplateMatch

# this code produce the detections in the folder 'multiTemplate'

# define path to data and templates
path = "/media/Data/Data/PIG/MSEED/noIR/"
templatePath = "/home/setholinger/Documents/Projects/PIG/detections/energy/"

# define station and channel parameters
stat = "PIG2"
chans = ["HHZ","HHE","HHN"]

# define template match parameters for first template
threshLow = 0.6
threshHigh = 0.2
tolerance = 60

# define filter parameters for templates
freqLow = [0.001,0.1]
freqHigh = [1, 10]

# read in tempates from energy detector
templates = obspy.read(templatePath + 'conservativeWaveforms.h5')

# make array for storing all detections
allDetections = []

for t in range(len(templates)):

    temp = templates[t]

    tempLims = [temp.stats.starttime, temp.stats.endtime]

    # run the template matching algorithm for first template
    detections = multiTemplateMatch.multiTemplateMatch(path,stat,chans,tempLims,freqLow,threshLow,tempLims,freqHigh,threshHigh,tolerance)

    # store results in big array
    allDetections = allDetections + detections

    print("Scanned data with " + str(t) + " of " + len(templates) + " templates \n")

# sort results
def func(t):
    return t.ns
allDetections.sort(key=func)

# remove redundant detections
finalDetections = [allDetections[0]]
for d in range(len(allDetections)):
        if allDetections[d] - allDetections[d-1] > 60:
            finalDetections.append(allDetections[d])

# save results
with open('/home/setholinger/Documents/Projects/PIG/detections/templateMatch/multiTemplate/multiTemplateDetections.txt', 'w') as f:
    for item in finalDetections:
        f.write("%s\n" % item)
