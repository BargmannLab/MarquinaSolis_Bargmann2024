%% Plot the results
% Input: vid_estimated_worms, num_worms_end, vid_fr_multi_blob, ID
function plotter(vid_estimated_worms, num_worms_end, aversion_ratio, vid_fr_multi_blob, ID) 

% Change the '_' for a blank space since it gives a problem in the legend
newID = strrep(ID,'_',' ');

% % % % % % % % % % % % Plot Estimated Worm Number VS Analyzed frame % % % % % % % % % % % % 
figure,
plot(1 : length(vid_estimated_worms), vid_estimated_worms, 'b-o', 'LineWidth', 1,...
    'MarkerEdgeColor', 'b', 'MarkerSize', 5)

% Title parameters
title('Estimated Worm Number VS Analyzed frames', 'FontSize', 14)

% Y axis parameters
set(gca,'ytick', 0 : num_worms_end)
set(gca, 'ylim', [0, num_worms_end])
ylabel('Number of Worms')

% X axis parameters
xlabel('Analyzed Frames')

% Legend
legend(newID, 'Location','northwest');
legend boxoff

hold on

% Label in red the frames that might have multi-worm blobs
for jj = 1 : size(vid_fr_multi_blob, 1)
    
    plot(vid_fr_multi_blob(jj), vid_estimated_worms(vid_fr_multi_blob(jj)),'r-o',...
        'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'MarkerSize', 5)
end

hold off


% % % % % % % % % % % % Plot Aversion Ratio VS Time % % % % % % % % % % % %  
figure,
plot(1 : length(vid_estimated_worms), (aversion_ratio), 'k-o', 'LineWidth',1,...
    'MarkerEdgeColor', 'k', 'MarkerSize', 5)

% Title parameters
title('Aversion Ratio VS Time', 'FontSize', 14)

% X axis parameters
set(gca, 'xlim', [1, 41])
set(gca,'XTick',1: 4: 41)
set(gca,'XTickLabel',0: 2: 20)
xlabel('Hours')

% Y axis parameters
set(gca, 'ylim', [0, 1])
set(gca,'YTick', 0: 0.1: 1);
ylabel('Aversion Ratio')

% Legend
legend(newID, 'Location','northwest');
legend boxoff
