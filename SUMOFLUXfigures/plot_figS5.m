if exist('SUMOFLUXfigS5.mat', 'file')
    load('SUMOFLUXfigS5')
else
    disp 'Supplementary Figure 5 data not found (file 'SUMOFLUXfigS5.mat')'
    return;
end


figure;
fsize = 10;
subplotidx = 1;

for target_idx = 1:length(targets) 
    
    tagFR = targets{target_idx};
    
    MAEnoise_exch = MAEnoise_exch_cell_ANALYTICAL{target_idx};
    
    subplot(1,5,subplotidx)
    imagesc(MAEnoise_exch);
    axis xy
   
    set(gca, 'XTick',(1:length(noiseVEC)));
    set(gca, 'XTickLabel', noiseVEC);
    set(gca, 'YTick', (1:length(exchVEC)));
    set(gca, 'YTickLabel', exchVEC);
    xlabel('Noise', 'fontSize', fsize);
    ylabel({'Exchange flux' 'magnitude'}, 'fontSize', fsize);
    set(gca, 'fontSize', fsize-1);
    axis square
    title({tagFR, 'Analytical formulas test MAE'}, 'fontSize', fsize+2);

  
    maxVal = max(max(MAEnoise_exch));
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
        colormap(cmap);
        caxis([0 maxVal]);
    else
        T = [0 0.45 0.7; 0.95 0.9 0.25; 0.8 0.4 0];
        x = [0 0.5 1];
        map = interp1(x, T, linspace(0,1,255));
        colormap(map);
        caxis([0 0.15]);
    end
    colorbar('northoutside')
    subplotidx = subplotidx + 1;
end
suptitle('Supplementary Figure 5')