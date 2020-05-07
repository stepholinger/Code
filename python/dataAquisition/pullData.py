import obspy
from obspy.clients.fdsn.mass_downloader import RectangularDomain, Restrictions, MassDownloader

domain = RectangularDomain(minlatitude=-90, maxlatitude=90, minlongitude=-180, maxlongitude=180.0)

restrictions = Restrictions(
	starttime=obspy.UTCDateTime(2012, 1, 1),
	endtime=obspy.UTCDateTime(2014, 1, 1),
	chunklength_in_sec=86400,
	network="YT", station="UPTW,DNTW,BEAR,THUR", location="", channel="BH*",
	location_priorities = ["01",],
	channel_priorities = ["BHZ","BHN","BHE"],
	reject_channels_with_gaps=False,
	minimum_length=0.0)

mseed_storage=("/media/Data/Data/YT/MSEED/raw/")

mdl = MassDownloader(providers=["IRIS"])

mdl.download(
	domain=domain,
	restrictions=restrictions, 
	mseed_storage=mseed_storage, 
	stationxml_storage=("/media/Data/Data/YT/XML/"))

