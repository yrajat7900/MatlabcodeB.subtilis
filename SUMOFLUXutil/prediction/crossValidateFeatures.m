function [lcCrossValidationMAE, importanceSort, lcCrossValidationQuantileSpan] = crossValidateFeatures(mat_noise, targetFR, nvalid, numtrees, mtry, percFeatures)

if size(mat_noise,1) ~= length(targetFR)
    mat_noise = mat_noise';
end
if size(targetFR,1)==1
    targetFR = targetFR';
end

lcCrossValidationMAE = zeros(length(percFeatures),1);
lcCrossValidationQuantileSpan = zeros(length(percFeatures),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nvalid-fold cross validation for the metaparameter search
validGroups = randi(nvalid, length(targetFR),1);
importanceSort = 1:size(mat_noise,2);

%make sure to start with all features
percFeatures = sort(percFeatures, 'descend');
if percFeatures(1) ~=1
    percFeatures = [1 percFeatures];
end

predictionQuantiles = [0.1 0.5 0.9];    
    
for perc_i=1:length(percFeatures)
       
    curFeatures = importanceSort(1:floor(length(importanceSort)*percFeatures(perc_i)));
        
    maeValid = 0;
    quantileSpan=0;
    for vi=1:nvalid
        [rfmodel] = regRF_train(mat_noise(validGroups~=vi, curFeatures), targetFR(validGroups~=vi), numtrees, mtry);
        [rfvalidoutput] = regRF_predict(mat_noise(validGroups==vi,curFeatures), rfmodel);
        [rfvalidquantiles] = calculateRFquantiles(mat_noise(validGroups~=vi, curFeatures), targetFR(validGroups~=vi), mat_noise(validGroups==vi,curFeatures), rfmodel, predictionQuantiles);

        maeValid = maeValid + sum(abs(targetFR(validGroups==vi)-rfvalidoutput));
        quantileSpan = quantileSpan+sum(rfvalidquantiles(:,3)-rfvalidquantiles(:,1));
    end
    maeValid = maeValid/length(targetFR);
    quantileSpan = quantileSpan/length(targetFR);
    
    lcCrossValidationMAE(perc_i) = maeValid;
    lcCrossValidationQuantileSpan(perc_i) = quantileSpan;
    
    if perc_i == 1
        [~, importanceSort] = sort(rfmodel.importance, 'descend');
    end
end