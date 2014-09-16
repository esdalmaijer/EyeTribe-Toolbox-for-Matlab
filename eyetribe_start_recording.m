function [success] = eyetribe_start_recording(connection)
%START_RECORDING starts data logging
%   Asks the sub-Server to start logging data to the log file, which will
%   then proceed to write samples obtained from the actual EyeTribe Server
%   to disk.
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%
%   Returns
%   succes         -    Boolean; 1 on success, 0 on failure

% send start_recording message
message = eyetribe_send_command(connection, 'Start recording');

% handle response
if strcmp(message, 'success')
    success = 1;
else
    disp('Failed to start recording.')
    disp(['Server says: ' message])
    success = 0;
end

end

