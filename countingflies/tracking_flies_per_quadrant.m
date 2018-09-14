%% Track the number of flies per quadrant per frame
% Reset everything
clear

%% Set all parameters
data_dir = cd('C:\Behavior_Experiments\Data'); % Folder containing olfactory arena videos
mask_dir = 'C:\Matlab_Scripts\trackingbehavior\countingflies'; % Folder containing olfactory arena masks

chunk_size = 600; % Number of frames loaded into memory at a time
min_area = 50; % Minimum area of a fly (in pixels)
acquisition_rate = 30; % Acquisition rate (in Hz)
[~, mat_file_list] = system('dir /S/B *test_test*.'); % List all folders containing "test_test"
mat_file_list = textscan(mat_file_list, '%s', 'Delimiter', '\n'); % List of all experiment files made by recursively scanning all subdirectories of data_dir
mat_file_list = mat_file_list{1, 1};

%% Analyze all of the behavior arena videos
for folder_n = 1:length(mat_file_list)
    % Change directory to file containing output from video analysis
    expt = mat_file_list{folder_n, 1};
    analyzed_file = [expt, '\', 'analyzed.txt'];
    error = strfind(expt, 'error');
    
    if ~isempty(error) % Skip if experiment is located in an error folder
        continue
    else
        cd(expt)
    end
    
    video = dir('movie_Test*.ufmf'); % Find file containing test video
    analysis_dir = replace(expt, 'Data', 'Analysis'); % Create a name for the analyzed video directory
    
    if (size(video, 1) == 0) || (exist(analyzed_file, 'file') ~= 0)  % Skip if folder does not contain a test file or if folder contains analyzed tag
        continue
    end
    
    disp(expt)
    
    header = ufmf_read_header(video(1).name); % Read the header for the test video 
    n_frames = header.nframes - rem(header.nframes, acquisition_rate); % Round the number of frames to the nearest second
    n_flies = NaN(n_frames, 2); % Create a matrix for the number of flies per set of quadrants per frame
    
    % Determine which camera was used to record the video
    if strfind(header.filename, 'cam_0') > 0
        masks = load([mask_dir, '\', 'masks', '\', 'cam0_quad_dilated.mat']); % Load the quadrant masks for cam0
        masks = masks.dilated_quad;
        mask_borders = load([mask_dir, '\', 'masks', '\', 'cam0_border.mat']); % Load a border around the arena for cam0
        mask_borders = mask_borders.borders;
    else
        masks = load([mask_dir, '\', 'masks', '\', 'cam1_quad_dilated.mat']); % Load the quadrant masks for cam1
        masks = masks.dilated_quad;
        mask_borders = load([mask_dir, '\', 'masks', '\', 'cam1_border.mat']); % Load a border around the arena for cam1
        mask_borders = mask_borders.borders;
    end
    
    % Load a chunk of frames at a time for each video
    for startframe_n = 1:chunk_size:n_frames
        if n_frames - startframe_n + 1 < chunk_size
            totframes = n_frames - startframe_n + 1;
        else
            totframes = chunk_size;
        end
        
        images = load_frames(startframe_n, totframes, header, expt);
        
        % Load an individual frame from the chunk of frames
        for frame_n = 1:totframes
            disp('Analyzing frame: ')
            disp(startframe_n + frame_n - 1)
            
            image = images(:, :, frame_n);
            
            % Loop through each quadrant
            for quad_n = 1:2
                mask = masks(:, :, quad_n);
                mask_border = mask_borders(:, :, quad_n);
                n_flies(startframe_n + frame_n - 1, quad_n) = mark_flies(image, mask, mask_border, min_area);
            end
        end
        
        % Save number of fly counts to Analysis file
        create_folder = mkdir(analysis_dir);
        save([analysis_dir, '\', 'flycounts.mat'], 'n_flies');
    end
    
    % Create an analyzed file tag
    file = fopen(analyzed_file, 'w'); 
    fclose(file);
end