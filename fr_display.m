% Display the current frame analyzed, number of blobs detected, and number
% of worms estimated. Default mode is 'Fast'. Other display options are
% 'NO' and 'Check'.
function fr_display(im_current, estimated_worms, fr_countBlobs, loop_counter, bbox, multi_blobs, display_mode)
    
    % If display mode is 'Fast', pause for 2 seconds after displaying the frame    
    if strcmp(display_mode, 'Fast') == 1 
        % Insert box with the estimated number of worms
        
        figure(1) 
        im_current = insertText(imadjust(im_current), [100 1], estimated_worms, 'BoxOpacity', 0.6, ...
            'FontSize', 100,'BoxColor', 'red');

        % Insert box with number of blobs detected
        im_current = insertText(im_current, [1 91], fr_countBlobs, 'BoxOpacity', 0.6, ...
            'FontSize', 50,'BoxColor', 'green');

        % Insert box with frame number
        im_current = insertText(im_current, [1 1], loop_counter, 'BoxOpacity', 0.6, ...
            'FontSize', 50,'BoxColor', 'blue');

        % Insert counter number next to the detected blobs
        counter_position = bbox(:, 1:2);
        adjusted_counter_position = counter_position + 5;

        for ii = 1 : fr_countBlobs
            im_current = insertText(im_current, adjusted_counter_position(ii, :), ii, 'BoxOpacity', 0,'TextColor', 'red');
        end

        % Point out big blobs
        if isempty(multi_blobs) == 0
            for ll = 1 : size(multi_blobs, 1)
                im_current = insertText(im_current, adjusted_counter_position(multi_blobs(ll), :), multi_blobs(ll), 'BoxOpacity', 0, 'TextColor', 'green');
            end
        end
    
     % Pause for 2 seconds to show the current frame
        imshow(im_current)
        hold on    
        % pause(2) 
        hold off
        
        
    % If display mode is 'Check', pause until user press a key     
    elseif strcmp(display_mode, 'Check') == 1 
        % Insert box with the estimated number of worms
        figure(1),
        im_current = insertText(imadjust(im_current), [100 1], estimated_worms, 'BoxOpacity', 0.6, ...
            'FontSize', 100,'BoxColor', 'red');

        % Insert box with number of blobs detected
        im_current = insertText(im_current, [1 91], fr_countBlobs, 'BoxOpacity', 0.6, ...
            'FontSize', 50,'BoxColor', 'green');

        % Insert box with frame number
        im_current = insertText(im_current, [1 1], loop_counter, 'BoxOpacity', 0.6, ...
            'FontSize', 50,'BoxColor', 'blue');

        % Insert counter number next to the detected blobs
        counter_position = bbox(:, 1:2);
        adjusted_counter_position = counter_position + 5;

        for ii = 1 : fr_countBlobs
            im_current = insertText(im_current, adjusted_counter_position(ii, :), ii, 'BoxOpacity', 0, 'TextColor', 'red');
        end

        % Point out big blobs
        if isempty(multi_blobs) == 0
            for ll = 1 : size(multi_blobs, 1)
                im_current = insertText(im_current, adjusted_counter_position(multi_blobs(ll),:), multi_blobs(ll), 'BoxOpacity', 0, 'TextColor', 'green');
            end
        end
   
        % Pause until user press a key
        imshow(im_current)
        hold on    
        pause()
        hold off   
     
        
    % If display mode is disabled do NOTHING
    elseif strcmp(display_mode, 'No') == 1 
        % Do nothing      
        
    % If user type any other stuff just do nothing   
    else
        % Do nothing  
        
    end