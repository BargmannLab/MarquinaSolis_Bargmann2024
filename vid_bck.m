%% Calculates the video background
% Takes as input a video object(v), the start and end frames to be 
% used to calculate the background
function background = vid_bck(vid, start_fr, end_fr)
    
    % Collect the video frame parameters
    total_frames = end_fr - start_fr - 1;
    height = vid.Height;
    width = vid.Width;
    
    % Make an empty array of length "frames" with the frame dimensions
    img_vid = zeros(height, width, total_frames);
    
    % Store video data frame-by-frame into empty_array
    fr = start_fr;
    ind = 1;
    
    while fr < end_fr
        
        img_vid(:, :, ind) = rgb2gray(read(vid, ind));
        ind = ind + 1;
        fr = fr + 1;
        
    end
    
    % Calculate background at 70 percentile
    background = uint8(prctile(img_vid, 70, 3));      
