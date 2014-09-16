function [success] = eyetribe_close(connection)
%INIT initializes connection with EyeTribe Server
%   Starts a client connection to the EyeTribe sub-server, which will in
%   turn start a connection to the actual EyeTribe Server (it's a bit of
%   a complicated procedure, to get around Matlab's lack of proper
%   multithreading functionality).
%
%   Arguments
%   logfilename    -    string; log file name, optionally with path, but
%                       without extenstion (e.g. 'test')
%
%   Returns
%   succes         -    Boolean; 1 on success, 0 on failure
%   connection     -    tcpip object on success, 0 on failure

% send socket closing message
disp('Closing connection.')
message = eyetribe_send_command(connection, 'Close');
disp(['Server says: ' message])

% continue if the closing attempt was succesful
if strcmp(message, 'success')
    % wait for the closing message
    message = 0;
    while message == 0
        if connection.BytesAvailable > 0
            message = char(fread(connection, connection.BytesAvailable)');
        end
    end
    % check success message, and edit return values accordingly
    if strcmp(message, 'Closing connection.')
        disp(['Server says: ' message])
        fclose(connection);
        disp('Connection closed.')
        success = 1;
    else
        disp('Failed to close connection to the sub-Server.')
        success = 0;
    end
else
    disp('Failed to close connection between the sub-Server and the EyeTribe Server.')
    success = 0;
end

end

