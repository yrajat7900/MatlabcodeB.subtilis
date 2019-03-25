function [fluxVectors, incaModel, sampleM, exitFLAG,...
            Smdv, isotopes_simulated, labelingStrategy] = SUMOFLUXstep1()
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

fluxVectors = [];
incaModel = [];
sampleM = [];
exitFLAG = 0;
Smdv = [];
isotopes_simulated={};
labelingStrategy={};
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
    DefaultName = 'SUMOFLUXsimulatedSample_ECOLI113C.mat';

    fullSUMOFLUXfilename = mfilename('fullpath');
    [SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
    parentFolder = strfind(SUMOFLUXpathstr, filesep);
    SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
    SUMOFLUXpathstr = [SUMOFLUXpathstr, 'SUMOFLUXdata' filesep 'simulated' filesep];
    
    varNames = {'fluxVectors' 'sampleM', 'incaModel'...
                'Smdv', 'isotopes_simulated', 'labelingStrategy'};
    loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'on', varNames);
    if ~isempty(loadedData)
        disp(' ')
        disp '***********************************************************************************************'
        disp 'Successfully loaded pre-simulated dataset:'
        disp 'Variable sampleM contains stoichiometric model information'
        disp 'Variable incaModel contains the model in INCA format'
        disp 'Results of STEP1: variable fluxVectors contains sampled flux distributions'
        disp ' '
        
        sampleM = loadedData.sampleM;
        fluxVectors = loadedData.fluxVectors;
        incaModel = loadedData.incaModel;
        Smdv = loadedData.Smdv;
        isotopes_simulated=loadedData.isotopes_simulated;
        labelingStrategy=loadedData.labelingStrategy;

        clear loadedData
    else
        disp 'Error in reading file'
        return;
    end
else
    % SAMPLE SIMULATION STEP was chosen
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % MODEL INITIALIZATION
    disp '***********************************************************************************************'
    disp 'Provide the model description file'
    disp '(for E. coli demo, choose model_inca_ecoli.m'
    disp 'for B. subtilis demo choose model_inca_bsub.m)'
    disp ' '
  

    % Load simulated data containing results of STEP1 and STEP2
    fullSUMOFLUXfilename = mfilename('fullpath');
    [SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
    parentFolder = strfind(SUMOFLUXpathstr, filesep);
    SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
    SUMOFLUXpathstr = [SUMOFLUXpathstr 'SUMOFLUXinput' filesep 'inputModels' filesep];
    
    FilterSpec = '*.m';
    DialogTitle = 'Provide the model description';
    DefaultName = 'model_inca_ecoli.m';
    
    [FileName,~,modelFunctionPath] = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'off', []);
    if FileName
        [~, modelFunction] = fileparts(FileName);
    else
        disp 'Error reading model file'
        return 
    end

    try 
        curdir = pwd;
        cd(modelFunctionPath);
        [incaModel, sampleM] = initializeModel(modelFunction);
        cd(curdir);
        
        % define main carbon source uptake value
        [~, largestInputCarbonIDX] = sort(sampleM.inp.ncarbons, 'descend');
        largestInputCarbon = sampleM.inp.names(largestInputCarbonIDX(1));
        %if there are no strict constrains, set the largest carbon intake to 10
  
        if nnz(sampleM.param.ub(sampleM.param.ub~=0) == sampleM.param.lb(sampleM.param.ub~=0))==0
            maxUptakeUB = sampleM.param.ub(sampleM.R.SM( ismember(sampleM.M.names, largestInputCarbon),:)<0);
            maxUptakeLB = sampleM.param.lb(sampleM.R.SM( ismember(sampleM.M.names, largestInputCarbon),:)<0);
            if maxUptakeUB>=10 && maxUptakeLB<=10
               fprintf('Setting uptake of %s to 10\n', largestInputCarbon{1});
               sampleM.param.b( ismember(sampleM.M.names, largestInputCarbon)) = -10;
            elseif maxUptakeUB<10
               fprintf('Setting uptake of %s to %.2f\n', largestInputCarbon{1}, maxUptakeUB);
               sampleM.param.b( ismember(sampleM.M.names, largestInputCarbon)) = -maxUptakeUB;
            elseif maxUptakeLB>10
                fprintf('Setting uptake of %s to %.2f\n', largestInputCarbon{1}, maxUptakeLB);
                sampleM.param.b( ismember(sampleM.M.names, largestInputCarbon)) = -maxUptakeLB;
            end
        else %there are strict constrains - do not balance input flux
            [sampleM.excl.names, ~, idx] = union(sampleM.excl.names, sampleM.inp.names, 'stable');
            sampleM.excl.ind = [sampleM.excl.ind, sampleM.inp.ind(idx)];
            sampleM.excl.num = length(sampleM.excl.names);           
        end
       
        % define exchange flux magnitude (max(exchange/net))
        defaultExchangeFlux = 1; % default sample size
        repeat = 1;
        while repeat    %Inquire the simulation procedure
            exchangeFlux = input('Specify exchange flux magnitude (relative to the net flux) [1]  >>');
            if isempty(exchangeFlux)
              exchangeFlux = defaultExchangeFlux;
              repeat = 0;
            end
            if ~isnumeric(exchangeFlux)
                disp('***input error, noise should be an integer***');
            else
                if exchangeFlux>100 || exchangeFlux <0
                    disp 'WARNING: Exchange flux magnitude should be non-negative'
                    disp 'WARNING: Exchange flux magnitude >100 is rare and might lead to inaccurate estimates'
                    continueWithCurrentParameters = getYNoutput(sprintf('Are you sure you want to set exchange flux magnitude = %d?', exchangeFlux), 0, 0);
                    if continueWithCurrentParameters
                        repeat = 0;
                    end
                else
                    repeat = 0;
                end
            end
        end
        if nnz(sampleM.param.max_exch(sampleM.R.irrev==0)>=0)
            disp 'WARNING: setting exchange flux values only for fluxes'
            disp 'WARNING: without constrains specified in the model file'
        end
        sampleM.param.max_exch(sampleM.R.irrev==0 & sampleM.param.max_exch==-1) = exchangeFlux;
    catch ME
        disp ' '
        disp '*************'
        disp(ME.message)
        disp '*************'
        disp 'Error in initializing model. Check the format of the provided file'
        disp 'Example files are model_inca_ecoli.m and model_inca_bsub.m'
        disp ' '
        return
    end
    disp 'Model initialization successful'
    disp ' '
    disp '***********************************************************************************************'
    disp 'STEP 1. Sampling flux vectors'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ask whether simulated flux vectors should be loaded from file
    % Specify number of data points in the sample
    sampleSize = 10000; % default sample size
    repeat = 1;
    while repeat    %Inquire the simulation procedure
        sampleSize = input('Specify number of data points to simulate [10000]  >>');
        if isempty(sampleSize)
           sampleSize = 10000;
           repeat = 0;
        end
        if ~isnumeric(sampleSize)
            disp('***input error, noise should be an integer***');
        else
            if sampleSize>50000 || sampleSize <1000
                disp 'WARNING: For demonstration, it is recommended that sampleSize is >1000 and <50000'
                disp 'WARNING: Choose >50000 only if computation parallelization is available'
                continueWithCurrentParameters = getYNoutput(sprintf('Are you sure you want to simulate %d points?', sampleSize), 0, 0);
                if continueWithCurrentParameters
                    repeat = 0;
                end
            else
                repeat = 0;
            end
        end
    end

    % to ensure uniform representation of certain flux ratios, provide them 
    % as input to the flux sampling procedure
    ratioConstrains = sampleM.param.ratioConstrains;
    %check that constrains are in the model reactions
    if ~isempty(ratioConstrains)
        % define number of fluxes sampled for each segment of flux ratio values
        segmentFluxNumber = floor(sampleSize/16);
        disp 'STEP 1. Sampling flux vectors (with ratio constrains) in progress...'
        tic 
        fluxVectors = simulateWithWindowRatios(sampleM, ratioConstrains, segmentFluxNumber);       
        toc
    else
        disp 'STEP 1. Sampling flux vectors in progress...'
        sampleM.param.hr.points_hr = sampleSize; % unique fluxes
        tic
            fluxVectors = simulateWithWindowRatios(sampleM);       
        toc
    end
    % Provide an option to save fluxVectors to file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Save to file?
    FilterSpec = {'*.mat'};
    DialogTitle = 'Save fluxVectors sampling results';
    DefaultName = 'mySUMOFLUXfluxVectors';
    
    repeatSAVE = 1;
    while repeatSAVE
        
        saveFileName = openSaveFileDialog(FilterSpec, DialogTitle, DefaultName);
        if ~isempty(saveFileName)
            try
              save(saveFileName, 'fluxVectors', 'sampleM', 'incaModel');
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end