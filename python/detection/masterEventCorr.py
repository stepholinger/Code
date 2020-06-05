import obspyh5
import obspy
from obspy.signal.cross_correlation import correlate
from obspy.signal.cross_correlation import xcorr_max
import numpy as np
import h5py

# set path
path = '/home/setholinger/Documents/Projects/PIG/detections/energy/conservative/'

# load waveforms
#waveforms = obspy.read(path + 'waveforms.h5')
waveforms = obspy.read('/home/setholinger/Documents/Projects/PIG/detections/energy/conservative/waveforms.h5')

# set filter parameters and filter waveforms
#freq = [0.05,0.1]
#waveforms.filter("bandpass",freqmin=freq[0],freqmax=freq[1])

# set master event for correlation
masterEvent = waveforms[1]

# open file for output
outFile = h5py.File(path + "correlations.h5","w")

# make some arrays for storing output
shifts = np.zeros((len(waveforms)))
corrCoefs = np.zeros((len(waveforms)))

for i in range(len(waveforms)):

    # correlate master event and waveform i
    corr = correlate(masterEvent,waveforms[i],len(waveforms[i].data),normalize='naive')
    shift, corrCoef = xcorr_max(corr)

    # save output
    shifts[i] = shift
    corrCoefs[i] = corrCoef

    # give the user some output
    print("Correlated master event with " + str(round(i/len(waveforms)*100)) + "% of remaining events")

# write output to file
outFile.create_dataset("corrCoefs",data=corrCoefs)
outFile.create_dataset("shifts",data=shifts)

# close output file
outFile.close()
