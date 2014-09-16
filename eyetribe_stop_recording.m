function [success] = eyetribe_stop_recording(connection)
%STOP_RECORDING pauses data logging
%   Asks the sub-Server to stop logging data to the log file, which will
%   then proceed to stop writing samples obtained from the actual EyeTribe
%   Server to disk.
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%
%   Returns
%   succes         -    Boolean; 1 on success, 0 on failure

% send stop_recording message
message = eyetribe_send_command(connection, 'Stop recording');

% handle response
if strcmp(message, 'success')
    success = 1;
else
    disp('Failed to stop recording.')
    disp(['Server says: ' message])
    success = 0;
end

end

