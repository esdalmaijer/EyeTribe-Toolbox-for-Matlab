function [success, connection] = eyetribe_init(logfilename)
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

% open new connection
disp('Opening new connection.')
connection = tcpip('localhost', 5666);
fopen(connection);

% send socket initialization message
disp('Sending socket initialization message.')
message = eyetribe_send_command(connection, 'Hi, this is Matlab!');
disp(message)
disp(['Server says: ' message])

% continue if the connection attempt was succesful
if strcmp(message, 'success')
    % send tracker initialization message
    disp('Sending socket initialization message.')
    message = eyetribe_send_command(connection, ['Initialize EyeTribe; logfilename=' logfilename]);
    disp(['Server says: ' message])
    % check success message, and edit return values accordingly
    if strcmp(message, 'success')
        success = 1;
    else
        disp('Failed to initialize EyeTribe object in the Server.')
        success = 0;
        connection = 0;
    end
else
    disp('Failed to initialize connection to the sub-Server.')
    success = 0;
    connection = 0;
end

end

