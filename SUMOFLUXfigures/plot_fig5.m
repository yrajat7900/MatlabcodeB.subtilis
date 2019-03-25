% print mae matrix
if exist('SUMOFLUXfig5.mat', 'file')
    load('SUMOFLUXfig5.mat')
else
    disp 'Figure 5 data not found (file 'SUMOFLUXfig5.mat')'
    return;
end

targets = {'Malic enzyme (mae/pyk)', 'Gluconeogenesis', 'Glycolysis'};
measurementSets = {'GC/MS', 'LC-MS', 'LC-MS/MS', 'LC-MS/MRM'};
labeling_strategies = { '1-13C-Glucose';...
                        '2-13C-Glucose';...
                        '6-13C-Glucose';...
                        '12-13C-Glucose';...
                        '56-13C-Glucose';...
                        '456-13C-Glucose';...
                        '50% U-13C-Glucose';...
                        '20%-U 80%-1-13C-Glucose'};
    
figure;                    
for target_i = 1:length(targets);
    subplot(1,3,target_i)
    imagesc(maeTestLabeling{target_i});
    set(gca, 'XTick', 1:length(measurementSets))
    set(gca, 'XTickLabel', measurementSets)
  
    set(gca, 'YTick', 1:length(labeling_strategies));
    set(gca, 'YTickLabel', labeling_strategies)
    title(['Experimental design: ' targets{target_i}]);
    axis square
    colorbar


    maxVal = max(max(maeTestLabeling{target_i}));
    maxErr = 0.15;
        if maxVal>maxErr
            zeroPoint = round(256 * (maxErr/maxVal));

            T = [0 0.45 0.7; 0.95 0.9 0.25; 0.8 0.4 0];
            x = [0 0.5 1];
            map = interp1(x, T, linspace(0,1,zeroPoint));

            T = [0.8 0.4 0; 0 0 0];
            x = [0 1];
            redtoblackmap = interp1(x, T, linspace(0,1,round(256 * (1-maxErr))));

            cmap = zeros(256,3); % Initialize
            cmap(1:zeroPoint, :) = map; %green to red between 0 and 0.15
            cmap(zeroPoint+1:end, :) = redtoblackmap(1:256-zeroPoint,:); % red to black otherwise
            colormap(cmap)
            caxis([0 maxVal])
        else
            T = [0 0.45 0.7; 0.95 0.9 0.25; 0.8 0.4 0];
            x = [0 0.5 1];
            map = interp1(x, T, linspace(0,1,255));
            colormap(map)
            caxis([0 0.15])
        end
end

suptitle('Figure 5')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

