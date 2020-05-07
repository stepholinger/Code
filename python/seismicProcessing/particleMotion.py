import obspy
from matplotlib import cm
from matplotlib.colors import ListedColormap, LinearSegmentedColormap
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np
	
def tFormat(t):
	if t < 10:
		tStr = "0" + str(t)
	else:
		tStr = str(t)
	return tStr

network = "PIG"
stat = "PIG2"
chans = ["HHN","HHE","HHZ"]
chanIdx = [1,2]
fileType = "MSEED"
fs = 100
path = "/media/Data/Data/" + network + "/" + fileType + "/noIR/" + stat + "/"

rotate = 1
backAz = 310

year = 2012
month = 5
day = 9
hour = 18
minute = 1
second = 31
length = 30000
startInd = ((hour*60+minute)*60+second)*fs
endInd = startInd + length

# make time unit strings for filenames
monthStr = tFormat(month)
dayStr = tFormat(day)
hourStr = tFormat(hour)
minuteStr = tFormat(minute)
secondStr = tFormat(second)
dateString = str(year) + "-" + monthStr + "-" + dayStr

freq = [1,10]

# read and filter data
st = obspy.read(path + chans[0] + "/" + dateString + "." + stat + "." + chans[0] + ".noIR." + fileType)
st += obspy.read(path + chans[1] + "/" + dateString + "." + stat + "." + chans[1] + ".noIR." + fileType)
st += obspy.read(path + chans[2] + "/" + dateString + "." + stat + "." + chans[2] + ".noIR." + fileType)
st.filter('bandpass',freqmin=freq[0],freqmax=freq[1])

# rotate seismogram if desired
if rotate: 
	st.rotate('NE->RT',backAz)
	
# extract data for plotting window
comp1 = st[chanIdx[0]].data[startInd:endInd];
comp2 = st[chanIdx[1]].data[startInd:endInd];

# get time axis for plotting window
times = st[0].times("matplotlib")[startInd:endInd]

# choose length to be plotted and how often to output a frame
colorLength = 250
skip = 10

for n in range(skip,length,skip):

	# make empty figure
	fig = plt.figure(1)

	# set up subplot grid
	gridspec.GridSpec(4,1)

	# plot trace in top panel of figure
	ax1 = plt.subplot2grid((4,1), (0,0), colspan=1, rowspan=1)
	plt.plot_date(times,comp2,fmt='-',linewidth=1)
	ax1.vlines(times[n],-1*abs(max(comp2)),abs(max(comp2)))
	dateFmt = matplotlib.dates.DateFormatter('%H:%M')
	ax1.xaxis.set_major_formatter(dateFmt)
	ax1.xaxis.tick_top()

	# plot particle motion in bottom panel of figure
	ax2 = plt.subplot2grid((4,1), (1,0), colspan=1, rowspan=3)
	ax2.set_xlabel(st[chanIdx[0]].stats.channel + " Velocity (m/s)")
	ax2.set_ylabel(st[chanIdx[1]].stats.channel + " Velocity (m/s)")
	ax2.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
	ax2.ticklabel_format(style='sci', axis='x', scilimits=(0,0))

	# choose base colormap
	plt.set_cmap('plasma_r')

	# use default colormap for first few frames
	if n <= colorLength:
		plasma = cm.get_cmap('plasma_r',n)
		cmap = plasma(np.linspace(0, 1,n))
		plt.scatter(comp1[0:n],comp2[0:n],c=cmap,s=5)
	else:
		# altered colormap setup
		plasma = cm.get_cmap('plasma_r', colorLength)
		newcolors = plasma(np.linspace(0, 1, colorLength))
		white = np.ones((n-colorLength,4))
		newcolors = np.vstack((white,newcolors))

		# plot with altered colormap
		plt.scatter(comp1[0:n],comp2[0:n],c=newcolors,s=5)

	# set axis limits
	plt.xlim(-1*(abs(max(comp1))), abs(max(comp1)))
	plt.ylim(-1*(abs(max(comp2))), abs(max(comp2)))

	# correct wonky formatting
	fig.tight_layout()

	if rotate:
		# save figure
		plt.savefig("/home/setholinger/Documents/Projects/PIG/particleAnimation/" + stat + "/rotated/" + dateString + "_" + hourStr + ":" + minuteStr + "/" + st[chanIdx[0]].stats.channel + "_" + st[chanIdx[1]].stats.channel + "/" + str(n) + ".png")
	
	else:
		# save figure
		plt.savefig("/home/setholinger/Documents/Projects/PIG/particleAnimation/" + stat + "/nonRotated/" + dateString + "_" + hourStr + ":" + minuteStr + "/" + st[chanIdx[0]].stats.channel + "_" + st[chanIdx[1]].stats.channel + "/" + str(n) + ".png")
	
	# clear figure
	plt.clf()
