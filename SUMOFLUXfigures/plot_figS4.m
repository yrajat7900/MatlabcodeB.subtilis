if exist('SUMOFLUXfigS4.mat', 'file')
    load('SUMOFLUXfigS4')
else
    disp 'Figure S4 data not found (file 'SUMOFLUXfigS4.mat')'
    return;
end


mfaPredictions = mfaPredictions1U;
mfaQuantiles = mfaQuantiles1U;
fig = figure;
idx = 1;
for i=1:length(mfaPredictions)
    subplot(4,3,idx)
    plotScatterValidation(mfaPredictions{i}', mfaQuantiles{i}(:,3), mfaQuantiles{i}(:,7),...
        experimentalPrediction{i}(:,2), experimentalPrediction{i}(:,1), experimentalPrediction{i}(:,3), targets{i});
    xlabel({'MFA best fit ratios' 'Best fit to 113C+U13C data'})
    ylabel('SUMOFLUX estimates')

    idx = idx+1;
end

mfaPredictions = mfaPredictions113C;
mfaQuantiles = mfaQuantiles113C;
for i=1:3
    subplot(4,3,idx)
    plotScatterValidation(mfaPredictions{i}', mfaQuantiles{i}(:,3), mfaQuantiles{i}(:,7),...
        experimentalPrediction{i}(:,2), experimentalPrediction{i}(:,1), experimentalPrediction{i}(:,3), targets{i});
    xlabel({'MFA best fit ratios'  'Best fit to 113 data'})
    ylabel('SUMOFLUX estimates')

    idx = idx+1;
end

mfaPredictions = mfaPredictionsU13C;
mfaQuantiles = mfaQuantilesU13C;
for i=4:6
    subplot(4,3,idx)
    plotScatterValidation(mfaPredictions{i}', mfaQuantiles{i}(:,3), mfaQuantiles{i}(:,7),...
        experimentalPrediction{i}(:,2), experimentalPrediction{i}(:,1), experimentalPrediction{i}(:,3), targets{i});
    xlabel({'MFA best fit ratios'  'Best fit to U13C data'})
    ylabel('SUMOFLUX estimates')

    idx = idx+1;
end
suptitle('Supplementary Figure 4')