import obspy
import glob
import numpy as np
import matplotlib.pyplot as plt
import os
import removeResponse


def removeResponse(st,freqBand,path2resp,nameOut,formatOut):
	st.detrend("demean")
	st.detrend("linear")
	st.taper(max_percentage=0.01, max_length=20)
	st.simulate(paz_remove=None, pre_filt=freqBand, seedresp=path2resp)
	st.write(nameOut,format=formatOut)
	return 


network = "PIG"
networkID = "XC"
stat = "PIG1"
chan = "HHZ"

freqBand = [0.0005,0.001,45,50]

pathMSEED = "/media/setholinger/Data/Data/" + network + "/MSEED/raw/" + stat + "/" + chan + "/"
pathRESP = {'filename': "/media/setholinger/Data/Data/PIG/RESP/" + "RESP" + '.' + networkID + '.' + stat + ".." + chan, 'units': 'DISP'}

# get list of all files in current directory
files = glob.glob(pathMSEED + "*")
files.sort()

#loop through all files 
for f in files:

	#read in one data file
	st = obspy.read(f)   
	nameOut = "/media/setholinger/Data/Data/" + network + "/MSEED/noIR/" + stat + "/" + chan + "/" + str(st[0].stats.starttime).split("T")[0] + "." + stat + "." + st[0].stats.channel + ".noIR" + ".MSEED"
	removeResponse(st,freqBand,pathRESP,nameOut,"MSEED")
	print("Response removed from " + f)


