
% Javier Marquina-Solis
% Bargmann Lab
% The code runs the Batch_Count_Lawn_leaving function on the avi videos
% contain in a directory. 

function [all_videos] = batch_analysis()
%% Create the video object and analyze all videos in the directory
% Get the directory path and specify the type of file extension
myDir = uigetdir;	
myFiles = dir(fullfile(myDir,'*.avi')); 

% Analyze all videos in the directory
all_videos = struct([]);

for video = 1:length(myFiles)
    
    % Get path and name of each video 
	baseFileName = myFiles(video).name;  
	fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now processing %s\n', baseFileName); 
    
    % Call the count leaving fucntion
    output = Batch_Count_Lawn_leaving(fullFileName, baseFileName);
    
    % Concatenate the outputs
    all_videos = cat(1, all_videos, output);
    
end

%% Concatenate the Aversion Ratio of experiments with the same identifier
% Make variables to store the Aversion Ratio(AR) grouped by genotype
AR_by_genotype = struct;
genotypes_list = [];

% Get the name of the identifiers
identifiers = {all_videos.ID};

% Parse the identifiers and look for the genotype of each experiment
for ii = 1 : length(identifiers)
    
    parsed_ID = strsplit(identifiers{ii}, '_');
    
    % Check if the identifier is in the 'genotypes' array. If not add it.
    if ~any(strcmp(genotypes_list, parsed_ID(1)))
        
        genotypes_list = [genotypes_list; parsed_ID(1)];
        
    else
        % Do nothig
        
    end
        
end

%% Make the nice table so you can copy paste to PRISM
% Create the cell array that groups the Aversion Ratio(AR) values by genotype 
AR_Table = [];

% For each genotype...
for jj = 1 : length(genotypes_list) 
    
    ind = 1;
    
    % Look through all the files to find the experiments with the same
    % genotype
    for tt = 1 : length(identifiers)
        
        parsed_ID = strsplit(identifiers{tt}, '_');
        
        if isequal(char(genotypes_list(jj, 1)), parsed_ID{1})
            
            AR_by_genotype(ind).(char(parsed_ID(1))) = num2cell(all_videos(tt).aversion_ratio);
            ind = ind + 1;
            
        else
            % Do nothing
            
        end
                
    end

    % Save the files as .mat variables. Calculate mean and error of the
    % mean. Get ready for plot? 
    AR_Table = [AR_Table, cell2mat([AR_by_genotype.(char(genotypes_list(jj)))])];
    
    % Open the variables in a table so you can copy them easy to PRISM
    openvar('AR_by_genotype');
    openvar('AR_Table');
     
end

%% Calculate mean and error of the mean for each genotype
mean_table  = [];

for field = 1 : length(genotypes_list)
   
    temp_table = [];

    field_name = char(genotypes_list(field));
    num_entry = sum(arrayfun(@(AR_by_fields) ~isempty(AR_by_fields.(field_name)), AR_by_genotype));
    
    for entry = 1 : num_entry
        temp_table = [temp_table, cell2mat(AR_by_genotype(entry).(field_name))];
        
    end
    
    mean_table = [mean_table, mean(temp_table, 2)];
    
end

%% Plot Aversion Ratio VS Hours
% Setup colors to be used in the plot (Green, black, BlueViolet, NavyBlue, Blue)
colors = {[0.21600, 0.60000, 0.03000], [0, 0, 0], [0.13440, 0.08640, 0.96000], [0.06000, 0.46000, 1.00000], [0, 0, 1]};
figure,

% Plot the data
for g = 1 : length(genotypes_list)

    plot(1 : length(mean_table), (mean_table(:, g)), 'color', colors{g}, 'marker', '.',...
        'LineWidth', 1, 'MarkerSize', 15)

    hold on
    
end
    
% Title parameters
title('Mean Aversion Ratio', 'FontSize', 14)

% X axis parameters. This is based on the experiments with 41 frames
% analyzed. Need to change if you analyze more or less frames
set(gca, 'xlim', [1, 41])
set(gca,'XTick',1: 4: 41)
set(gca,'XTickLabel',0: 2: 20)
xlabel('Hours')

% Y axis parameters
set(gca, 'ylim', [0, 1])
set(gca,'YTick', 0: 0.1: 1);
ylabel('Aversion Ratio')

% Generate the legend
L = cell(length(genotypes_list), 1);
    
for l = 1 : length(genotypes_list)
    L{l} = genotypes_list{l};
end

legend((L), 'Location','northwest');
legend boxoff

% Save figure
fig_name = [baseFileName(1:11)  'Summary'];
savefig(fig_name);

%% SAVE THE DATA
% Save the struct file containing the data from all videos analyzed
file_name = [baseFileName(1:11)  'Analysis'];

% Save the output data to the workspace
assignin('base','file_name', file_name)
assignin('base','all_videos', all_videos)
assignin('base','AR_by_genotype', AR_by_genotype)
assignin('base','AR_Table', AR_Table)

% Save a .mat file with the date and name of the experiment
save(file_name, 'all_videos', 'AR_by_genotype', 'AR_Table')