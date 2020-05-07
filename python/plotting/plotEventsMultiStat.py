import obspy

outPath = "/home/setholinger/Documents/Projects/PIG/detectionPlots/regional/HHZ/zoom/"

netStat = [["PIG","PIG2","HHZ"], ["YT","DNTW","BHZ"], ["YT","UPTW","BHZ"], ["YT","THUR","BHZ"], ["YT","BEAR","BHZ"]]
fileType = "MSEED"

freq = [1,10]

autoWindow = 0

f = open('energyRiftDetectionsZoom.txt','r')
detections = f.readlines()

for d in detections:

	# get string for day of detection
	dateStr = d[0:10]	
	yearStr	= d[0:4]
	monthStr = d[5:7]
	dayStr = d[8:10]
	hourStr = d[11:13]
	minStr = d[14:16]
	secStr = d[17:19]

	if autoWindow:

		# get start and end times for plotting window
		if int(hourStr) == 0:
			startTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr),int(minStr),int(secStr))
			endTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr)+2,int(minStr),int(secStr))

		elif int(hourStr) == 23:
			startTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr)-1,int(minStr),int(secStr))
			endTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr)+1,0,int(minStr),int(secStr))

		elif int(hourStr) == 22:
			startTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr)-1,int(minStr),int(secStr))
			endTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr)+1,0,int(minStr),int(secStr))

		else:	
			startTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr)-1,int(minStr),int(secStr))
			endTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr)+2,int(minStr),int(secStr))

	else:
		startTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr),int(minStr),int(secStr))

		if int(hourStr) == 23:

			endTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr)+1,0,int(minStr),int(secStr))	
	
		else:
		
			endTime = obspy.UTCDateTime(int(yearStr),int(monthStr),int(dayStr),int(hourStr)+1,int(minStr),int(secStr))

	st = obspy.read()
	st.clear()

	for n in range(len(netStat)):

		try:
			# construct path for given network and station
			path = "/media/Data/Data/" + netStat[n][0] + "/" + fileType + "/noIR/" + netStat[n][1] + "/"

			# read and filter data
			st += obspy.read(path + netStat[n][2] + "/" + dateStr + "." + netStat[n][1] + "." + netStat[n][2] + ".noIR." + fileType)
		
		except:
			print("Missing data!")

	# filter the data
	st.filter('bandpass',freqmin=freq[0],freqmax=freq[1])

	st.trim(startTime,endTime)
	
	st.plot(outfile = outPath + dateStr + "_" + str(startTime.hour) + ":00-" + str(endTime.hour) + ":00.png",method='full',equal_scale=False)

	f.close()
