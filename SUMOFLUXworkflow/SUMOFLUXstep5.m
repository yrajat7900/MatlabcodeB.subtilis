function [rfmodel, mat_noise_subset, targetFRsubset, train_idx, test_idx, tagFR] = ...
    SUMOFLUXstep5(mat_noise, fluxVectors, sampleM, fluxRatio_list, chosenFR)

rfmodel=[];
mat_noise_subset=[];
targetFRsubset = [];
train_idx = [];
test_idx = [];

try
    ratioName = fluxRatio_list{chosenFR};
    targetstring = ratiolist(fluxRatio_list, ratioName{1});
    [targetFR, tagFR] = extractRatio(targetstring,fluxVectors, sampleM);
    if isempty(targetFR)
        disp ' '
        disp 'ERROR: flux ratio not applicable for the chosen model'
        disp ' '
        return
    end
catch ME
    disp 'ERROR: Error extracting flux ratio from the flux vectors sample'
    disp 'ERROR: Make sure the reaction names are the same as in the provided model'
        disp '*************'
        disp(ME.message)
        disp '*************'
    return
end

if nnz(targetFR)==0
    disp 'ERROR: Error extracting flux ratio from the flux vectors sample'
    disp 'ERROR: Make sure the reaction names are the same as in the provided model'
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 5
% a. Divide the simulated dataset into training and test;
% b. Train the predictor on the test dataset;
% c. Assess the predictor performance on the test dataset;
disp ' '
disp '***********************************************************************************************'
disp 'STEP 5: Training and testing the predictor'
disp ' '

% define the maximal size of training+test subset
maxSampleSize = 20000;
[targetFRsubset, mat_noise_subset] = extractRepresentativeFRdataset(targetFR, mat_noise, maxSampleSize);


% define percentage of test subset and divide the simulated dataset to
% training and test
test_percent=0.33;
[train_idx, test_idx] = divideSamples(targetFRsubset, test_percent); 
    
% define the parameters of random forest predictor
% OPTIONAL: use cross-validation to find the optimal parameters
% [cvMAE, cvTime] = crossValidateParameters(mat_noise, targetFR, nvalid, ntreevec, mtryvec);
repeat = 1;
    while repeat
        numtrees = input('Set the number of trees for the random forest algorithm ntree [100]  >>');
        if isempty(numtrees)
           numtrees = 100;
           repeat = 0;
        else
           repeat = 0;
        end
    end
repeat = 1;
    while repeat
        mtry = input('Set the number of variables for decision making mtry [20]  >>');
        if isempty(mtry)
           mtry = 20;
           repeat = 0;
        else
           repeat = 0;
        end
    end    
  
if ~exist('regRF_train', 'file') || ~exist('regRF_predict', 'file')   
    disp ' '
    disp 'ERROR: Random forest algorithm not found.'
    disp 'ERROR: Verify that functions regRF_train and regRF_predict are in MatLab path.'
    disp 'SUMOFLUX closing...'
    disp ' '
    return;
end
    
try 
    disp 'Training the random forest predictor...' 
    tic
        [rfmodel] = regRF_train(mat_noise_subset(train_idx,:), targetFRsubset(train_idx), numtrees, mtry);
    toc

    disp 'Testing the random forest predictor...' 
    % assess the performance on the test dataset
    [rfTestOutput] = regRF_predict(mat_noise_subset(test_idx,:), rfmodel);
catch ME
    disp ' '
    disp 'ERROR: Training the predictor failed. Randomforest package errored'
    disp 'ERROR: To check whether Randomforest package is functional, please type'
    disp 'ERROR: >>tutorial_regRF'
    disp 'ERROR: If the tutorial does not run, please, consult '
    disp 'ERROR: https://code.google.com/archive/p/randomforest-matlab/wikis/Introduction.wiki'
    disp 'ERROR: on how to install the package for your OS'
    disp ' '
        disp '*************'
        disp(ME.message)
        disp '*************'
    rfmodel=[];
    mat_noise_subset=[];
    targetFRsubset = [];
    train_idx = [];
    test_idx = [];
    return;
end

    figure;
    plotHeatmapValidation(targetFRsubset(test_idx), rfTestOutput, tagFR);
    xlabel('Real ratios')
    ylabel('SUMOFLUX estimates')

    testMAE = mean(abs(rfTestOutput - targetFRsubset(test_idx)));

    fprintf('Testing MAE = %.2f\n', testMAE);


