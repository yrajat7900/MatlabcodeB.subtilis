function SUMOFLUXworkflow()
% SUMOFLUXworkflow performs 5 steps of building a flux ratio predictor
  
clear all
%Check wjether SUMOFLUX is in path, and if not, add
fullSUMOFLUXfilename = mfilename('fullpath');
[SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
parentPath = [filesep 'SUMOFLUX' filesep];
SUMOFLUXpathstr = SUMOFLUXpathstr(1:strfind(SUMOFLUXpathstr, parentPath)+length(parentPath)-2);
%check whether SUMOFLUX is in path
pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
  onPath = any(strcmpi(SUMOFLUXpathstr, pathCell));
else
  onPath = any(strcmp(SUMOFLUXpathstr, pathCell));
end
if ~onPath
    addpath(genpath(SUMOFLUXpathstr));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp ' '
disp '***********************************************************************************************'
disp 'Welcome to SUMOFLUX workflow demo. The workflow consists of 5 steps:'
disp '1. Sample flux distributions through the specified metabolic network'
disp '2. For each flux distribution, simulate metabolite labeling patterns given the substrate label'
disp 'NOTE: (previsouly simulated datasets from steps 1. and 2. can be loaded to '
disp 'NOTE: continue the workflow from step 3.)'
disp '3. From the simulated dataset, extract the measured metabolites and add noise'
disp '4. Specify the flux ratio of interest'
disp '5. Divide the simulated dataset into training and testing sets, train and test the predictor'
disp ' '
disp 'NOTE: For the simulation step, INCAv1.4 software is required (freely available at http://mfa.vueinnovations.com/about)'
disp 'NOTE: The simulation step is time-consuming (For this example, estimated time ~1.5 hours)'
disp 'NOTE: You can omit this step and download presimulated datasets for demonstration'
disp ' '
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Waiting for input to continue
continueKey = input('Press any key to start, or Q to exit...', 's');
if isequal(upper(continueKey), 'Q')
    % EXIT SUMOFLUX
    repeatSAVE = 1;
    exitOPTION = 1;
    while repeatSAVE
        [ynOUTPUT, fullSaveName] = exitSUMOFLUX(exitOPTION);
        if ynOUTPUT
            if ~isempty(fullSaveName)
                %Save the workspace to a mat file
                try
                    save(fullSaveName);
                    return;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp '*************'
                    disp(ME.message)
                    disp '*************'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                    exitOPTION=0;
                    if ~repeatSAVE
                        return;
                    end
                end
            else
                return;
            end
        else
            repeatSAVE = 0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%STEP1: initialize INCA model and sample flux distributions
disp '***********************************************************************************************'
[fluxVectors, incaModel, sampleM, exitFLAG,...
            Smdv, isotopes_simulated, labelingStrategy] = SUMOFLUXstep1();
if exitFLAG %User chose to exit
   disp 'Exiting SUMOFLUX'
   % EXIT SUMOFLUX
    repeatSAVE = 1;
    while repeatSAVE
        [~, fullSaveName] = exitSUMOFLUX(0);
        if ~isempty(fullSaveName)
            %Save the workspace to a mat file
            try
                save(fullSaveName);
                return;
            catch ME
                disp 'WARNING: MatLab error saving to file'
                disp '*************'
                disp(ME.message)
                disp '*************'
                repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
            end
        else
            return;
        end
    end
    return
end
clear exitFLAG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(fluxVectors) && ~isempty(incaModel) && ~isempty(sampleM)
    useExistingSample = 0;
    if ~isempty(fluxVectors.net)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp ' '
        disp 'Successfully completed STEP1: flux sampling'
        disp ' '
        %%Waiting for input to continue
        continueKey = input('Press any key to continue to STEP2, or Q to exit...', 's');
        if isequal(upper(continueKey), 'Q')
            % EXIT SUMOFLUX
            repeatSAVE = 1;
            exitOPTION = 1;
            while repeatSAVE
                [ynOUTPUT, fullSaveName] = exitSUMOFLUX(exitOPTION);
                if ynOUTPUT
                    if ~isempty(fullSaveName)
                        %Save the workspace to a mat file
                        try
                            save(fullSaveName);
                            return;
                        catch ME
                            disp 'WARNING: MatLab error saving to file'
                            disp '*************'
                            disp(ME.message)
                            disp '*************'
                            repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                            exitOPTION=0;
                            if ~repeatSAVE
                                return;
                            end
                        end
                    else
                        return;
                    end
                else
                    repeatSAVE = 0;
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(Smdv) && ~isempty(isotopes_simulated) && ~isempty(labelingStrategy)
            useExistingSample = getYNoutput('Use existing simulated sample?', 1, 0);
        end
        if useExistingSample==0
            disp '***********************************************************************************************'
            [Smdv, isotopes_simulated, labelingStrategy, exitFLAG,...
                fluxVectors, incaModel, sampleM] = SUMOFLUXstep2(fluxVectors, incaModel, sampleM);
            if exitFLAG %User chose to exit
                disp 'Exiting SUMOFLUX'
                % EXIT SUMOFLUX
                repeatSAVE = 1;
                while repeatSAVE
                    [~, fullSaveName] = exitSUMOFLUX(0);
                    if ~isempty(fullSaveName)
                        %Save the workspace to a mat file
                        try
                            save(fullSaveName);
                            return;
                        catch ME
                            disp 'WARNING: MatLab error saving to file'
                            disp '*************'
                            disp(ME.message)
                            disp '*************'
                            repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                        end
                    else
                        return;
                    end
                end
                return
            end
            clear exitFLAG
            if ~isempty(Smdv) && ~isempty(isotopes_simulated)
                disp ' '
                disp 'Successfully completed STEP3: extracting measurement data from simulated data'
                disp ' '
            else
                disp ' '
                disp 'ERROR: simulated sample does not exist (variable Smdv or isotopes_simulated)'
                disp 'Exiting SUMOFLUX...'
                disp ' '
                % EXIT SUMOFLUX
                    repeatSAVE = 1;
                    while repeatSAVE
                        [~, fullSaveName] = exitSUMOFLUX(0);
                        if ~isempty(fullSaveName)
                            %Save the workspace to a mat file
                            try
                                save(fullSaveName);
                                return;
                            catch ME
                                disp 'WARNING: MatLab error saving to file'
                                disp '*************'
                                disp(ME.message)
                                disp '*************'
                                repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                            end
                        else
                            return;
                        end
                    end
                    return
            end
        else
            disp 'Using existing simulated sample from STEP2'
            disp ' '
        end
    else
        disp 'ERROR: no fluxes were sampled. Exiting SUMOFLUX' 
         % EXIT SUMOFLUX
        repeatSAVE = 1;
        while repeatSAVE
            [~, fullSaveName] = exitSUMOFLUX(0);
            if ~isempty(fullSaveName)
                %Save the workspace to a mat file
                try
                    save(fullSaveName);
                    return;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp '*************'
                    disp(ME.message)
                    disp '*************'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                end
            else
                return;
            end
        end
        return;
    end
else
    if isempty(fluxVectors)
        disp 'ERROR: no fluxes were sampled. Exiting SUMOFLUX'
        % EXIT SUMOFLUX
        repeatSAVE = 1;
        while repeatSAVE
            [~, fullSaveName] = exitSUMOFLUX(0);
            if ~isempty(fullSaveName)
                %Save the workspace to a mat file
                try
                    save(fullSaveName);
                    return;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp '*************'
                    disp(ME.message)
                    disp '*************'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                end
            else
                return;
            end
        end
        return;
    end
    if isempty(incaModel)
        disp ' '
        disp 'WARNING: INCA model was not initialized'
        disp 'WARNING: SUMOFLUX will continue with loaded data from STEP1 and STEP2'
        disp ' '
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3
% Extract measured metabolites and add noise
if ~exist('Smdv', 'var') || ~exist('isotopes_simulated', 'var')
    disp 'Error: variables Smdv (simulated sample) and isotopes_simulated are not found'
    disp 'Try reloading demo files or resimulating the sample'
    disp 'Exiting SUMOFLUX'
    % EXIT SUMOFLUX
       [~, fullSaveName] = exitSUMOFLUX(0);
       if ~isempty(fullSaveName)
           %Save the workspace to a mat file
           save(fullSaveName);
       end
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
continueKey = input('Press any key to continue to STEP3, or Q to exit...', 's');
if isequal(upper(continueKey), 'Q')
    % EXIT SUMOFLUX
    % EXIT SUMOFLUX
    repeatSAVE = 1;
    exitOPTION = 1;
    while repeatSAVE
        [ynOUTPUT, fullSaveName] = exitSUMOFLUX(exitOPTION);
        if ynOUTPUT
            if ~isempty(fullSaveName)
                %Save the workspace to a mat file
                try
                    save(fullSaveName);
                    return;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp '*************'
                    disp(ME.message)
                    disp '*************'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                    exitOPTION=0;
                    if ~repeatSAVE
                        return;
                    end
                end
            else
                return;
            end
        else
            repeatSAVE = 0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp '***********************************************************************************************'
[mat_noise, isotopes_measured, metabolites_measured, loadedData] = SUMOFLUXstep3(Smdv, isotopes_simulated);
if isempty(mat_noise) || isempty(isotopes_measured) || isempty(metabolites_measured)
    disp 'Error: Measured metabolites could not be extracted from the simulated sample.'
    disp 'Make sure the metabolite and fragment names are the same'
    disp 'Exiting SUMOFLUX'
    % EXIT SUMOFLUX
    repeatSAVE = 1;
    while repeatSAVE
        [~, fullSaveName] = exitSUMOFLUX(0);
        if ~isempty(fullSaveName)
            %Save the workspace to a mat file
            try
                save(fullSaveName);
                return;
            catch ME
                disp 'WARNING: MatLab error saving to file'
                disp '*************'
                disp(ME.message)
                disp '*************'
                repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
            end
        else
            return;
        end
    end
    return
end
%check whether loadedData also contains experimental data, 
%if the user chose to load experimental file
if isfield(loadedData, 'experimentalData')
    experimentalData = loadedData.experimentalData;
end
if isfield(loadedData, 'experimentalStrains')
    experimentalStrains = loadedData.experimentalStrains;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 4
% Define flux ratios of interest
if ~exist('mat_noise', 'var') || ~exist('fluxVectors', 'var')
    disp 'Error: variables mat_noise (training input) and fluxVectors are not found'
    disp 'Try reloading demo files or resimulating the sample'
    disp 'Exiting SUMOFLUX'
    % EXIT SUMOFLUX
    repeatSAVE = 1;
    while repeatSAVE
        [~, fullSaveName] = exitSUMOFLUX(0);
        if ~isempty(fullSaveName)
            %Save the workspace to a mat file
            try
                save(fullSaveName);
                return;
            catch ME
                disp 'WARNING: MatLab error saving to file'
                disp '*************'
                disp(ME.message)
                disp '*************'
                repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
            end
        else
            return;
        end
    end
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp ' '
disp 'Successfully completed STEP3: extracting measurement data from simulated data'
disp ' '
%%Waiting for input to continue
continueKey = input('Press any key to continue to STEP4, or Q to exit...', 's');
if isequal(upper(continueKey), 'Q')
    % EXIT SUMOFLUX
    repeatSAVE = 1;
    exitOPTION = 1;
    while repeatSAVE
        [ynOUTPUT, fullSaveName] = exitSUMOFLUX(exitOPTION);
        if ynOUTPUT
            if ~isempty(fullSaveName)
                %Save the workspace to a mat file
                try
                    save(fullSaveName);
                    return;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp '*************'
                    disp(ME.message)
                    disp '*************'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                    exitOPTION=0;
                    if ~repeatSAVE
                        return;
                    end
                end
            else
                return;
            end
        else
            repeatSAVE = 0;
        end
    end
end
% Provide the choice of flux ratio of interest from fluxRatio_list
disp '***********************************************************************************************'
fluxRatio_list = SUMOFLUXstep4();
if ~isempty(fluxRatio_list)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp ' '
    disp 'Successfully completed STEP4: defining flux ratios'
    disp ' '
    %%Waiting for input to continue
    continueKey = input('Press any key to continue to STEP5, or Q to exit...', 's');
    if isequal(upper(continueKey), 'Q')
         % EXIT SUMOFLUX
        repeatSAVE = 1;
        exitOPTION = 1;
        while repeatSAVE
            [ynOUTPUT, fullSaveName] = exitSUMOFLUX(exitOPTION);
            if ynOUTPUT
                if ~isempty(fullSaveName)
                    %Save the workspace to a mat file
                    try
                        save(fullSaveName);
                        return;
                    catch ME
                        disp 'WARNING: MatLab error saving to file'
                        disp '*************'
                        disp(ME.message)
                        disp '*************'
                        repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                        exitOPTION=0;
                        if ~repeatSAVE
                            return;
                        end
                    end
                else
                    return;
                end
            else
                repeatSAVE = 0;
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nRatios = length(fluxRatio_list);
    repeat = 1;
    while repeat
        disp ' '
        disp '***********************************************************************************************'
        disp 'STEP 4: Choose a flux ratio of interest:'
        disp ' '
        for i=1:length(fluxRatio_list)
            ratioName = fluxRatio_list{i,1};
            fprintf('    %d: %s\n', i, ratioName{1});
        end
        disp(' ')

        chosenFR = input('Choose flux ratio of interest: [exit]  >>');
        if isempty(chosenFR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % EXIT SUMOFLUX
            exitOPTION = 1;
            repeatEXIT = 1;
            while repeatEXIT
                [ynOUTPUTexit, fullSaveName] = exitSUMOFLUX(exitOPTION);
                if ynOUTPUTexit
                    if ~isempty(fullSaveName)
                        %Save the workspace to a mat file
                        try
                             save(fullSaveName);
                             return;
                        catch ME
                            disp 'WARNING: MatLab error saving to file'
                            disp '*************'
                            disp(ME.message)
                            disp '*************'
                            repeatChooseFile = getYNoutput('Choose another file to save the workflow?', 1, 0);
                            if repeatChooseFile
                                exitOPTION = 0;
                                repeatEXIT = 1;
                            else
                                return
                            end
                        end
                    else
                        return;
                    end
                else
                    repeat=1;
                    repeatEXIT = 0;
                end
            end
        elseif chosenFR<1 || chosenFR>nRatios
            disp('***input error, try again***');
        else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [rfmodel, mat_noise_subset, targetFRsubset, train_idx, test_idx, tagFR] = ...
            SUMOFLUXstep5(mat_noise, fluxVectors, sampleM, fluxRatio_list, chosenFR);
            repeat=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
             if ~isempty(rfmodel)
                applyToExperimentalData = getYNoutput('Apply the predicor to experimental data?', 1, 0);

                if applyToExperimentalData
                    useExistingData = 0;
                    if exist('experimentalData', 'var') && exist('experimentalStrains', 'var')...
                            && exist('metabolites_measured', 'var')
                       useExistingData = getYNoutput('Use previsouly loaded experimental data?', 1, 0);
                    end
                    if ~useExistingData 
                        [experimentalData, experimentalStrains, metabolites_measured]=...
                        SUMOFLUXloadExperimentalData(isotopes_measured);    
                    end
                    if ~isempty(experimentalData) && ~isempty(experimentalStrains)...
                            && ~isempty(metabolites_measured)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                       
                       [experimentalPrediction,predictionQuantiles,experimentalMeanPrediction] = ...
                        SUMOFLUXapply(rfmodel, mat_noise_subset, targetFRsubset, train_idx, tagFR,...
                                    experimentalData, experimentalStrains);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    else
                        disp ' '
                        disp 'ERROR: Experimental data is empty'
                        disp ' '
                    end
                end
             end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    disp 'No flux ratios were chosen. Exiting SUMOFLUX'
    repeatSAVE = 1;
    while repeatSAVE
        [~, fullSaveName] = exitSUMOFLUX(0);
        if ~isempty(fullSaveName)
            %Save the workspace to a mat file
            try
                save(fullSaveName);
                return;
            catch ME
                disp 'WARNING: MatLab error saving to file'
                disp '*************'
                disp(ME.message)
                disp '*************'
                repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
            end
        else
            return;
        end
    end
end

