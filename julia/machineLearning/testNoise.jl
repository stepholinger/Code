using DSP
using Statistics
using Plots
using Random

# set some parameters
signalLength = 1000
bufferLength = 100
numSignals = 1000

# make matrix of random numbers and demean
noiseMat = rand(signalLength + 2*bufferLength,numSignals) .- 0.5

# define filter parameters
fs = 100
freq = [10,20]
corners = 4
responsetype = Bandpass(freq[1], freq[2]; fs=fs)
designmethod = Butterworth(corners)

# make a blank arrays to store filtered noise and FFT results
filtNoiseMat = zeros(signalLength + 2*bufferLength,numSignals)
trimFiltNoiseMat = zeros(signalLength,numSignals)
fMat = zeros(signalLength,numSignals)

for n = 1:numAverage

    # filter the noise
    filtNoiseMat[:,n] = filt(digitalfilter(responsetype, designmethod), noiseMat[:,n])

    # remove the buffer on either side
    trimFiltNoiseMat[:,n] = filtNoiseMat[1 + bufferLength:end-bufferLength,n]

    # take fft of the noise
    F = DSP.fft(trimFiltNoiseMat[:,n]) |> DSP.fftshift
    fMat[:,n] = abs.(F)

end

# average the spectra
fMatMean = Statistics.mean(fMat,dims = 2)

# get frequency axis labels
freqs = DSP.fftfreq(signalLength,fs) |> DSP.fftshift

# plot the spectra of the averaged, filtered noise
plot(freqs[Int(signalLength/2):Int(signalLength)],fMatMean[Int(signalLength/2):Int(signalLength)])
