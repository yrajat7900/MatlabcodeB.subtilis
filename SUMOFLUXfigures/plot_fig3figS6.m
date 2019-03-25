if exist('SUMOFLUXfig3figS6.mat', 'file')
    load('SUMOFLUXfig3figS6')
else
    disp 'Figure 3 data not found (file 'SUMOFLUXfig3figS6.mat')'
    return;
end



%find the maximum value
maxVal = 0;
for i=1:length(MAEnoise_exch_cell)
    if max(max(MAEnoise_exch_cell{i}))>maxVal
            maxVal = max(max(MAEnoise_exch_cell{i}));
    end
end
for i=1:length(MAEnoise_train_test)
    if max(max(MAEnoise_train_test{i}))>maxVal
            maxVal = max(max(MAEnoise_train_test{i}));
    end
end
for i=1:length(MAEnoise_exch_cell)
    if max(max(MAEnoise_exch_cell{i}))>maxVal
            maxVal = max(max(MAEnoise_exch_cell{i}));
    end
end

figure;
fsize = 10;
subplotidx = 1;

for maei = 1:3
    
    switch maei
        case 1
            MAEcell = MAEnoise_exch_cell;
            curxlabel = 'Noise';
            curxtick = noiseVEC;
            curylabel = {'Exchange flux' 'magnitude'};
            curytick = exchVEC; 
        case 2
            MAEcell = MAEnoise_train_test;
            curxlabel = 'Noise in testing';
            curxtick = noiseVEC;
            curylabel = {'Noise in' 'training'};
            curytick = noiseVEC;
        case 3
            MAEcell = MAEexch_train_test;
            curxlabel = {'Exchange flux' 'magnitude' 'in testing'};
            curxtick = exchVEC;
            curylabel = {'Exchange flux' 'magnitude' 'in training'};
            curytick = exchVEC;
    end

    for target_idx = 1:length(targets) 

        tagFR = targets{target_idx};

        MAEnoise_exch = MAEcell{target_idx};

        subplot(3,5,subplotidx)
        imagesc(MAEnoise_exch);
        axis xy

        set(gca, 'XTick',(1:length(curxtick)));
        set(gca, 'XTickLabel', curxtick);
        set(gca, 'YTick', (1:length(curytick)));
        set(gca, 'YTickLabel', curytick);
        xlabel(curxlabel, 'fontSize', fsize);
        ylabel(curylabel, 'fontSize', fsize);
        set(gca, 'fontSize', fsize-1);
        axis square
        title({tagFR 'SUMOFLUX test MAE'}, 'fontSize', fsize+2);

%         if max(max(MAEnoise_exch))>maxVal
%             maxVal = max(max(MAEnoise_exch));
%         end
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
 end
    

suptitle('Figure 3')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot figure S6

fsize = 8;
figure;
idx = 1;
%compare histograms with WIlcoxon Mann Whitney rank sum test
    WMWp = zeros(size(rfTestPredictionMalicEnzyme_noise));
    edgesstep = 0.05;
    edges = [0:edgesstep:1];
    for i=1:size(rfTestPredictionMalicEnzyme_noise,1)
        hmain = histc(rfTestPredictionMalicEnzyme_noise{i, i}, edges);
        for j=1:size(rfTestPredictionMalicEnzyme_noise,2)
            hcur = histc(rfTestPredictionMalicEnzyme_noise{i,j}, edges);
            WMWp(i,j) = ranksum(rfTestPredictionMalicEnzyme_noise{i,j},...
                                rfTestPredictionMalicEnzyme_noise{i,i},'alpha',0.01,'tail','right');
                             
            
            spi(j) = subplot(4,4,idx);
            bar(edges+edgesstep/2, hcur, 'FaceColor',[.3 .3 .3])
            
            idx = idx+1;
            axis square
            title(sprintf('WMWp = %.2f', WMWp(i,j)))
            xlim([0 1])
            if j==1
                ylabel(sprintf('Noise in training %.2f', noiseVEC(i)))
            end
            if i==4
                xlabel(sprintf('Noise in testing %.2f', noiseVEC(j)))
            end
        end
        linkaxes([spi(i), spi(setdiff([1:4],i))])
    end
suptitle('Figure S6a')


fsize = 8;
figure;
idx = 1;
%compare histograms with WIlcoxon Mann Whitney rank sum test
    WMWp = zeros(size(rfTestPredictionMalicEnzyme_exchange));
    edgesstep = 0.05;
    edges = [0:edgesstep:1];
    for i=1:size(rfTestPredictionMalicEnzyme_exchange,1)
        hmain = histc(rfTestPredictionMalicEnzyme_exchange{i, i}, edges);
        for j=1:size(rfTestPredictionMalicEnzyme_exchange,2)
            hcur = histc(rfTestPredictionMalicEnzyme_exchange{i,j}, edges);
            WMWp(i,j) = ranksum(rfTestPredictionMalicEnzyme_exchange{i,j},...
                                rfTestPredictionMalicEnzyme_exchange{i,i},'alpha',0.01,'tail','right');
                             
            
            spi(j) = subplot(4,4,idx);
            bar(edges+edgesstep/2, hcur, 'FaceColor',[.3 .3 .3])
            
            idx = idx+1;
            axis square
            title(sprintf('WMW p = %.2f', WMWp(i,j)))
            xlim([0 1])
            if j==1
                ylabel(sprintf('Exchange in training %.2f', exchVEC(i)))
            end
            if i==4
                xlabel(sprintf('Exchange in testing %.2f', exchVEC(j)))
            end
        end
        linkaxes([spi(i), spi(setdiff([1:4],i))])
    end
suptitle('Figure S6b')
