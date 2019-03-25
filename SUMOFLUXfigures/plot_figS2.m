if exist('SUMOFLUXfigS2.mat', 'file')
    load('SUMOFLUXfigS2')
else
    disp 'Supplementary Figure 2 data not found (file 'SUMOFLUXfigS2.mat')'
    return;
end

shapes = {'o', 'v', 'd', 's'};
colors = [1 1 1
          0.6 0.6 0.6
          0.3 0.3 0.3
          0 0 0];
 
figure; 
for target_idx = 1:length(targets)
    subplot(2,3, target_idx)
    for i=1:length(ntreevec)
        for j=1:length(mtryvec)
            plot(cvTime{target_idx}(i,j), cvMAE{target_idx}(i,j), shapes{i}, 'MarkerFaceColor', colors(j,:), 'MarkerEdgeColor', 'k', 'MarkerSize', 15);
            hold on
        end
    end
    xlabel('Training time (sec)')
    ylabel('CV mean absolute error')
    title(targets{target_idx}, 'fontSize', 14)
    axis square
    if target_idx == length(targets)
        legend(metaParameters, 'Location', 'EastOutside')
    end
end

suptitle('Supplementary Figure 2a')


figure;
for i=1:size(lcTrainMAE,1)
    subplot(2,3,i);
    plot(lcTrainMAE(i,:), 'k', 'LineWidth', 3)
    hold on
    plot(lcTestMAE(i,:), 'k--', 'LineWidth', 3)
    title(targets{i}, 'fontSize', 14)
    ylim([0 0.155])
    xlim([1 length(learning_curve)])
    set(gca, 'XTick', 1:length(learning_curve));
    set(gca, 'XTickLabel', learning_curve/1000);
    xlabel('Total sample size (x 10^3)')
    ylabel('Test mean absolute error')    
    axis square
    
    legend({'Training', 'Testing'}, 'Location', 'SouthOutside')
    
end
suptitle('Supplementary Figure 2b')
