if exist('SUMOFLUXfig4_figS7.mat', 'file')
    load('SUMOFLUXfig4_figS7')
else
    disp 'Figure 4 and Supplementary Figure 7 data not found (file 'SUMOFLUXfig4_figS7.mat')'
    return;
end


targets = {'Anaplerosis from pyruvate', 'TCA cycle (sdh)', 'Glyoxylate shunt'};
oaaColors=[0 0.6 0.5;...
    0.9 0.6 0;...
    0.35 0.7 0.9]; % make a colors list



figure; 
for i=1:length(targets)
    subplot(1,3,i)
    bar(experimentalPrediction{i}(:,2), 'FaceColor', oaaColors(i,:))
    
    hold on
    lowerQuantile = experimentalPrediction{i}(:,2) - experimentalPrediction{i}(:,1);
    upperQuantile = experimentalPrediction{i}(:,3) - experimentalPrediction{i}(:,2);
    
    errorbar(1:length(experimentalStrains), experimentalPrediction{i}(:,2), lowerQuantile, upperQuantile, '.k')
    set(gca, 'XTick', 1:length(experimentalStrains))
    set(gca, 'XTickLabel', experimentalStrains)
    axis square
    ylim([0 1])
    xlim([0.25 8.75])
    title(targets{i}, 'fontSize', 14)
end
suptitle('Supplementary figure 7')
%%%%%%%

figure;
for i=1:length(targets)
    subplot(1,4,i)
    tagFR = targets(i);

    testFR = targetFRcell{i};
    rfTestFR = rfTestOutput{i};
    
    plotHeatmapValidation(testFR, rfTestFR, tagFR);
           
end

subplot(1,4,4)

oaaOrigin = [experimentalPrediction{1}(:,2) experimentalPrediction{2}(:,2) experimentalPrediction{3}(:,2)];
bar(oaaOrigin, 'stacked')

P=findobj(gca,'type','patch');
for i=1:length(P)
    set(P(i),'facecolor',oaaColors(i,:));
end

set(gca, 'XTick', 1:length(experimentalStrains))
set(gca, 'XTickLabel', experimentalStrains)
axis square
ylim([0 1.25])
xlim([0.25 8.75])
legend(P, targets, 'location', 'northOutside')
title('Origin of oxaloacetate', 'fontSize', 14)

suptitle('Figure 4')