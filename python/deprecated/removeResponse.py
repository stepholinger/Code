import obspy
import glob
import numpy as np
import matplotlib.pyplot as plt
import os

def removeResponse(st,freqBand,path2resp,nameOut,formatOut):
	st.detrend("demean")
	st.detrend("linear")
	st.taper(max_percentage=0.01, max_length=20)
	st.simulate(paz_remove=None, pre_filt=freqBand, seedresp=path2resp)
	st.write(nameOut,format=formatOut)
	return 
