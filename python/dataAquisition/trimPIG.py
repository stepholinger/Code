import obspy
import glob
import numpy as np
import matplotlib.pyplot as plt
import os
import removeResponse

network = "PIG"
networkID = "XC"
stat = "PIG5"
chan = "HHE"

freqBand = [0.05, 0.1, 45, 50]

pathSAC = "/home/setholinger/Data/" + network + "/" + stat + "/"
pathRESP = {'filename': "/home/setholinger/Data/" + network + "/RESP/" + "RESP" + '.' + networkID + '.' + stat + ".." + chan, 'units': 'DISP'}

startDay = obspy.UTCDateTime("2012-01-01T00:00:00")
endDay = obspy.UTCDateTime("2014-01-01T00:00:00")
numDays = int((endDay-startDay)/86400)

#create variable with all days in time range
days = np.zeros(numDays)
for n in range(numDays):
	days[n] = startDay + n * 86400

# get list of all files in current directory
files = glob.glob(pathSAC + "*" + chan + ".M.SAC")
files.sort()

#loop through all files 
for i in range(np.size(files)):

	flag = 0

	#read in one data file
	st = obspy.read(files[i])   
	st2 = st.copy()
	st3 = st.copy()

	#loop through list of days
	for n in range(np.size(days)-1):
			    
		if flag==1:
			st = st2

		#if st has data on that day, trim it and write it
		if days[n]>st[0].stats.starttime and days[n+1]<st[0].stats.endtime:
		    
			#trim file
			st.trim(obspy.UTCDateTime(days[n]),obspy.UTCDateTime(days[n+1]),nearest_sample=False,pad=True,fill_value=0)

			#remove instrument response
			nameOut = pathSAC + str(st[0].stats.starttime).split("T")[0] + "." + stat + "." + st[0].stats.channel + ".noIR" + ".SAC"
			removeResponse(st,freqBand,pathRESP,nameOut,"SAC")

			flag = 1

		#if st3 has some data on that day but ends before 23:59:99, merge with next file and then trim
		if days[n]<st3[0].stats.endtime and days[n+1]>st3[0].stats.endtime:
		    
			#check for gaps
			st4 = obspy.read(files[i+1])
			if np.abs(st4[0].stats.starttime - st3[0].stats.endtime) < 100:

				#merge next file
				st3 += obspy.read(files[i+1])
				st3.merge()

				#trim file
				st3.trim(obspy.UTCDateTime(days[n]),obspy.UTCDateTime(days[n+1]),nearest_sample=False,pad=True,fill_value=0)

				#remove instrument response
				nameOut = pathSAC +  str(st3[0].stats.starttime).split("T")[0] + "." + stat + "." + st3[0].stats.channel + ".noIR" + ".SAC"
				removeResponse(st3,freqBand,pathRESP,nameOut,"SAC")


