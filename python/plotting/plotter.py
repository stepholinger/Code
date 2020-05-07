import obspy
import glob
import numpy as np
import matplotlib.pyplot as plt
import os

# choose dataset
stat = "PIG3"
network = "PIG"
networkID = "XC"

pathSAC = "/home/setholinger/Data/" + network + "/" + stat + "/"

# choose filter band (Hz)
freqMin = 1
freqMax = 10

# get list of all files in current directory
files = glob.glob(pathSAC + "*HHE*")
files.sort()

# loop through files 
for i in range(np.size(files)):

    # read, filter, and then plot all three traces
    st = obspy.read(files[i].split("HHE")[0] + "HH*" + files[i].split("HHE")[1])
    st.filter('bandpass',freqmin = freqMin,freqmax = freqMax)
    fig = st.plot()
