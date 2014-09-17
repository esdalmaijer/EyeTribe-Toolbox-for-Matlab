function [success, size] = eyetribe_pupil_size(connection)
%PUPIL_SIZE obtains a pupil size sample from the EyeTribe
%   Asks the sub-Server for a sample, which proceeds to ask the EyeTribe
%   Server for a sample. If the sample is invalid, -999 is returned.
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%
%   Returns
%   succes         -    Boolean; 1 on success, 0 on failure
%   size           -    int; horizontal gaze position

% send pupil size message
message = eyetribe_send_command(connection, 'Pupil size');

% continue if the sample request was successful
if strcmp(message(1:7), 'success')
    % find pupil size position
    spos = strfind(message, 's=');
    % get size
    size = str2double(message(spos+2:length(message)));
    % set success value to True
    success = 1;
else
    disp('Failed to obtain sample.')
    size = -999;
    success = 0;
end

end

