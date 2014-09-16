function [message] = eyetribe_send_command(connection, command)
%SEND_COMMAND sends a command to the EyeTribe and waits for a reply
%   Sends a command to the EyeTribe sub-Server, which will in turn use this
%   command to talk to the actual EyeTribe Server. Returns string with the
%   reply from the EyeTribe sub-Sever
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%   command    -    string; tell the EyeTribe sub-Server what to do
%
%   Returns
%   message    -    string; tells you what the outcome is ('success' on a
%                   successful attempt at performing the command, or an
%                   error on a failed attempt)

% send command
fwrite(connection, command);

% keep reading
message = 0;
while message == 0
    if connection.BytesAvailable > 0
        message = char(fread(connection, connection.BytesAvailable)');
    end
end

end

