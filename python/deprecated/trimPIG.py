import obspy
import glob
import numpy as np
import matplotlib.pyplot as plt
import os

startDay = obspy.UTCDateTime("2012-01-01T00:00:00")
endDay = obspy.UTCDateTime("2014-01-01T00:00:00")
numDays = int((endDay-startDay)/86400)
network = "PIG"
networkID = "XC"
stat = "PIG5"

pathSAC = "/home/setholinger/Data/" + network + "/" + stat + "/"
pathRESP = "/home/setholinger/Data/" + network + "/RESP/" 

#create file with all days in time range
days = np.zeros(numDays)
for n in range(numDays):
    days[n] = startDay + n * 86400
    
# get list of all files in current directory
files = glob.glob(pathSAC + "*HHE.M.SAC")
files.sort()

#loop through all files 
for i in range(np.size(files)):
        
    flag = 0
        
    #read in a day of data
    st = obspy.read(files[i])   
    
    #copy data
    st2 = st.copy()
    st3 = st.copy()

    #loop through list of days and 
    for n in range(np.size(days)-1):
       
        if days[n]>st3[0].stats.starttime and days[n+1]<st3[0].stats.endtime and flag == 1:
            
            #trim file
            st3.trim(obspy.UTCDateTime(days[n]),obspy.UTCDateTime(days[n+1]),nearest_sample=False,pad=True,fill_value=0)
            
            #remove instrument response
            pre_filt = [0.05, 0.1, 45, 50]
            seedresp = {'filename': pathRESP + "RESP" + '.' + networkID + '.' + stat + ".." + st3[0].stats.channel, 'units': 'DISP'}
            st3.detrend("demean")
            st3.detrend("linear")
            st3.taper(max_percentage=0.01, max_length=20)
            st3.simulate(paz_remove=None, pre_filt=pre_filt, seedresp=seedresp)
            
            #write new file
            st3.write(pathSAC + str(st3[0].stats.starttime).split("T")[0] + "." + stat + "." + st3[0].stats.channel + ".noIR" + ".SAC", format="SAC")
            
        #if st has data on that day, trim it and write it
        if days[n]>st[0].stats.starttime and days[n+1]<st[0].stats.endtime:
            
            #trim file
            st.trim(obspy.UTCDateTime(days[n]),obspy.UTCDateTime(days[n+1]),nearest_sample=False,pad=True,fill_value=0)
            
            #remove instrument response
            pre_filt = [0.05, 0.1, 45, 50]
            seedresp = {'filename': pathRESP + "RESP" + '.' + networkID + '.' + stat + ".." + st[0].stats.channel, 'units': 'DISP'}
            st.detrend("demean")
            st.detrend("linear")
            st.taper(max_percentage=0.01, max_length=20)
            st.simulate(paz_remove=None, pre_filt=pre_filt, seedresp=seedresp)
            
            #write new file
            st.write(pathSAC + str(st[0].stats.starttime).split("T")[0] + "." + stat + "." + st[0].stats.channel + ".noIR" + ".SAC", format="SAC")
            flag = 1
            
        #if st2 has some data on that day but ends before 23:59:99, merge with next file and then trim
        if days[n]<st2[0].stats.endtime and days[n+1]>st2[0].stats.endtime:
            
            #check for gaps
            st4 = obspy.read(files[i+1])
            if np.abs(st4[0].stats.starttime - st2[0].stats.endtime) < 100:

                #merge next file
                st2 += obspy.read(files[i+1])
                st2.merge()

                #trim file
                st2.trim(obspy.UTCDateTime(days[n]),obspy.UTCDateTime(days[n+1]),nearest_sample=False,pad=True,fill_value=0)

                #remove instrument response
                pre_filt = [0.05, 0.1, 45, 50]
                seedresp = {'filename': pathRESP + "RESP" + '.' + networkID + '.' + stat + ".." + st2[0].stats.channel, 'units': 'DISP'}
                st2.detrend("demean")
                st2.detrend("linear")
                st2.taper(max_percentage=0.01, max_length=20)
                st2.simulate(paz_remove=None, pre_filt=pre_filt, seedresp=seedresp)

                #write new file
                st2.write(pathSAC +  str(st2[0].stats.starttime).split("T")[0] + "." + stat + "." + st2[0].stats.channel + ".noIR" + ".SAC", format="SAC")
        
