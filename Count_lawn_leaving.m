% Javier Marquina-Solis
% Bargmann Lab
% The code takes as input an avi video and count the number of worms outside 
% the lawn of bacteria using a dynamic background calculation and vision blob
% analysis toolbox. The ROI is define by the user by drawing an ellipse
% around the plate and aoutomatic detection of the lawn.
% VERSION: SINGLE VIDEO ANALYSIS 
% THIS VERSION IS FOR THE VIDEOS 1 FRAME PER MINUTE
function [output] = Count_lawn_leaving()
%% Select a video and load it
[fullFileName, pathname, ~] = uigetfile({'*.avi'});
vid = VideoReader([pathname fullFileName]); 
fprintf(1, 'Now processing %s\n', fullFileName);

% Show a frame
figure; imshow(imadjust(rgb2gray(read(vid,600))));
pause();
close all;

%% Ask user to input experiment info 
% ID name is CRITICAL for the analysis. USE THE FORMAT 'genotype_rep#' as ID. 
% The code will group together experiments with the same genotype.
% (e.g. WT_rep1; flp1_rep3, dmsr7_rep2, etc.) 
ID = input('Experiment identifier?\n', 's');
num_worms_start = input('How many worms started the assay?\n');
num_worms_end = input('How many ended the assay?\n');

%% Generate plate mask using an ellipse draw by the user
% Ask user to draw an ellipse to create the plate mask
figure; imshow(imadjust(rgb2gray(read(vid,600))));
plate = imellipse;
position = wait(plate);
pos_plate = getPosition(plate);
plate_mask = imcrop((plate.createMask()), pos_plate);
close all;

%% Generate background images for lawn-edge detection
% Since bacterial lawns grow over 20 hours period. The code calculates 3 different 
% backgrounds for lawn-edge detection at specific periods
bck_lawn_1 = imcrop(vid_bck(vid, 1, 400), pos_plate);
bck_lawn_2 = imcrop(vid_bck(vid, 401, 800), pos_plate);
bck_lawn_3 = imcrop(vid_bck(vid, 801, 1200), pos_plate);

%% Detect lawn and generate lawn masks at 3 timepoints
% Treshold values for the PA14 lawn edge detection. Smaller number gives a bigger lawn. Adjust as necessary.
th_1 = 0.0035; % 0.005 Good for mutants that leave faster
th_2 = 0.0035; % 0.005 
th_3 = 0.0030; % 0.005

% Create the lawn-mask and detect the lawn at 3 different time frames
[edge_x1, edge_y1] = edge_detection(bck_lawn_1, th_1);
lawn_mask_1 = 1 - (poly2mask(edge_x1, edge_y1, size(bck_lawn_1, 1), size(bck_lawn_1, 2)));

[edge_x2, edge_y2] = edge_detection(bck_lawn_2, th_2);
lawn_mask_2 = 1 - (poly2mask(edge_x2, edge_y2, size(bck_lawn_2, 1), size(bck_lawn_2, 2)));

[edge_x3, edge_y3] = edge_detection(bck_lawn_3, th_3);
lawn_mask_3 = 1 - (poly2mask(edge_x3, edge_y3, size(bck_lawn_3, 1), size(bck_lawn_3, 2)));

% Plot figures so the user can verify the lawns have been detected
figure; 
subplot(131); imshow(imcrop(rgb2gray((read(vid,400))), pos_plate)); hold on; plot(edge_x1, edge_y1,'-w','LineWidth',.5);
subplot(132); imshow(imcrop(rgb2gray((read(vid,800))), pos_plate)); hold on; plot(edge_x2, edge_y2,'-w','LineWidth',.5);
subplot(133); imshow(imcrop(rgb2gray((read(vid,1200))), pos_plate)); hold on; plot(edge_x3, edge_y3,'-w','LineWidth',.5);
pause();
close all;

%% Analysis of the frames
% Set parameters required for the analysis of the frames 
N_frames = vid.NumberOfFrames;
stp = 30;   % Every how many frames(minutes) you want to analyze 

% Set parameters for the BlobAnalysis
hblob = vision.BlobAnalysis;
hblob.MaximumCount = num_worms_end;
hblob.ExcludeBorderBlobs = true;

% Create variables for counting the blobs detected, the estimated number
% of worms throuhgt the whole video, and the frames with multiblobs
vid_countBlobs = [];
vid_estimated_worms = [];
vid_fr_multi_blob = [];

%% Blob detection loop
% Start of the loop, load and analyze frames one by one
loop_counter = 1;

for fr = 1: stp: N_frames       
    
    % Set the appropiate mask for analysis 
    if fr < 401
        analysis_mask = plate_mask .* lawn_mask_1;
        schmutz = 30; % 30
        
    elseif fr < 801
        analysis_mask = plate_mask .* lawn_mask_2;
        schmutz = 45; % 45
        
    else
        analysis_mask = plate_mask .* lawn_mask_3;
        schmutz = 55; % 60
        
    end
    
    % Open and crop current frame 
    im_current = imcrop(rgb2gray(read(vid, fr)), pos_plate);
    
    % Create the dynamic background and substract it from the currentframe
    background = imcrop((dynamicBackground(vid, fr, 60, 2)), pos_plate); % 60 frames with a stp of 2 seems to be the sweet spot
    imtemp_current = imsubtract(uint8(background), im_current);

    % Imbinarize the image using a threshold determined by the user
    % and eliminate the lawn and plate by mutliplying analysis mask
    level = 0.025;  
    im_segment_current = im2bw(imtemp_current, level) .* (analysis_mask);    
    
    % Get rid off smalls blobs by eliminating objects below a threshold
    im_segment_current = bwareaopen(im_segment_current, schmutz);
    
    % Use blob analysis to take the positions of the blobs
    [area, centroid, bbox] = step(hblob, im_segment_current);
    area = double(area);
    
    % Count the number of blobs using the number of centroids detected
    fr_countBlobs = size(centroid, 1);
    vid_countBlobs = cat(1, vid_countBlobs, fr_countBlobs);
    
    % Estimate worms based on the area of the blobs
    [fr_estimated_worms, multi_blobs, vid_fr_multi_blob] = estimate_worms(area, fr_countBlobs, num_worms_end, vid_fr_multi_blob, loop_counter);

    % Keep track of the estimated number of worms thtoughout the video
    vid_estimated_worms = cat(1, vid_estimated_worms, fr_estimated_worms);
            
    % Display the current frame, number of blobs detected, and number
    % of worms estimated. Default mode is 'Fast'. Other display options are
    % 'No' display and 'Check' mode.
    fr_display(im_current, fr_estimated_worms, fr_countBlobs, loop_counter, bbox, multi_blobs, 'Fast')
    
    % Increase the loop_counter
    loop_counter = loop_counter + 1;

end

% CALCULATE AVERSION RATIO FOR ALL TIMEPOINTS (MAIN OUTPUT)
aversion_ratio = vid_estimated_worms / num_worms_end;

pause();
close all;

%% Plot the results
% Generates two plots: Number of blobs detected VS frame, and aversion ratio VS frame
plotter(vid_estimated_worms, num_worms_end, aversion_ratio, vid_fr_multi_blob, ID) 

%% Save Variables
% Create a struct array containing the following data
Name = fullFileName(1 : (length(fullFileName) - 4));

output = struct('Name', Name, 'ID', ID, 'aversion_ratio', aversion_ratio, 'vid_estimated_worms', vid_estimated_worms, ...
    'vid_countBlobs', vid_countBlobs, 'num_worms_start', num_worms_start, 'num_worms_end', num_worms_end);

% Save the output data
assignin('base','output', Name)
save(Name, 'output')

%% Open the results (Only necessary if you copy and paste manually...) 
% openvar('vid_estimated_worms')
% openvar('aversion_ratio')

