% Estimate number of worms using blob area
function [ estimated_worms, multi_blobs, vid_fr_multi_blob ] = estimate_worms(area, fr_countBlobs, num_worms_end, vid_fr_multi_blob, loop_counter)

    % Collect the area of all blobs detected
    total_blob_area = sum(area); 
    
    % Set the minimum blob area using the median and std values from the
    % training set
    load concatenated_blob_median.mat
    
    % Create variables for storing single and multi blobs
    multi_blobs = [];    
    single_blobs = [];   
    
    % Decide how to stimate the number of worms based on the number of blobs that were detected
    % If two or more blobs were detected
    if fr_countBlobs > 1 
        
        threshold = median(area) + 1.6 * std(double(area)); %It was 1.5 threshold for what "is too big"
        single_blobs = find(area < threshold);
        multi_blobs = find(area > threshold);
        
        % If there are multi blobs, use only the single blobs area 
        % to generate the denominator
        if ~ isempty(multi_blobs) 
            
            single_worm_area = area(single_blobs);
            % area_multi_blobs = area(multi_blobs);
            blob_divisor = median(single_worm_area);
            vid_fr_multi_blob = cat(1, vid_fr_multi_blob, loop_counter);      
            
        else
            
            % area_multi_blobs = 0;
            blob_divisor = median(area);
            
        end
        
        single_worm_total_area = sum(area(single_blobs));
        total_area_multi_blobs = sum(area(multi_blobs));
        estimated_worms = round(round(single_worm_total_area / blob_divisor) + round(total_area_multi_blobs / blob_divisor)); 

    % If one blob was detected
    elseif fr_countBlobs == 1
        
        % Since there is only blob, use the historical knowledge of worm size
        % This is specific to the videos with 41 frames analyzed
        blob_divisor = double(concatenated_blob_median(loop_counter));
        estimated_worms = round (total_blob_area / blob_divisor); 

    % If NO blobs were detected
    else
        
        estimated_worms = 0;
        
    end
    
    % In case the stimation is smaller than the number of blobs 
    % detected, use number of blobs
    if estimated_worms < fr_countBlobs 
        
        estimated_worms = fr_countBlobs;
        
    end
    
    % In case the stimation is larger than the actual number of
    % worms on the assay , use maximum number of worms 
    if estimated_worms > num_worms_end
        
        estimated_worms = num_worms_end;
        
    end