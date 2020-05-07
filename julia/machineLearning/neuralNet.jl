# using data from PIG2 and PIG4 on 10-20 Hz band
# run staLta detections to get training dataset
detections = stalta("/media/Data/Data/PIG/SAC/noIR/",["PIG1","PIG2","PIG3","PIG4","PIG5"],["HHZ","HHN","HHE"],100,60.,1.,6.,10.,"Highpass",[10.],4)

# retrieve waveforms for training set
getTrainingData("/home/setholinger/Documents/Projects/PIG/detections/staLta/>10Hz/conservative/detections.txt",
"/media/Data/Data/PIG/SAC/noIR/",["PIG2","PIG4"], ["HHZ","HHN","HHE"],"2012-01-01","2014-01-01",
"Bandpass",[10.,20.],4,2,8,"/home/setholinger/Documents/Code/machineLearning/10-20Hz/trainingData.h5")

# make training noise
getTrainingNoise(100000,2,3,1000,100,[10,20],4,"/home/setholinger/Documents/Code/machineLearning/10-20Hz/trainingData.h5")

# get data to manually test network if desired
getTestData("fileList.txt","Bandpass",[10.,20.],4,"PIG24/PIG24_2013-06-03.h5")
getTestData("fileList.txt","Bandpass",[10.,20.],4,"PIG24/PIG24_2013-06-24.h5")

# train and save neural network
# RIGHT NOW, USE ICENET ON GOOGLE COLABS

# load neural network and run on data (set parameters in script)
# freq = [10,20]
# FIRST RUN: gap = 5
# SECOND RUN: gap = 2
python runModel.py




# using data from PIG2 and PIG4 on 10-20 Hz band
# run staLta detections to get training dataset
detections = stalta("/media/Data/Data/PIG/SAC/noIR/",["PIG1","PIG2","PIG3","PIG4","PIG5"],["HHZ","HHN","HHE"],100,60.,1.,6.,10.,"Highpass",[10.],4)

# retrieve waveforms for training set
getTrainingData("/home/setholinger/Documents/Projects/PIG/detections/staLta/>10Hz/conservative/detections.txt",
"/media/Data/Data/PIG/SAC/noIR/",["PIG2","PIG4"], ["HHZ","HHN","HHE"],"2012-01-01","2014-01-01",
"Bandpass",[10.,20.],4,1,1,"/home/setholinger/Documents/Code/machineLearning/10-20Hz/testTrainingData.h5")

# make training noise
getTrainingNoise(100000,2,3,200,100,[10,20],4,"/home/setholinger/Documents/Code/machineLearning/10-20Hz/noDownsample/2SecWin/trainingData.h5")




# using data from PIG2 and PIG4 on 1-10 Hz band
# run staLta detections to get training dataset
detections = stalta("/media/Data/Data/PIG/SAC/noIR/",["PIG1","PIG2","PIG3","PIG4","PIG5"],["HHZ","HHN","HHE"],100,60.,5.,3,10.,"Bandpass",[1.,10.],4)

# only use detections with 4 stations

# retrieve waveforms for training set
getTrainingData("/home/setholinger/Documents/Projects/PIG/detections/staLta/1-10Hz/detections4stations.txt",
"/media/Data/Data/PIG/SAC/noIR/",["PIG2","PIG4"], ["HHZ","HHN","HHE"],"2012-01-01","2014-01-01",
"Bandpass",[1.,10.],4,5,15,"/home/setholinger/Documents/Code/machineLearning/1-10Hz/downsample/trainingData.h5")

# make training noise
getTrainingNoise(200000,2,3,400,100,[1,10],4,"/home/setholinger/Documents/Code/machineLearning/1-10Hz/downsample/trainingData.h5")

# get data to manually test network if desired
getTestData("fileList.txt","Bandpass",[1.,10.],4,"/home/setholinger/Documents/Code/machineLearning/1-10Hz/downsample/testData/2013-06-03.h5")
getTestData("fileList.txt","Bandpass",[1.,10.],4,"/home/setholinger/Documents/Code/machineLearning/1-10Hz/downsample/testData/2013-06-24.h5")
