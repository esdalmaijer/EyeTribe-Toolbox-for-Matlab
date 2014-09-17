function [success, x, y] = eyetribe_sample(connection)
%SAMPLE obtains a [x,y] sample from the EyeTribe
%   Asks the sub-Server for a sample, which proceeds to ask the EyeTribe
%   Server for a sample. If the sample is invalid, (-999,-999) is returned.
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%
%   Returns
%   succes         -    Boolean; 1 on success, 0 on failure
%   x              -    int; horizontal gaze position
%   y              -    int; vertical gaze position

% send Sample message
message = eyetribe_send_command(connection, 'Sample');

% continue if the sample request was successful
if strcmp(message(1:7), 'success')
    % find x position in string
    xpos = strfind(message, 'x=');
    % find y position in string
    ypos = strfind(message, 'y=');
    % get x position
    x = str2double(message(xpos+2:ypos-1));
    % get y position
    y = str2double(message(ypos+2:length(message)));
    % set success value to True
    success = 1;
else
    disp('Failed to obtain sample.')
    x = -999;
    y = -999;
    success = 0;
end

end

