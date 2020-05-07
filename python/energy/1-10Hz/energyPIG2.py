import obspy
import glob
import numpy as np

#find files
chan = ["HHZ","HHN","HHE"]
stat = "PIG2"

fileMat = []

for c in chan:
	path = "/media/Data/Data/PIG/MSEED/noIR/" + stat + "/" + c + "/*"
	files = glob.glob(path)
	files.sort()
	fileMat.append(files)

f1 = open("detectBand" + stat + ".txt","ab")
f2 = open("energyTimeStamps" + stat + ".txt","a")

#loop through all files
for f in range(len(fileMat[0])):

	sumSeries = np.zeros(8640000)

	skip = 0	
	
	for c in range(len(chan)):

		#pull out the current day for utility reasons
		fname = fileMat[c][f].split("/")[9]
		day = fname.split(".")[0]

		if skip == 0:

			#read data
			st = obspy.read(fileMat[c][f])

			print(fileMat[c][f])

			#check if file has whole day- if not, we will just fill with 0s (treat it as a gap)
			if len(st[0].data) >= 8640000:

				#basic preprocessing
				st.detrend("demean")
				st.detrend("linear")

				#taper and filter in detection band
				st.taper(max_percentage=0.01, max_length=10.)
				st.filter("bandpass",freqmin=1.,freqmax=10.)

				#square trace
				detectSquared = np.square(np.array(st[0].data,dtype='float64'))

				#trim to 8640000 samples in case of slight unevenness to make sure reshape works properly
				detectSquared = detectSquared[0:8640000]
				
				#add to squared timeseries of other traces
				sumSeries = sumSeries + detectSquared

			else:
				skip = 1	

	if skip == 0:
	
		#take elementwise square root
		rootSeries = np.sqrt(sumSeries)

		#calculate total energy
		sumEnergy = np.sum(rootSeries)

		print(day)
		print(sumEnergy)
				
		#append to text file
		np.savetxt(f1,[sumEnergy])
		f2.write(day + "\n")

	else:
		print("Skipping " + day + "\n")
		np.savetxt(f1,[0])
		f2.write(day + "\n")

f1.close()
f2.close()
