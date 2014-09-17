function [success] = eyetribe_log(connection, msg)
%LOG_MESSAGE logs a message to the EyeTribe data file
%   Asks the sub-Server to write a message in the log file, which will
%   then proceed to write a message to the log file.
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%   msg        -    string; message to be logged to the data file
%
%   Returns
%   succes     -    Boolean; 1 on success, 0 on failure

% send log message
message = eyetribe_send_command(connection, ['Log; message=' msg]);

% handle response
if strcmp(message, 'success')
    success = 1;
else
    disp('Failed to log message.')
    disp(['Server says: ' message])
    success = 0;
end

end

