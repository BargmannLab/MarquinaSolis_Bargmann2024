%% Function dynamic background
% Takes as input a video object(v), the current frame to be subtracted, the
% number of frames to be use for the background, and the step
function background = dynamicBackground(v, frame, numFrame, step)
 
    nf= v.NumberOfFrames; 
 
    % Generate the background matrix with zeros
    stack = zeros(v.Height, v.Width, numFrame + 1);
    kk = 1;
    
    % Fill up the matrix frame-by-frame
    if frame < step * numFrame + 1
        
        index = (frame:step:frame + step * numFrame);
        
        for jj = index
            stack(:, :, kk) = rgb2gray(read(v, jj));
            kk = kk + 1;
            
        end
        
        % Mean of the stack to obtain the background
        background = uint8(mean(stack, 3)); 
    
    else
        index = (frame:-step:frame-step * numFrame);
        
        for jj = index
            stack(:, :, kk) = rgb2gray(read(v, jj));
            kk= kk + 1;
            
        end
        
        % Mean of the stack to obtain the background
        background = uint8(mean(stack, 3)); 
        
    end
    
end