import obspy
import glob
import time

#specify network and make path variable
network = "YT"
fileType = "MSEED"
path = "/media/Data/Data/" + network
chan = "*BH*"

#set frequency band for response removal
pre_filt = [0.0005,0.001,15,20]

#make a list of all files in the raw folder
filesRaw = glob.glob(path + "/" + fileType + "/raw/**/" + chan, recursive=True)

print(filesRaw)
 
#make a list of all files in the noIR folder
filesNoIR = glob.glob(path + "/" + fileType + "/noIR/**/*" + chan, recursive=True)

#manually make a list of files to skip
fileSkip = [path + "/" + fileType + "/raw/BEAR/YT.BEAR..BHN__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/BEAR/YT.BEAR..BHZ__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/BEAR/YT.BEAR..BHE__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/THUR/YT.THUR..BHN__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/THUR/YT.THUR..BHZ__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/THUR/YT.THUR..BHE__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/UPTW/YT.UPTW..BHN__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/UPTW/YT.UPTW..BHZ__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/UPTW/YT.UPTW..BHE__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/DNTW/YT.DNTW..BHN__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/DNTW/YT.DNTW..BHN__20120630T000000Z__20120701T000000Z.mseed",
		path + "/" + fileType + "/raw/DNTW/YT.DNTW..BHZ__20120630T000000Z__20120701T000000Z.mseed"]

#remove any specified files from list of raw data files
for f in range(len(fileSkip)):
	print("Skipping file " + fileSkip[f])
	if any(fileSkip[f] in s for s in filesRaw):
	     filesRaw.remove(fileSkip[f])

#remove subdirectories from raw file list and sort
filesRaw = [i for i in filesRaw if len(i) > 80]
filesRaw.sort()

print(filesRaw)

#remove subdirectories from noIR file list and sort
filesNoIR = [i for i in filesNoIR if len(i) > 60]
filesNoIR.sort()

#loop through all raw files
for f in filesRaw:

	#start timer
	t = time.time()

	#read in one data file
	st = obspy.read(f)

	#grab a couple useful variables from file metadata
	stat = st[0].stats.station
	chan = st[0].stats.channel
	startDate = str(st[0].stats.starttime).split("T")[0]

	#specify output filename format
	nameOut = path + "/" + fileType +"/noIR/" + stat + "/" + chan + "/" + startDate + "." + stat + "." + chan + ".noIR" + "." + fileType

	#check whether a file by that name exists in the noIR folder; if so, skip it
	if nameOut in filesNoIR:
		print("Response already removed from " + f + ".")

	#otherwise, remove the response from the file
	else:

		#print("Removing response from " + f + "...")

		#preprocess file
		st.detrend("demean")
		st.detrend("linear")
		st.taper(max_percentage=0.00025, max_length=20.)

		#read correct stationXML file
		pathXML = glob.glob(path + "/XML/*" + stat + "*.xml")[0]
		inv = obspy.read_inventory(pathXML)

		#remove instrument response
		st.remove_response(inventory=inv,pre_filt=pre_filt,output="VEL")

		#write new file
		st.write(nameOut,format=fileType)

		#end timer
		runTime = time.time() - t

		#give some output to check progress
		print("Response removed from " + f + " using " + pathXML.split("/")[-1] + " in " + str(runTime) + " seconds.")
