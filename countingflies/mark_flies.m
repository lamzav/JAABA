%% Mark foreground objects
function n_flies = mark_flies(image, mask, mask_border, min_area)
    image(mask == 0) = NaN;
    threshold = adaptthresh(image, 0.5, 'ForegroundPolarity', 'dark');
    binary = imbinarize(image, threshold);
    binary = abs(binary - 1);
    binary(mask_border == 1) = 0;
    binary2 = bwareaopen(binary, min_area); 

%     se = strel('disk', 2);
%     binary = imerode(binary, se);
    
    % Count the number of flies in the quadrant
%     props = table2array(regionprops('table', binary, 'Area', 'Eccentricity'));
    [~, n_flies] = bwlabel(binary2);
    n_flies = n_flies - 1;