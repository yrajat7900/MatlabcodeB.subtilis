function [mat_noise, isotopes_measured, metabolites_measured, loadedData] = SUMOFLUXstep3(Smdv, isotopes_simulated) 
% SUMOFLUX step 3: select available measurements from the sumulated data
% and add measurement noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat_noise = [];
isotopes_measured = [];
metabolites_measured = [];
% Extract simulated measurement data from the simulated 13C data
disp ' '
disp '***********************************************************************************************'
disp 'STEP 3: Extract the measurement data from the simulated dataset'
disp ' '
disp 'Provide file containing the list of measured metabolites'
disp '(for E. coli demo, choose inputMeasuredMetabolites_ECOLI113C.m or'
disp 'inputMeasuredMetabolites_ECOLI20U13C, '
disp 'for B. subtilis demo choose inputMeasuredMetabolites_BSUB.m)'
disp ' '
  
% Load experimental data to define which measurements are available
FilterSpec = '*.m; *.mat; *.xls; *.xlsx';
DialogTitle = 'Provide the experimental measurements file';
DefaultName = 'inputMeasuredMetabolites_ECOLI113C.m';

fullSUMOFLUXfilename = mfilename('fullpath');
[SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
parentFolder = strfind(SUMOFLUXpathstr, filesep);
SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
SUMOFLUXpathstr = [SUMOFLUXpathstr, 'SUMOFLUXinput', filesep];
    
varNames = {'metabolites_measured'};
loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'on', varNames);
if ~isempty(loadedData)
        disp(' ')
        disp '***********************************************************************************************'
        disp 'Successfully loaded measurement file'
        metabolites_measured = loadedData.metabolites_measured;
       
        if iscell(isotopes_simulated{1})
            metabolites_simulated = cell(size(isotopes_simulated));
            for i=1:length(isotopes_simulated)
                metabolites_simulated{i} = unique(cellfun(@(x) x(1:strfind(x, '_')-1), isotopes_simulated{i}, 'UniformOutput', 0));
            end
        else
            metabolites_simulated = unique(cellfun(@(x) x(1:strfind(x, '_')-1), isotopes_simulated, 'UniformOutput', 0));
        end 
        %compare measured and simulated metabolites
        try
            if iscell(metabolites_measured{1}) && ~iscell(metabolites_simulated{1})
                if size(metabolites_measured, 1) == 1
                    metabolites_measured = cat(2,metabolites_measured{:})';
                else
                    metabolites_measured = cat(1,metabolites_measured{:});
                end                
            end
            if ~iscell(metabolites_measured{1}) && ~iscell(metabolites_simulated{1})
                unknownMetabolites = setdiff(metabolites_measured, metabolites_simulated);
                if ~isempty(unknownMetabolites)
                    disp 'ERROR: the following measured metabolites were not simulated'
                    disp 'ERROR: or are not contained in the model'
                    for i=1:length(unknownMetabolites)
                        disp(unknownMetabolites{i})
                    end
                    return;
                end
            elseif iscell(metabolites_measured{1}) && iscell(metabolites_simulated{1})
                if length(metabolites_measured) ~= length(metabolites_simulated)
                    disp 'ERROR: Can not assign measured metabolites to the simulated samples'
                    disp 'ERROR: Please, provide either one measurement list,'
                    disp 'ERROR: or a measurement list for each concatenated simulated sample'
                    return;
                else
                    for j=1:length(metabolites_measured)
                        unknownMetabolites = setdiff(metabolites_measured{j}, metabolites_simulated{j});
                        if ~isempty(unknownMetabolites)
                            disp 'ERROR: the following measured metabolites were not simulated'
                            disp 'ERROR: or are not contained in the model'
                            for i=1:length(unknownMetabolites)
                                disp(unknownMetabolites{i})
                            end
                            return;
                        end
                    end
                end
            elseif ~iscell(metabolites_measured{1}) && iscell(metabolites_simulated{1})
                for j=1:length(metabolites_simulated)
                    unknownMetabolites = setdiff(metabolites_measured, metabolites_simulated{j});
                    if ~isempty(unknownMetabolites)
                        disp 'ERROR: the following measured metabolites were not simulated'
                        disp 'ERROR: or are not contained in the model'
                        for i=1:length(unknownMetabolites)
                            disp(unknownMetabolites{i})
                        end
                        return;
                    end
                end
            end
        catch ME
            disp ' '
            disp 'ERROR: measured metabolites file could not be read'
            disp 'ERROR: example file format is in inputMeasuredMetabolites'
            disp ' '
            disp '*************'
            disp(ME.message)
            disp '*************'
            return;
        end
else
    disp 'Error in reading file'
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify measurement noise
noiseDEFAULT = 0.01; % default noise value
repeat = 1;
while repeat    %Inquire the simulation procedure
    noise = input(sprintf('Specify measurement noise for the MDVs [%.2f]  >>', noiseDEFAULT));
    if isempty(noise)
       noise = noiseDEFAULT;
       repeat = 0;
    end
    if ~isnumeric(noise)
        disp('***input error, noise should be between 0 and 1***');
    else
        if noise>=1 || noise <0
            disp('***input error, noise should be between 0 and 1***');
        else
            repeat = 0;
        end
    end
end

if ~iscell(Smdv)
    %preparet the measurement matrix
    mat_noise = Smdv; %prepare the measurement matrix
    %intersect measured metabolites with simulated ones
    [mat_noise, isotopes_measured] = extractMeasurements(mat_noise, isotopes_simulated, metabolites_measured);
    %add experimental noise
    mat_noise = addNoise(mat_noise, noise);
    %re-normalise MDVs after adding noise
    [mat_noise] = normalizeMetDataByIsotopes(mat_noise, isotopes_measured);
else
    mat_noise = cell(size(Smdv));
    isotopes_measured = cell(size(Smdv));
    if iscell(metabolites_measured{1})
        for i=1:length(Smdv)
            %intersect measured metabolites with simulated ones
            [mat_noise{i}, isotopes_measured{i}] = extractMeasurements(Smdv{i}, isotopes_simulated{i}, metabolites_measured{i});
            %add experimental noise
            mat_noise{i} = addNoise(mat_noise{i}, noise);
            %re-normalise MDVs after adding noise
            [mat_noise{i}] = normalizeMetDataByIsotopes(mat_noise{i}, isotopes_measured{i});
        end
        mat_noise = cat(1, mat_noise{:});
        isotopes_measured = cat(1, isotopes_measured{:});
    else
        for i=1:length(Smdv)
            %intersect measured metabolites with simulated ones
            [mat_noise{i}, isotopes_measured{i}] = extractMeasurements(Smdv{i}, isotopes_simulated{i}, metabolites_measured);
            %add experimental noise
            mat_noise{i} = addNoise(mat_noise{i}, noise);
            %re-normalise MDVs after adding noise
            [mat_noise{i}] = normalizeMetDataByIsotopes(mat_noise{i}, isotopes_measured{i});
        end
        mat_noise = cat(1, mat_noise{:});
        if size(isotopes_measured{1},1)>1
            isotopes_measured = cat(1, isotopes_measured{:});
        else
            isotopes_measured = cat(2, isotopes_measured{:});
        end
    end
end
        
