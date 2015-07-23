EyeTribe Toolbox for Matlab
===========================

version 0.0.3 (03-Jun-2015)


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
before you run your Matlab script.

The calibration routine is based on the [PsychToolbox](https://psychtoolbox.org/HomePage) for Matlab,
and requires an active window to be passed to it. This assures that
you are free to calibrate the tracker at any given moment in your
experiment, without having any external calibration routine battle
with your experiment for control of the active display.

If you do not want to calibrate using the PsychToolbox, you can still
use the EyeTribe Toolbox for Matlab, by simply NOT calling the
`eyetribe_calibrate` function. Please do note that you should then
calibrate the system with your own means, e.g. by using the EyeTribe's
own GUI (`C:\Program Files (x86)\EyeTribe\Client\EyeTribeWinUI.exe`)
*before* starting any software that calls upon the EyeTribe Toolbox
for Matlab.

IMPORTANT
---------

A very common assumption among people using the EyeTribe for Matlab
Toolbox is that calling the sample function is a requirement. This is
**not** true! After calling `eyetribe_start_recording` the executable
(*EyeTribe_Matlab_server.exe*) will make sure that data will be written
to the log file. Calling `eyetribe_stop_recording` will halt data
logging. The `eyetribe_sample` and `eyetribe_pupil_size` functions have
nothing to do with data recording!

So why are they there? Well, sometimes you want to use participant's
point of regard to change something on-screen or to give feedback. To
this end, you can call `eyetribe_sample` to get the most recent gaze
coordinates. These can be used to set the location of a stimulus (e.g.
to lock it to gaze position), or to monitor whether a participants is
looking at a certain stimulus.

In sum, the `eyetribe_sample` and `eyetribe_pupil_size` functions are
there to support gaze-contingent displays. They are **not** related to
the recording of data: the executable running in the background will
handle this in the background, storing gaze and pupil data in a text
file.

DOWNLOAD
--------

1) Go to: [https://github.com/esdalmaijer/EyeTribe-Toolbox-for-Matlab](https://github.com/esdalmaijer/EyeTribe-Toolbox-for-Matlab)

2) Press the Download ZIP button, or click this [direct link](https://github.com/esdalmaijer/EyeTribe-Toolbox-for-Matlab/archive/master.zip).

3) Extract the ZIP archive you just downloaded.

4) Copy the folder `EyeTribe_for_Matlab` to where you want it to be
(e.g. in your *Documents* folder, under *MATLAB*).

5) In Matlab, go to *File -> Set Path -> Add folder* and select
the folder you copied at step 4.

Alternatively, place the following code at the start of your experiment:

~~~ .matlab
% assuming you placed the EyeTribe_for_Matlab directly under C:
addpath('C:\EyeTribe_for_Matlab')
~~~


USAGE ON WINDOWS
----------------

1. Start EyeTribe Server
	`C:\Program Files(x86)\EyeTribe\Server\EyeTribe.exe`

2. Start `EyeTribe_Matlab_server.exe`.

3. Run your Matlab script, e.g. the one below:

USAGE ON OS X AND LINUX
-----------------------

Thanks to [@shandelman116](https://github.com/shandelman116) for trying this out (see [issue #4](https://github.com/esdalmaijer/EyeTribe-Toolbox-for-Matlab/issues/4)).

1. Open a Terminal.
2. Use the `cd` function to go to the python_source folder. An example:
~~~
cd /home/python_source
~~~
3. Use Python to run the source. Python should be installed on any Linux system, and I think OS X usually comes with it as well. Type the following command in the Terminal:
~~~
python EyeTribe_Matlab_server.py
~~~
4. Now run your Matlab script (but do it within two minutes of starting the Python script, because it will time out after that).

EXAMPLE SCRIPT
--------------

~~~ .matlab
% don't bother with vsync tests for this demo
Screen('Preference', 'SkipSyncTests', 1);

% initialize connection
[success, connection] = eyetribe_init('test');

% open a new window
window = Screen('OpenWindow', 2);

% calibrate the tracker
success = eyetribe_calibrate(connection, window);

% show blank window
Screen('Flip', window);

% start recording
success = eyetribe_start_recording(connection);

% log something
success = eyetribe_log(connection, 'TEST_START');

% get a few samples
% NOTE: this is NOT necessary for data recording and
% collection, but just a demonstration of the sample
% and pupil_size functions!
for i = 1:60
    pause(0.0334)
    [success, x, y] = eyetribe_sample(connection);
    [success, size] = eyetribe_pupil_size(connection);
    disp(['x=' num2str(x) ', y=' num2str(y) ', s=' num2str(size)])
end

% log something
success = eyetribe_log(connection, 'TEST_STOP');

% stop recording
success = eyetribe_stop_recording(connection);

% close connection
success = eyetribe_close(connection);

% close window
Screen('Close', window);
~~~

