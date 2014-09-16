EyeTribe Toolbox for Matlab
===========================

version 0.0.1 (16-Sep-2014)


ABOUT
-----

The EyeTribe Toolbox for Matlab is a set of functions that can be used
to communicate with eye trackers manufactured by [the EyeTribe](https://theeyetribe.com/). The
communication process is not direct, but goes via a sub-server that
receives input from Matlab (when the functions from this toolbox are
called), and then sends commands to the actual EyeTribe server.

This setup is rather odd, but it is the most elegant solution that I
could come up with to get around the problem of Matlab not having
decent multithreading functionality. This functionality is required
for running a heartbeat Thread (which keeps the connection with the
EyeTribe alive), and another Thread to monitor samples (and write these
to a log file). Similar results might be obtained by using callback
functions within Matlab's TCP/IP framework, but that approach causes
timing errors that extent into other domains: timing issues when
using PsychToolbox's `WaitSecs` function, and background processes
in Matlab screwing up all sorts of other timing sensitive processes.

So, out of lazine... Err... Out of a well-planned timing management
effort to avoid time loss by re-inventing the wheel, I simply used
[PyTribe](https://github.com/esdalmaijer/PyTribe) in a short Python script (see the `python_source` folder for
the source) to compile a Windows executable, which should be run
before you run your Matlab script. Currently, the toolbox does not
have it's own calibration routine yet, but this will be implemented
shortly using the [PsychToolbox](https://psychtoolbox.org/HomePage).


USAGE
-----

1. Start EyeTribe Server
	`C:\Program Files(x86)\EyeTribe\Server\EyeTribe.exe`

2. Start EyeTribe UI
	`C:\Program Files(x86)\EyeTribe\Client\EyeTribeWinUI.exe`

3. Press the Calibrate button to calibrate the system.

4. Start `EyeTribe_Matlab_server.exe`.

5. Run your Matlab script, e.g. the one below:

~~~ .matlab
% initialize connection
[success, connection] = eyetribe_init('test');

% start recording
success = eyetribe_start_recording(connection);

% log something
success = eyetribe_log(connection, 'TEST_START');

% get a few samples
for i = 1:60
    pause(0.0334)
    [succes, x, y] = eyetribe_sample(connection);
    [succes, size] = eyetribe_pupil_size(connection);
    disp(['x=' num2str(x) ', y=' num2str(y) ', s=' num2str(size)])
end

% log something
success = eyetribe_log(connection, 'TEST_STOP');

% stop recording
success = eyetribe_stop_recording(connection);

% close connection
succes = eyetribe_close(connection);
~~~

