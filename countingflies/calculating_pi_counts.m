%% Calculate PI from an olfactory arena experiment
clear

% Select spreadsheet containing experiment names
cd('C:\Behavior_Experiments\Data_Lists') % Change directory to folder containing experiment lists
[FileName, PathName] = uigetfile('*', 'Select spreadsheet containing experiment names', 'off');

[~, expts, ~] = xlsread([PathName, FileName]);
acquisition_rate = 30; % Acquisition rate (in Hz)
all_pi = [];

% Select the range of frames over which to calculate an average PI value
startframe_pi = 2400; % Frame number at which PI calculation starts
endframe_pi = 4500; % Frame number at which PI calculation ends

%% Load flycounts for each arena & CS+
for expt_n = 1:length(expts)
    expt_name = expts{expt_n, 1};
    cd(expt_name)
    trials = dir(expt_name);
    
    for trial_n = 1:length(trials)
        % Skip the folders containing '.'
        if startsWith(trials(trial_n).name, '.')
            continue
        end

        % Change directory to file containing flycounts 
        trial = strcat(expt_name, '\', trials(trial_n).name);
        cd(trial)
        load('flycounts.mat')
        
        if exist('allflycounts') == 0 %#ok<EXIST>
           allflycounts = NaN(length(n_flies), 4, 2);
        end
        
        % Create indicator for CS+
        OCT = strfind(trials(trial_n).name,'OCT');

        % Create indicator for arena number
        cam0 = strfind(trials(trial_n).name,'_Cam0');
        
        % Classify and store flycounts
        if ~isempty(cam0) % cam0
            if ~isempty(OCT) % oct
                allflycounts(:, 1, :) = n_flies(1:length(allflycounts), :);
            else % mch
                allflycounts(:, 3, :) = n_flies(1:length(allflycounts), :);
            end
        else % cam1
            if ~isempty(OCT) % oct
                allflycounts(:, 2, :) = n_flies(1:length(allflycounts), :);
            else % mch
                allflycounts(:, 4, :) = n_flies(1:length(allflycounts), :);
            end
        end      
    end
    
    %% Convert indices to time
    % Convert the indices for each measurement to time using the acquisition rate (30 Hz)
    frames = 1:size(allflycounts, 1);
    time = frames/acquisition_rate;
    time = permute(time, [2, 1]); % Time (in s)
    
    %% Plot individual fly counts
    x = [30 30 150 150];
    y = [-2 -1 -1 -2]; 

    figure
    subplot(2, 2, 1)
    plot(time, squeeze(allflycounts(:, 1, 1)),... % Specify trace by value for each dimension
            time, squeeze(allflycounts(:, 1, 2)))
    patch(x, y, 'black')
    xlim([0, 180])
    ylim([-3, 20])
    xlabel('Time (s)')
    ylabel('Fly counts')

    subplot(2, 2, 2)
    plot(time, squeeze(allflycounts(:, 2, 1)),... % Specify trace by value for each dimension
            time, squeeze(allflycounts(:, 2, 2)))
    patch(x, y, 'black')
    xlim([0, 180])
    ylim([-3, 20])
    xlabel('Time (s)')
    ylabel('Fly counts')

    subplot(2, 2, 3)
    plot(time, squeeze(allflycounts(:, 3, 1)),... % Specify trace by value for each dimension
            time, squeeze(allflycounts(:, 3, 2)))
    patch(x, y, 'black')
    xlim([0, 180])
    ylim([-3, 20])
    xlabel('Time (s)')
    ylabel('Fly counts')
    
    subplot(2, 2, 4)
    plot(time, squeeze(allflycounts(:, 4, 1)),... % Specify trace by value for each dimension
            time, squeeze(allflycounts(:, 4, 2)))
    patch(x, y, 'black')
    xlim([0, 180])
    ylim([-3, 20])
    xlabel('Time (s)')
    ylabel('Fly counts')
    
    %% Calculate an average PI
    % Average the paired & unapaired odor trials for the first camera
    cam0p = cat(2, allflycounts(:, 1, 2), allflycounts(:, 3, 1));
    cam0p = mean(cam0p, 2);

    cam0u = cat(2, allflycounts(:, 1, 1), allflycounts(:, 3, 2));
    cam0u = mean(cam0u, 2);

    expt_pi = (cam0p - cam0u)./(cam0p + cam0u);
    all_pi = cat(2, all_pi, expt_pi);

    % Average the paired & unpaired odor trials for the second camera
    cam1p = cat(2, allflycounts(:, 2, 1), allflycounts(:, 4, 2));
    cam1p = mean(cam1p, 2);

    cam1u = cat(2, allflycounts(:, 2, 2), allflycounts(:, 4, 1));
    cam1u = mean(cam1u, 2);

    expt_pi = cat(2, expt_pi, ((cam1p - cam1u)./(cam1p + cam1u)));
    all_pi = cat(2, all_pi, ((cam1p - cam1u)./(cam1p + cam1u)));
    expt_pi = mean(expt_pi, 2);

    x = [30 30 150 150];
    y = [-0.42 -.4 -0.4 -0.42];
    
    figure
    plot(time, expt_pi)
    patch(x, y, 'black')
    xlim([0, 180])
    ylim([-0.45, 0.9])
    xlabel('Time (s)')
    ylabel('Average PI')
    title('Average PI for experiment')
end

%% Plot average PI across experiments
avg_pi = mean(all_pi, 2);
figure
plot(time, avg_pi)
patch(x, y, 'black')
xlim([0, 180])
ylim([-0.45, 0.9])
xlabel('Time (s)')
ylabel('Average PI')
title('Average PI')

%% Calculate average PI value
pi = mean(all_pi(startframe_pi:endframe_pi, :), 1);
sd = std(pi);
pi = mean(pi, 2);
n = size(all_pi, 2);

disp(pi)
disp(sd)
disp(n)