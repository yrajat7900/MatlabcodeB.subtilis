function [experimentalPrediction,predictionQuantiles,experimentalMeanPrediction] = ...
    SUMOFLUXapply(rfmodel, mat_noise_subset, targetFRsubset, train_idx, tagFR,...
                    experimentalData, experimentalStrains)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
experimentalPrediction=[];
predictionQuantiles=[];
experimentalMeanPrediction = [];

% CHECK THE DIMENSIONS
if size(mat_noise_subset,2) ~= size(experimentalData,2) %dimensions do not agree
    if size(mat_noise_subset,2) ~= size(experimentalData,1) %if transposed dimensions also do not agree
        disp ' '
        disp 'ERROR: experimental data size is different from the simulated data size'
        disp 'ERROR: change the list of extracted measurements in STEP 3'
        disp 'ERROR: or load different experimental data'
        disp ' '
        return;
    else
        if length(experimentalStrains) == size(experimentalData,1) %transposed dimensions agree, but this is the number os samples
            disp ' '
            disp 'ERROR: experimental data size is different from the simulated data size'
            disp 'ERROR: change the list of extracted measurements in STEP 3'
            disp 'ERROR: or load different experimental data'
            disp ' '
            return;
        else %transposed dimensions agree - transpose the experimentalData
            experimentalData = experimentalData';
        end
    end
end
      
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% APPLY TO EXPERIMENTAL DATA
   
predictionQuantiles = [0.1 0.5 0.9];
experimentalPrediction = calculateRFquantiles(mat_noise_subset(train_idx,:), targetFRsubset(train_idx), experimentalData, rfmodel, predictionQuantiles);
experimentalMeanPrediction = regRF_predict(experimentalData, rfmodel);
figure;
barh(experimentalPrediction(:,2))
hold on
herrorbar(experimentalPrediction(:,2), 1:size(experimentalPrediction,1), experimentalPrediction(:,2)-experimentalPrediction(:,1), experimentalPrediction(:,3)-experimentalPrediction(:,2), 'k.')
set(gca, 'YTick', 1:length(experimentalStrains))
set(gca, 'YTickLabel', experimentalStrains)
xlabel('Flux ratio estimate')
title({tagFR{1}, 'Experimental data'}, 'fontSize', 14)
xlim([0 1])
ylim([0 length(experimentalStrains)+1])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save to file?
FilterSpec = {'*.mat'; '*.csv'};
DialogTitle = 'Save prediction results';
DefaultName = strrep(['mySUMOFLUXexperimentalPrediction_' tagFR{1}], '/', '_');
DefaultName = strrep(DefaultName, '\', '_');
DefaultName = strrep(DefaultName, filesep, '_');

saveFileName = openSaveFileDialog(FilterSpec, DialogTitle, DefaultName);
if ~isempty(saveFileName)
    [~,~,EXT] = fileparts(saveFileName);
    switch EXT
        case '.mat' %Save as matlab file
            repeatSAVE = 1;
            while repeatSAVE
                try
                    save(saveFileName, 'experimentalData', 'experimentalPrediction', 'experimentalStrains', 'experimentalMeanPrediction', 'predictionQuantiles');
                    repeatSAVE = 0;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp(ME.identifier)
                    disp 'SUMOFLUX workflow can continue'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                end
            end
        case '.csv'
            fid = fopen(saveFileName, 'w');
            fprintf(fid, 'Strain,Quantile %.2f,Quantile %.2f,Quantile %.2f,Mean\n', predictionQuantiles);
            for i=1:length(experimentalStrains)
                fprintf(fid, '%s,%.2f,%.2f,%.2f,%.2f\n', experimentalStrains{i}, experimentalPrediction(i,:),experimentalMeanPrediction(i));
            end
            fclose(fid);
        otherwise
            disp 'Unknown file format'
    end
end
