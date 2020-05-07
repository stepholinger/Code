import os
import multiprocessing
from multiprocessing import Manager
import time

import obspy
from obspy import read
import obspyh5

import eqcorrscan
from eqcorrscan.core.template_gen import template_gen
from eqcorrscan.core.match_filter import Tribe
from eqcorrscan.core.match_filter import Template
from eqcorrscan.core.match_filter import match_filter

from eqCorrScanUtils import getFname
from eqCorrScanUtils import makeTemplate
from eqCorrScanUtils import parFunc
from eqCorrScanUtils import makeTemplateList



# define path to data and templates
path = "/media/Data/Data/PIG/MSEED/noIR/"
templatePath = "/home/setholinger/Documents/Projects/PIG/detections/energy/"

# read in h5 file of single channel templates- we will use the start and end times to make 3-component templates
tempH5 = obspy.read(templatePath + 'conservativeWaveforms.h5')[:10]

# define parallel parameters
readPar = 0
nproc = 8

# define station and channel parameters
stat = ["PIG2"]
chan = "HH*"
freq = [1,10]
filtType = "bandpass"

# enter the buffer used on the front and back end to produce templates
buff = [2*60,3*60]

[templates,template_names] = makeTemplateList(tempH5,buff,path,stat,chan,freq,filtType,readPar,nproc)
print("Loading 1 day of data...")

# read in data to scan
st = read()
st.clear()
for s in stat:
  fname = getFname(path,s,chan,obspy.UTCDateTime(2012,1,20,0,1))
  st += obspy.read(fname)

# basic preprocessing
st.detrend("demean")
st.detrend("linear")
st.taper(max_percentage=0.01, max_length=10.)
if filtType == "bandpass":
    st.filter(filtType,freqmin=freq[0],freqmax=freq[1])
    st.resample(freq[1]*2)
elif filtType == "lowpass":
    st.filter(filtType,freq=freq[0])
    st.resample(freq[0]*2)
elif filtType == "highpass":
    st.filter(filtType,freq=freq[0])

# start timer and give output
timer = time.time()
print("Starting scan...")

# run eqcorrscan's match filter routine
detections = match_filter(template_names=template_names,template_list=templates,st=st,threshold=8,threshold_type="MAD",trig_int=6,cores=20)

# stop timer and give output
runtime = time.time() - timer
print(detections)
print("Scanned 1 day of data with " + str(len(templates)) + " templates in " + str(runtime) + " seconds and found " + str(len(detections)) + " detections")
detections.plot()
