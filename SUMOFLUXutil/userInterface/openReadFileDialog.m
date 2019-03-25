function [loadedData,FileName,PathName] = openReadFileDialog(fullPATH, FilterSpec, DialogTitle, DefaultName, MultiSelect, varNames)


repeat = 1;
loadedData = [];
FileName={};
PathName={};
while(repeat)
    [FileName,PathName] = uigetfile(fullfile(fullPATH, FilterSpec),DialogTitle,fullfile(fullPATH, DefaultName), 'MultiSelect', MultiSelect);
    if iscell(FileName)
        disp ' '
        concatFILES = getYNoutput('Concatenate the selected files into one dataset?', 1, 0);
        switch concatFILES
            case 1 %concatenate
                %concatenate into one sample
                loadedData = concatenateDataFromFiles(PathName, FileName, varNames);
                if isempty(loadedData)
                    tryAGAIN = getYNoutput('Error reading file. Do you want to load another file?', 1, 0);
                    switch tryAGAIN
                        case 1
                            repeat = 1;
                        case 0
                            repeat = 0;
                    end
                else
                    repeat = 0;
                end
            case 0
                disp(' ')
                disp('Please, select one file...')
                disp(' ')
                repeat = 1;
        end
    elseif ischar(FileName)
        fprintf('Loading data from %s...\n', FileName)
        if ~isempty(varNames)
            loadedData = loadDataFromFile([PathName, FileName], varNames);
            nonemptyFields = structfun(@(x) ~isempty(x), loadedData);
            if nnz(nonemptyFields(ismember(fieldnames(loadedData), varNames)))==0
                tryAGAIN = getYNoutput('Error reading file. Do you want to load another file?', 1, 0);
                    switch tryAGAIN
                        case 1
                            repeat = 1;
                        case 0
                            repeat = 0;
                    end
            else
                repeat = 0;
            end
        else
            loadedData = FileName;
            repeat = 0;
        end
    else
        PathName = fullPATH;
        FileName = DefaultName;
        loadDefault = getYNoutput(sprintf('Load data from the default file %s?', FileName), 1, 0);
        switch loadDefault
            case 1  %load from default file
                disp(sprintf('Loading data from %s...', FileName))
                if ~isempty(varNames)
                    loadedData = loadDataFromFile([PathName, FileName], varNames);
                    if nnz(structfun(@(x) ~isempty(x), loadedData))==0
                        tryAGAIN = getYNoutput('Error reading file. Do you want to load another file?', 1, 0);
                            switch tryAGAIN
                                case 1
                                    repeat = 1;
                                case 0
                                    repeat = 0;
                            end
                    else     
                        repeat = 0;
                    end
                else
                    loadedData = FileName;
                    repeat = 0;
                end
            case 0 %do not load from default
                tryAGAIN = getYNoutput('Do you want to load another file?', 1, 0);
                switch tryAGAIN
                    case 1
                        repeat = 1;
                    case 0
                        repeat = 0;
                end
        end
    end
end
