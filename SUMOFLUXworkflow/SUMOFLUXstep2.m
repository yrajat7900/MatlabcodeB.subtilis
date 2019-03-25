function [Smdv, isotopes_simulated, labelingStrategy, exitFLAG, fluxVectors, incaModel, sampleM] = SUMOFLUXstep2(fluxVectors, incaModel, sampleM)
% SUMOFLUXstep1 is the first step of SUMOFLUX workflow:
% Sample flux vectors given a stoichiometric model and constraints
% Model should be provided in the INCA1.4-software format
% (see example files model_inca_ecoli.m and model_inca_bsub.m)
% !IMPORTANT! Although the flux sampling procedure does not require INCA
% software, the model initialization step is using INCA software. 
% Therefore, INCA software is required to perform this step. 
% INCAv1.4 software is freely available at
% http://mfa.vueinnovations.com/about
% OUTPUT: incaModel in inca software format, 
% OUTPUT: sampleM in SUMOFLUX model format
% OUTPUT: fluxVectors - simulated fluxVectors 
% OUTPUT: exitFLAG = 1 if the user chose to exit SUMOFLUX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PAREMETERS: fixed flux (glucose)
% PAREMETERS: exchange flux magnitude 1
% PAREMETERS: fixed flux ratios

Smdv = [];
isotopes_simulated = {};
labelingStrategy = {};
exitFLAG = 0;

%Check whether required INCA files are in the MatLab path
if ~exist('reaction', 'file') || ~exist('model', 'file') || ~exist('simulate', 'file') 
    disp 'WARNING: Required INCA files not found'
    loadSimulatedData = getYNoutput('Load presimulated data from file?', 1, 1);
    if loadSimulatedData==0
        disp 'Please, add INCA software directory to MatLab path and try again'
        return;
    end
    if loadSimulatedData==-1
        exitFLAG = 1;
        return;
    end
else
    disp 'WARNING: Sample simulation with INCA software is a time-consuming step'
    disp 'WARNING: Approx. timing for 10000 samples of E. coli central carbon metabolism:'
    disp 'WARNING: STEP1. Flux sampling ~30s'
    disp 'WARNING: STEP2. Labeling patterns simulation ~1h'
    disp 'WARNING: You can skip these steps and load presimulated samples from file'
    disp ' '
    loadSimulatedData = getYNoutput('Load presimulated data from file?', 1, 1);
    if loadSimulatedData==-1
        exitFLAG = 1;
        return;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If load from file option was chosen, load from file
if loadSimulatedData==1 %Load presimulated data option was chosen
    disp '***********************************************************************************************'
    disp 'Provide pre-simulated data file with results from STEP1 and STEP 2'
    disp '(for E. coli demo, choose SUMOFLUXsimulatedSample_ECOLI113C.mat or'
    disp 'SUMOFLUXsimulatedSample_ECOLI20U13C.mat,' 
    disp 'for B. subtilis demo choose SUMOFLUXsimulatedSampleBSUB.mat)'
    disp ' '
  
    % Load simulated data containing results of STEP1 and STEP2
    FilterSpec = '*.mat';
    DialogTitle = 'Provide the simulated data file';
    DefaultName = 'SUMOFLUXsimulatedSampleECOLI_113C.mat';

    fullSUMOFLUXfilename = mfilename('fullpath');
    [SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
    parentFolder = strfind(SUMOFLUXpathstr, filesep);
    SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
    SUMOFLUXpathstr = [SUMOFLUXpathstr, 'SUMOFLUXdata' filesep 'simulated' filesep];
       
    
    varNames = {'fluxVectors' 'sampleM', 'incaModel', 'Smdv', 'isotopes_simulated', 'labelingStrategy'};
    loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'on', varNames);

    if ~isempty(loadedData)
        disp(' ')
        disp '***********************************************************************************************'
        disp 'Successfully loaded pre-simulated dataset:'
        disp 'Variable sampleM contains stoichiometric model information'
        disp 'Variable incaModel contains the model in INCA format'
        disp 'Results of STEP1: variable fluxVectors contains sampled flux distributions'
        disp 'Results of STEP2: variable Smdv contains simulated labeling patterns'
        disp 'Results of STEP2: variable isotopes_simulated contains isotope names'
        disp 'Results of STEP2: variable labelingStrategy contains the labelingStrategy'
        disp ' '
        
        sampleM = loadedData.sampleM;
        fluxVectors = loadedData.fluxVectors;
        incaModel = loadedData.incaModel;
        Smdv = loadedData.Smdv;
        isotopes_simulated = loadedData.isotopes_simulated;
        labelingStrategy = loadedData.labelingStrategy;
        
        return;
    else
        disp 'Error in reading file'
        return;
    end
else
% Continue with simulation step
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 2
    % Simulate 13C labeling patterns
    disp ' '
    disp '***********************************************************************************************'
    disp 'STEP 2. Simulating metabolite MDVs'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % LABELING STRATEGY 
    disp '***********************************************************************************************'
    disp 'Provide file defining the labeling strategy'
    disp '(for E. coli demo, choose inputLabelingStrategy_Glucose_100_113C.m or'
    disp 'inputLabelingStrategy_Glucose_20_U13C_80_natural.m,' 
    disp 'for B. subtilis demo choose inputLabelingStrategy_Glucose_80_113C_20_U13C.m)'
    disp ' '
  
  
    fullSUMOFLUXfilename = mfilename('fullpath');
    [SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
    parentFolder = strfind(SUMOFLUXpathstr, filesep);
    SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
    SUMOFLUXpathstr = [SUMOFLUXpathstr, 'SUMOFLUXinput' filesep];
    
    FilterSpec = '*.m';
    DialogTitle = 'Provide the labeling strategy file';
    DefaultName = 'inputLabelingStrategy.m';
    varNames = {'labelingStrategy'};
    
    loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'off',varNames);
    
    if ~isempty(loadedData)
        disp 'Successfully loaded labeling strategy from file'
        labelingStrategy = loadedData.labelingStrategy;
        %check the labeling strategy according to the provided model
        labelingStrategy = getIsotopeLabelingFromCarbonLabeling(labelingStrategy, sampleM);
        if isempty(labelingStrategy)
            disp 'ERROR: Loading labeling strategy from file failed'
            disp 'ERROR: Check whether the file format is correct'
            return;
        end
    else
        disp 'ERROR: Loading labeling strategy from file failed'
        return;
    end
    disp(' ')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Metabolites to be simulated 
    disp '***********************************************************************************************'
    disp 'Provide file containing the list of isotopes to simulate'
    disp '(for E. coli or B. subtilis demo, choose inputSimulateMetabolites.m)'
    disp ' '
  
  
    fullSUMOFLUXfilename = mfilename('fullpath');
    [SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
    parentFolder = strfind(SUMOFLUXpathstr, filesep);
    SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
    SUMOFLUXpathstr = [SUMOFLUXpathstr 'SUMOFLUXinput' filesep];
    
    FilterSpec = '*.m';
    DialogTitle = 'Provide the file with the isotope list';
    DefaultName = 'inputSimulateMetabolites.m';
    varNames = {'metabolites_simulated'};
    
    loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'off',varNames);
    if ~isempty(loadedData)
        simulateMetabolites = loadedData.metabolites_simulated;
        %check the simulated list according to the provided model
        simulateMetabolites = checkSimulateMetabolites(simulateMetabolites, sampleM);
        if isempty(simulateMetabolites)
            disp 'ERROR: Loading isotope list from file failed'
            disp 'ERROR: Check whether the file format is correct'
            return;
        end
        disp 'Successfully loaded isotope list from file'
        disp ' '

    else
        disp 'ERROR: Loading isotope list from file failed'
        disp ' '
        return;
    end
    disp(' ')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    startSimulation = getYNoutput('Start simulation? (Time-comsuming step)', 1, 1);
    if startSimulation == -1
        exitFLAG = 1;
        return;
    elseif startSimulation == 1
        disp 'Simulating metabolite MDVs with INCA...'

        [Smdv, fluxVectors, isotopes_simulated] = simulateLabelingData(incaModel, fluxVectors, labelingStrategy, simulateMetabolites);

        % Option to save the simulation results to file
        % Save to file?
        FilterSpec = {'*.mat'};
        DialogTitle = 'Save simulation results';
        DefaultName = 'mySUMOFLUXsimulatedSample';
        
        repeatSAVE = 1;
        while repeatSAVE
            saveFileName = openSaveFileDialog(FilterSpec, DialogTitle, DefaultName);
            if ~isempty(saveFileName)
                try
                    save(saveFileName, 'fluxVectors', 'sampleM', 'incaModel', 'Smdv', 'isotopes_simulated', 'labelingStrategy');
                    repeatSAVE = 0;
                catch ME
                    disp 'WARNING: MatLab error saving to file'
                    disp '*************'
                    disp(ME.message)
                    disp '*************'
                    disp 'SUMOFLUX workflow can continue'
                    repeatSAVE = getYNoutput('Choose another file to save the workflow?', 1, 0);
                end
            else    
                repeatSAVE = 0;
            end
        end
    end
end