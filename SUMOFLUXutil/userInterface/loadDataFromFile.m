function [loadedData] = loadDataFromFile(fileName, varNames)

if ~exist(fileName, 'file')
    disp(sprintf('Error: file %s not found', fileName))
    loadedData = struct();
    return
else
    try
        %get the file extension
        [fDIR,fNAME,EXT] = fileparts(fileName);
        if ismember(EXT, {'.xls', '.xlsx'})
            %read excel file with input data
            [numData, textData] = xlsread(fileName);
            textData = cellfun(@(x)strrep(x, '"', ''),textData, 'UniformOutput', 0);
            textData = cellfun(@(x)strrep(x, '''', ''),textData, 'UniformOutput', 0);
            loadedData = struct;
            if ismember('experimentalData', varNames)
                loadedData.experimentalData = numData;
            end
            if ismember('experimentalStrains', varNames)
                loadedData.experimentalStrains = textData(1,2:end);
            end
            if ismember('isotopes_measured', varNames)
                loadedData.isotopes_measured = textData(2:end,1);
            end
            if ismember('metabolites_measured', varNames)
                loadedData.metabolites_measured = unique(cellfun(@(x)x(1:strfind(x,'_')-1),textData(2:end,1), 'UniformOutput', 0), 'stable');
            end
        elseif isequal(EXT, '.mat')
            loadedData = load(fileName); %load all the variables from the file
            %for each variable which were expected to be in the file, 
            %check whether it is already a field of loadedData
            %and if it is not, add blank field
            for i=1:length(varNames)
                if ~isfield(loadedData, varNames{i})
                    fprintf('WARNING: Variable %s not found in the input file\n', varNames{i})
                    loadedData = setfield(loadedData, varNames{i}, []);
                end
            end
        elseif isequal(EXT, '.m')
            %go to the file directory and evaluate the m file
            curdir = pwd;
            cd(fDIR);
            if ismember('metabolites_measured', varNames)
                loadedData.metabolites_measured = eval(fNAME);
                for i=1:length(varNames)
                    if ~isfield(loadedData, varNames{i})
                        loadedData = setfield(loadedData, varNames{i}, []);
                    end
                end
            end
            if ismember('metabolites_simulated', varNames)
                loadedData.metabolites_simulated = eval(fNAME);
                for i=1:length(varNames)
                    if ~isfield(loadedData, varNames{i})
                        loadedData = setfield(loadedData, varNames{i}, []);
                    end
                end
            end     
            if ismember('fluxRatio_list', varNames)
                loadedData.fluxRatio_list = eval(fNAME);
                for i=1:length(varNames)
                    if ~isfield(loadedData, varNames{i})
                        loadedData = setfield(loadedData, varNames{i}, []);
                    end
                end
            end
            if ismember('labelingStrategy', varNames)
                loadedData.labelingStrategy = eval(fNAME);
                for i=1:length(varNames)
                    if ~isfield(loadedData, varNames{i})
                        loadedData = setfield(loadedData, varNames{i}, []);
                    end
                end
            end
            cd(curdir);
        else
            disp('Error:  unknown file format')
            loadedData = struct;
            return
        end
    catch ME
        fprintf('Error reading file %s\n', fileName)
        disp '*************'
        disp(ME.message)
        disp '*************'
        loadedData = struct;
        return
    end
end
