#import obspyh5
import obspy
from obspy.signal.cross_correlation import correlate_template
from obspy.signal.cross_correlation import xcorr_max
import numpy as np
import h5py

# set path
path = '/home/setholinger/Documents/Projects/PIG/detections/energy/run2/'

# load waveforms
#waveforms = obspy.read(path + 'waveforms.h5')
waveforms = obspy.read('/home/setholinger/Documents/Projects/PIG/detections/energy/run2/long_waveforms.h5')

# set filter parameters and filter waveforms
freq = [0.001,0.1]
waveforms.filter("bandpass",freqmin=freq[0],freqmax=freq[1])

# set master event for correlation
masterEvent = waveforms[52]

# open file for output
outFile = h5py.File(path + "long_correlations.h5","w")

# make some arrays for storing output
shifts = np.zeros((len(waveforms)))
corrCoefs = np.zeros((len(waveforms)))

for i in range(len(waveforms)):

    # correlate master event and waveform i
    corr = correlate_template(masterEvent,waveforms[i])
    shift, corrCoef = xcorr_max(corr)

    # save output
    shifts[i] = shift
    corrCoefs[i] = corrCoef

    # give the user some output
    print("Correlated master event with " + str(round(i/len(waveforms)*100)) + "% of events")

# write output to file
outFile.create_dataset("corrCoefs",data=corrCoefs)
outFile.create_dataset("shifts",data=shifts)

# close output file
outFile.close()
