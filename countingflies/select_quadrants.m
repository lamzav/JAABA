%% Select quadrants
% Reset everything
clear

%% Set all parameters
strel_size = 22; % Pixel dilation size for arena quadrants
data_dir = 'C:\Behavior_Experiments\Data'; % Folder containing olfactory arena videos
mask_dir = 'C:\Matlab_Scripts\trackingbehavior\countingflies\masks'; % Folder containing olfactory arena masks

%% Select and save arena quadrants for each camera
for cam_n = 1:2
    % Select video file
    cd(data_dir)
    if cam_n == 1
        [FileName, PathName] = uigetfile('*.ufmf', 'Select a video file for cam0');
    else
        [FileName, PathName] = uigetfile('*.ufmf', 'Select a video file for cam1');
    end
    video = strcat(PathName, FileName);   

    % Read in first frame of video
    header = ufmf_read_header(video);
    image = load_frames(1, 1, header, PathName);

    % View frame
    figure
    imagesc(image)

    % Manually select quadrants
    all_quad = [];
    for quad_n = 1:4
        imagesc(image)
        quadrants = roipoly;
        title('Current Frame');

        all_quad = cat(3, all_quad, quadrants);
    end

    % Save quadrant information
    quad1 = all_quad(:, :, 1) + all_quad(:, :, 3);
    quad2 = all_quad(:, :, 2) + all_quad(:, :, 4);
    
    if cam_n == 1
        cam0_quad = cat(3, quad1, quad2); 
    else
        cam1_quad = cat(3, quad1, quad2);
    end

    PathName = mask_dir; 
    if cam_n == 1
        save([PathName, '\', 'cam0_quad', '.mat'], 'cam0_quad');
    else
        save([PathName, '\', 'cam1_quad', '.mat'], 'cam1_quad');
    end
end

%% Dilate the quadrants to change the border width and create an arena border
for cam_n = 1:2
    if cam_n == 1
        quadrant = load([mask_dir, '\', 'cam0_quad.mat']);
        quadrant = quadrant.cam0_quad;
        arena = load([mask_dir, '\', 'cam0_arena.mat']);
        arena = arena.cam0_arena;
    else
        quadrant = load([mask_dir, '\', 'cam1_quad.mat']);
        quadrant = quadrant.cam1_quad;
        arena = load([mask_dir, '\', 'cam1_arena.mat']);
        arena = arena.cam1_arena;
    end
    
    img_size = length(quadrant);
    dilated_quad = zeros(img_size, img_size, 2);
    borders = zeros(img_size, img_size, 2);
    
    % Loop through each quadrant
    for quad_n = 1:2
        se = strel('disk', strel_size);
        se2 = strel('disk', strel_size + 2);
        
        mask = imdilate(quadrant(:, :, quad_n), se);
        mask(arena == 0) = 0;
        mask_border = imdilate(quadrant(:, :, quad_n), se2);
        mask_border(mask == 1) = 0;
        
        dilated_quad(:, :, quad_n) = mask;
        borders(:, :, quad_n) = mask_border;
    end
    
    if cam_n == 1
        save([mask_dir, '\', 'cam0_quad_dilated.mat'], 'dilated_quad');
        save([mask_dir, '\', 'cam0_border.mat'], 'borders');
    else
        save([mask_dir, '\', 'cam1_quad_dilated.mat'], 'dilated_quad');
        save([mask_dir, '\', 'cam1_border.mat'], 'borders');
    end
end