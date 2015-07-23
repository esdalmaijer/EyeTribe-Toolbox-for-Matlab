% EyeTribe Toolbox for Matlab testing script
%
% author: Edwin Dalmaijer
% email: edwin.dalmaijer@psy.ox.ac.uk
%
% version 1 (16-Sep-2014)

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
    [succes, x, y] = eyetribe_sample(connection);
    [succes, size] = eyetribe_pupil_size(connection);
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