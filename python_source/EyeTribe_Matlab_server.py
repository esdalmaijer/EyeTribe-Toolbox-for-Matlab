# native
import time
import socket

# external
from pytribe import EyeTribe


# # # # #
# CONSTANTS

DEBUG = False

MLIP = 'localhost'
MLPORT = 5666


# # # # #
# INIT CONNECTION

# start socket connection
print("Starting new socket connection (ip=%s, port=%d)." % (MLIP, MLPORT))
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((MLIP,MLPORT))

# set server timeout to two minutes
sock.settimeout(120)

# start listening for new connections (max = 10)
print("Listening for connections...")
sock.listen(10)

# wait for the connection to be made
matlabconnected = False
while not matlabconnected:
	# accept any new connection
	try:
		conn, addr = sock.accept()
	except socket.timeout:
		sock.close()
		raise Exception("ERROR: socket timed out, no connections available.")
	print("Found new connection (%s, %d)" % (addr[0], addr[1]))
	# set the timeout for this connection to 10 seconds
	conn.settimeout(10)
	# see whether the new connection is Matlab
	try:
		message = conn.recv(1024)
		print("Client says: %s" % message)
	except socket.timeout:
		print("Timeout while listening to (%s, %d)." % (addr[0], addr[1]))
		message = None
	if message == "Hi, this is Matlab!":
		matlabconnected = True
# return success message
conn.send('success')


# # # # #
# RUN EYETRIBE

# run until the stop command is received
tracker = None
stopped = False
while not stopped:
	
	# READ INCOMING MESSAGES
	try:
		message = conn.recv(1024)
		if DEBUG:
			print("Client says: %s" % message)
	except socket.timeout:
		message = ''

	# INIT
	if "Initialize EyeTribe" in message:
		# get the file name
		try:
			# (message: "Initialize EyeTribe; logfilename=%s")
			logfilename = message[message.find('logfilename=')+12:]
		except:
			print("WARNING in Initialize EyeTribe: invalid logfilename, using default")
			logfilename = None
		# initialize the EyeTribe
		try:
			tracker = EyeTribe(logfilename=logfilename)
			conn.send('success')
		except:
			print("ERROR in Initialize EyeTribe: could not initialize new EyeTribe object.")
			conn.send("ERROR in Initialize EyeTribe: could not initialize new EyeTribe object.")

	# CALIBRATE
#	elif message == "Calibrate":
	
	# START RECORDING
	elif message == 'Start recording':
		if tracker == None:
			print('ERROR in Start recording: tracker was not initialized.')
			conn.send('ERROR in Start recording: tracker was not initialized.')
		else:
			try:
				tracker.start_recording()
				conn.send('success')
			except:
				print("Error in Start recording: failed to start recording.")
				conn.send("Error in Start recording: failed to start recording.")
	
	# STOP RECORDING
	elif message == 'Stop recording':
		if tracker == None:
			print('ERROR in Stop recording: tracker was not initialized.')
			conn.send('ERROR in Stop recording: tracker was not initialized.')
		else:
			try:
				tracker.stop_recording()
				conn.send('success')
			except:
				print("Error in Stop recording: failed to stop recording.")
				conn.send("Error in Stop recording: failed to stop recording.")
	
	# LOG
	elif "Log; message=" in message:
		if tracker == None:
			print('ERROR in Log: tracker was not initialized.')
			conn.send('ERROR in Log: tracker was not initialized.')
		else:
			# parse message
			try:
				msg = message[message.find('message=')+8:]
			except:
				print("WARNING in Log: could not parse message '%s'" % message)
			# log message
			try:
				tracker.log_message(msg)
				conn.send('success')
			except:
				print("Error in Log: failed to log '%s'." % msg)
				conn.send("Error in Log: failed to log '%s'." % msg)

	
	# SAMPLE
	elif message == "Sample":
		if tracker == None:
			print('ERROR in Sample: tracker was not initialized.')
			conn.send('ERROR in Sample: tracker was not initialized.')
		else:
			# get sample
			try:
				x, y = tracker.sample()
			except:
				x = y = -999
				print("ERROR in Sample: failed to obtain sample")
			# remove potential None
			if x == None:
				x = -999
			if y == None:
				y = -999
			# send message
			conn.send("success;x=%d,y=%d" % (x,y))
	
	# PUPIL SAMPLE
	elif message == "Pupil size":
		if tracker == None:
			print('ERROR in Pupil size: tracker was not initialized.')
			conn.send('ERROR in Pupil size: tracker was not initialized.')
		else:
			# get sample
			try:
				size = tracker.pupil_size()
			except:
				size = -999
				print("ERROR in Pupil size: failed to obtain sample")
			# remove potential None
			if size == None:
				x = -999
			# send message
			conn.send("success;s=%d" % (size))
	
	# CLOSE
	elif message == 'Close':
		if tracker == None:
			print('ERROR in Close: tracker was not initialized.')
			conn.send('ERROR in Close: tracker was not initialized.')
		else:
			try:
				tracker.close()
				conn.send('success')
				stopped = True
			except:
				print("ERROR in Close: failed to close connection.")
				conn.send("ERROR in Close: failed to close connection.")

# short pause
time.sleep(0.5)


# # # # #
# CLOSE CONNECTION

# send closing message
print("Closing connection.")
conn.send("Closing connection.")

# wait for a bit
time.sleep(0.5)

# close connections
conn.close()
sock.close()
