function [success] = eyetribe_calibrate(connection, window)
%CALIBRATE calibrates the EyeTribe tracker
%   Sends a command to the EyeTribe sub-Server, which will in turn use this
%   command to talk to the actual EyeTribe Server to initialize a
%   caibration. Both the sub-Server and the EyeTribe server will go into
%   calibration mode, and dots will be shown on the display, using
%   PsychToolbox routines. NOTE: to be able to use this function, you need
%   to have PsychToolbox installed. See the PTB website for information:
%   https://psychtoolbox.org/wikka.php?wakka=PsychtoolboxDownload
%
%   Arguments
%   connection -    tcpip object; the tcpip object created by init_eyetribe
%   window     -    windowPtr; reference to an open PsychToolbox window,
%                   resulting from a call to Screen('OpenWindow')
%
%   Returns
%   succes         -    Boolean; 1 on success, 0 on failure

% success starting value
success = 0;

% get screen colours
fgc = BlackIndex(0);

% get screen dimensions
[w, h] = Screen('WindowSize', window);

% Dot Size - a vector that will be looped over when shrinking the dot
dotSize = round([linspace(40, 10, 30), 10 - 5*sin(linspace(0, 4*pi, 45))]);

% point locations
x = [];
y = [];
sp = [0.1 0.5 0.9];
for i = 1:3
    for j = 1:3
        x = [x sp(i)*w];
        y = [y sp(j)*h];
    end
end

% send calibration starting message
disp('Starting calibration.')
message = eyetribe_send_command(connection, 'Calibration start');
disp(['Server says: ' message])

% on success, calibration mode was entered
if strcmp(message, 'success')
    
    % run until aborted or calibrated
    running = 1;
    while running == 1
    
        % % % % %
        % POINTS
        pointorder = randperm(9);
        x = x(pointorder);
        y = y(pointorder);
        % loop through all points in a randomized order
        for i = 1:9
            % check if the abort key was pressed
            [keyIsDown, ~, keyCode, ~] = KbCheck();
            if keyIsDown == 1
                if sum(strcmp(KbName(keyCode), 'q')) > 0
                    % send abort message
                    message = eyetribe_send_command(connection, 'Calibration abort');
                    if strcmp(message, 'success') == 0
                        disp('Failed to abort calibration.')
                    else
                        running = 0;
                        break
                    end
                end
            end
            % draw new point
            
            % move dot linearly
            if i>1
                % if not first point, move from previous point to next point
                speed = round(20 * ( sqrt( (x(1, i-1)-x(1, i))^2 +  (y(1, i-1)-y(1, i))^2)/(0.4*h) ));
                movePoint = [linspace(x(1, i-1), x(1, i), speed); linspace(y(1, i-1), y(1, i), speed)];
            elseif i == 1;
                % if first point, move from the very last point to first
                % point
                speed = round(20 * ( sqrt( (x(1, end)-x(1, 1))^2 +  (y(1, end)-y(1, 1))^2)/(0.4*h)));
                movePoint = [linspace(x(1, end), x(1, 1), speed); linspace(y(1, end), y(1, 1), speed)];
            end
            for ii = 1:speed
                Screen('FillOval', window, fgc, [movePoint(1, ii)-dotSize(1)/2, movePoint(2, ii)-dotSize(1)/2, movePoint(1, ii)+dotSize(1)/2, movePoint(2, ii)+dotSize(1)/2]);
                Screen('Flip', window);
            end
            
            % shrink dot linearly (+ sinusoid wobble)
            for ii = 1:numel(dotSize);
                Screen('FillOval', window, fgc, [x(1, i)-dotSize(ii)/2, y(1, i)-dotSize(ii)/2, x(1, i)+dotSize(ii)/2, y(1, i)+dotSize(ii)/2]);
                Screen('Flip', window);
            end
            
            Screen('FillOval', window, fgc, [x(i)-dotSize(end)/2 y(i)-dotSize(end)/2 x(i)+dotSize(end)/2 y(i)+dotSize(end)/2]);
            Screen('Flip', window);
            % pause for a bit (to allow a saccade to land on the new point)
            pause(1);
            % send point start message
            message = eyetribe_send_command(connection, ['Calibration pointstart;x=' num2str(x(i)) ',y=' num2str(y(i))]);
            if strcmp(message, 'success') == 0
                disp('Failed to start new point.')
            end
            % wait for a bit
            pause(1);
            % send point end message
            message = eyetribe_send_command(connection, 'Calibration pointend');
            if strcmp(message, 'success') == 0
                disp('Failed to end point.')
            end
        end

        
        % % % % %
        % RESULT
        
        % get results
        if running == 0
            % calibration was aborted
            resulttext = 'Calibration was aborted. (a = accept; r = retry)';
            % dummy results
            result = zeros(4,9);
        else
            % calibration finished
            resulttext = 'Calibration was succesful. (a = accept; r = retry)';
            % get result message
            message = eyetribe_send_command(connection, 'Calibration result');
            if strcmp(message(1:7), 'success') == 0
                resulttext = 'Failed to obtain results. (a = accept; r = retry)';
                disp('Failed to obtain results.')
                result = zeros(4,9);
            else
                eval(['result = ' message(9:length(message)) ';']);
            end
        end

        % show result
        if sum(result) > 0
            for i = 1:9
                % calibration state for this point
                state = result(1,i); % 1 for good, 0 for not calibrated
                % precision
                error = result(2,i); % precision
                % calibration point location
                actx = result(3,i); % horizontal position of calibration point
                acty = result(4,i); % vertical position of calibration point
                % accuracy
                estx = result(5,i); % estimated horizontal position of calibration point
                esty = result(6,i); % estimated vertical position of calibration point
                % only draw if the state was not 0
                if state > 0
                    % draw error margin
                    Screen('FillOval', window, [252 233 79], [round(actx-error/2) round(acty-error/2) round(actx+error/2) round(acty+error/2)]);
                    % draw actual point on Screen
                    Screen('FillOval', window, [115 210 22], [round(actx-5) round(acty-5) round(actx+5) round(acty+5)]);
                    % draw estimated point on Screen
                    Screen('FillOval', window, [32 74 135], [round(estx-5) round(esty-5) round(estx+5) round(esty+5)]);
                end
            end
        end
        % draw text on Screen
        Screen('DrawText', window, resulttext, round(w/2), round(h/4), fgc);
        % show results!
        Screen('Flip', window);
        
        % wait for keypress
        pressed = 0;
        while pressed == 0
            % wait for a keypress
            [~, keyCode, ~] = KbWait();
            % 'q' - quit key
            if sum(strcmp(KbName(keyCode), 'a')) > 0
                % key is pressed, stop calibration
                running = 0;
                pressed = 1;
                restart = 0;
            % 'r' - redo key
            elseif  sum(strcmp(KbName(keyCode), 'r')) > 0
                % key is pressed
                pressed = 1;
                restart = 1;
            end
        end
        
        % calibration ending message
        message = eyetribe_send_command(connection, 'Calibration finished');
        if strcmp(message, 'success') == 0
            disp('Failed to exit calibration mode.')
        else
            % set success to True
            success = 1;
        end
        % restart if needed
        if restart
            success = 0;
            message = eyetribe_send_command(connection, 'Calibration start');
            if strcmp(message, 'success') == 0
                disp('Failed restart calibration mode.')
            end            
        end
    end

% failed to enter calibration mode
else
    disp('Failed to enter calibration mode.')
end

end

