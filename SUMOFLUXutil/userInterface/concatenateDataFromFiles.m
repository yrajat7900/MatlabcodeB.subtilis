function [loadedData] = concatenateDataFromFiles(pathName, fileNames, varNames)
%concatenateDataFromFiles reads several files and concatenates them into 
%an array of structures. This is used when using data from different
%experiments in one. 
%INPUT: pathName - path to the files
%INPUT: fileNames - names of files to concatenate
%INPUT: varNames - expected variables to be concatenated

%Load all the data into an array of structures
emptyStruct = struct;
for i=1:length(varNames)
    emptyStruct = setfield(emptyStruct, varNames{i}, []);
end

loadedData = repmat(emptyStruct, length(fileNames), 1);
for i=1:length(fileNames)
    curData = loadDataFromFile([pathName fileNames{i}], varNames);
    
    for j=1:length(varNames)
        loadedData(i) = setfield(loadedData(i), varNames{j}, getfield(curData, varNames{j}));
    end
  
end

%Check that field sizes and fluxVectors are the same, if available
for i=1:length(varNames)
    testFieldSize = arrayfun(@(x) size(getfield(x, varNames{i}),2), loadedData);
    if length(unique(testFieldSize)) > 1
        %data have different dimensions, not possible to concatenate
        disp 'ERROR: unable to concatenate data with different dimensions'
        fprintf('ERROR: dimensions of variable %s are not consistent\n', varNames{i});
        loadedData = [];
        return;
    end
end

%check whether flux vectors are identical

if ismember('fluxVectors', varNames)
    fluxVectors = loadedData(1).fluxVectors;
    for j=2:length(loadedData)
        if nnz(size(fluxVectors.net) ~= size(loadedData(j).fluxVectors.net))
           disp 'ERROR: to concatenate simulated data, flux vectors have to be the same'
           loadedData = [];
           return
        else
            if nnz(fluxVectors.net ~= loadedData(j).fluxVectors.net)>0 ||...
               nnz(fluxVectors.ex ~= loadedData(j).fluxVectors.ex)>0 ||...
               nnz(fluxVectors.f ~= loadedData(j).fluxVectors.f)>0 ||...
               nnz(fluxVectors.b ~= loadedData(j).fluxVectors.b)>0
                    disp 'ERROR: to concatenate simulated data, flux vectors have to be the same'
                    loadedData = [];
                    return;
            end
        end
    end        
end

if ismember('Smdv', varNames)
    if ~isempty(loadedData(1).Smdv)
        Smdv = cell(size(loadedData));
        for i=1:length(loadedData)
            Smdv{i} = loadedData(i).Smdv;
        end
        loadedData(1).Smdv = Smdv;    
    end
end

if ismember('isotopes_simulated', varNames)
    if ~isempty(loadedData(1).isotopes_simulated)
        isotopes_simulated = cell(size(loadedData));
        for i=1:length(loadedData)
            isotopes_simulated{i} = loadedData(i).isotopes_simulated;
        end
        loadedData(1).isotopes_simulated = isotopes_simulated;
    end
end

if ismember('labelingStrategy', varNames)
    if ~isempty(loadedData(1).labelingStrategy)
        labelingStrategy = cell(size(loadedData));
        for i=1:length(loadedData)
            labelingStrategy{i} = loadedData(i).labelingStrategy;
        end
        loadedData(1).labelingStrategy = labelingStrategy; 
    end   
end

if ismember('experimentalData', varNames)
    if ~isempty(loadedData(1).experimentalData)
        experimentalData = cell(size(loadedData));
        for i=1:length(loadedData)
            experimentalData{i} = loadedData(i).experimentalData;
        end
        loadedData(1).experimentalData = experimentalData; 
    end   
end

if ismember('experimentalStrains', varNames)
    if ~isempty(loadedData(1).experimentalStrains)
        for i=2:length(loadedData)
            if ~isequal(loadedData(1).experimentalStrains, loadedData(i).experimentalStrains)
                disp 'ERROR: Can not concatenate data from experiments with different strains'
                disp 'ERROR: Please, make sure the strain names and order are the same'
                loadedData = [];
                return
            end
        end
    end   
end

if ismember('metabolites_measured', varNames)
    if ~isempty(loadedData(1).metabolites_measured)
        metabolites_measured = cell(size(loadedData));
        for i=1:length(loadedData)
            metabolites_measured{i} = loadedData(i).metabolites_measured;
        end
        loadedData(1).metabolites_measured = metabolites_measured; 
    end   
end

if ismember('experimentalData', varNames)
    loadedData = loadedData(1);
end
        
                
