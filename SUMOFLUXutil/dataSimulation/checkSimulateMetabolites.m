function simulateMetabolites = checkSimulateMetabolites(simulateMetabolites, varargin)
% function checkSimulateMetabolites(simulateMetabolites, varargin):
% Check whether provided simulateMetabolites cell array has the correct format;
% If stoichiometric model is provided as secon dinput argument, 
% check whether the metabolites in simulateMetabolites belong to the model 
% and have the same number of carbons

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~iscell(simulateMetabolites)
    disp 'ERROR: simulatemetabolites should be a cell array in the following format:'
    disp 'ERROR: FragmentName: MetaboliteName @ carbon indeces'
    disp 'ERROR: Example:'
    disp 'ERROR: PYR12: PYR @ 1 2'
    simulateMetabolites = [];
    return;
end 
%remove extra spaces from simulateMetabolites
simulateMetabolites = cellfun(@(x) strtrim(regexprep(x,' +',' ')), simulateMetabolites, 'UniformOutput', 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, check that the format is corrct: 
% 'FragmentName: MetaboliteName @ carbon indeces'
fragmentNames = cellfun(@(x) x(1:strfind(x, ':')-1), simulateMetabolites, 'UniformOutput', 0);
emptyFragmentNames = cellfun(@(x) isempty(x), fragmentNames);
%if there are empty elements in fragmentNames, display error message
if nnz(emptyFragmentNames)
    disp 'ERROR: Incorrect Fragment format in simulateMetabolites.'
    disp 'ERROR: Fragments should have the following format:'
    disp 'ERROR: FragmentName: MetaboliteName @ carbon indeces'
    disp 'ERROR: Example:'
    disp 'ERROR: PYR12: PYR @ 1 2'
    disp 'ERROR: Following fragments have incorrect format:'
    emptyFragmentNames = find(emptyFragmentNames);
    for i=1:length(emptyFragmentNames)
        disp(simulateMetabolites{emptyFragmentNames(i)})
    end
    simulateMetabolites = [];
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check whether all fragments have carbon indeces
fragmentCarbons = cellfun(@(x) x(strfind(x, '@')+1:end), simulateMetabolites, 'UniformOutput', 0);
fragmentCarbons = cellfun(@(x) str2num(x), fragmentCarbons, 'UniformOutput', 0);
emptyFragmentCarbons = cellfun(@(x) isempty(x), fragmentCarbons);
%if there are empty elements in fragmentNames, display error message
if nnz(emptyFragmentCarbons)
    disp 'ERROR: Incorrect Fragment carbon format in simulateMetabolites.'
    disp 'ERROR: Fragments should have the following format:'
    disp 'ERROR: FragmentName: MetaboliteName @ carbon indeces'
    disp 'ERROR: Example:'
    disp 'ERROR: PYR12: PYR @ 1 2'
    disp 'ERROR: Following fragments have incorrect format:'
    emptyFragmentNames = find(emptyFragmentCarbons);
    for i=1:length(emptyFragmentNames)
        disp(simulateMetabolites{emptyFragmentNames(i)})
    end
    simulateMetabolites = [];
    return;
end
% Check whether there are any nonpositive or non-integer values in fragmentCarbons
nonIntegerfragmentCarbons = cellfun(@(x) (nnz(x<=0)+nnz(floor(x)<x)), fragmentCarbons, 'UniformOutput', 0);
nonIntegerfragmentCarbons = cell2mat(nonIntegerfragmentCarbons);

%if there are empty elements in fragmentNames, display error message
if nnz(nonIntegerfragmentCarbons)
    disp 'ERROR: Incorrect Fragment carbon format in simulateMetabolites.'
    disp 'ERROR: Fragments should have the following format:'
    disp 'ERROR: FragmentName: MetaboliteName @ carbon indeces'
    disp 'ERROR: Carbon indeces should be positive integers'
    disp 'ERROR: Example:'
    disp 'ERROR: PYR12: PYR @ 1 2'
    disp 'ERROR: Following fragments have incorrect format:'
    emptyFragmentNames = find(nonIntegerfragmentCarbons);
    for i=1:length(emptyFragmentNames)
        disp(simulateMetabolites{emptyFragmentNames(i)})
    end
    simulateMetabolites = [];
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check whether all metabolites have a name
fragmentMetaboliteName = cellfun(@(x) strtrim(x(strfind(x, ':')+1:strfind(x, '@')-1)),...
                                                simulateMetabolites, 'UniformOutput', 0);
emptyFragmentMetaboliteNames = cellfun(@(x) isempty(x), fragmentMetaboliteName);
%if there are empty elements in fragmentNames, display error message
if nnz(emptyFragmentMetaboliteNames)
    disp 'ERROR: Incorrect Fragment format in simulateMetabolites.'
    disp 'ERROR: Fragments should have the following format:'
    disp 'ERROR: FragmentName: MetaboliteName @ carbon indeces'
    disp 'ERROR: Example:'
    disp 'ERROR: PYR12: PYR @ 1 2'
    disp 'ERROR: Following fragments have incorrect format:'
    emptyFragmentNames = find(emptyFragmentMetaboliteNames);
    for i=1:length(emptyFragmentNames)
        disp(simulateMetabolites{emptyFragmentNames(i)})
    end
    simulateMetabolites = [];
    return;
end                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check whether there are multiple entries for the same fragment
fragmentMetabolite = cellfun(@(x) strtrim(x(strfind(x, ':')+1:end)), simulateMetabolites, 'UniformOutput', 0);
[fragmentMetaboliteUnique, i1, i2] = unique(fragmentMetabolite, 'stable');
if length(fragmentMetaboliteUnique) < length(fragmentMetabolite)
    disp 'WARNING: removing duplicate fragments from simulateMetabolites:'
    for i=1:length(i1)
        if nnz(i2==i)>1
            duplicateI = find(i2==i);
            for j=1:length(duplicateI)
                disp(simulateMetabolites(duplicateI(j)))
            end
        end
    end
    simulateMetabolites = simulateMetabolites(i1);
    fragmentMetabolite = fragmentMetabolite(i1);
    fragmentNames = fragmentNames(i1);
    fragmentCarbons = fragmentCarbons(i1);
    fragmentMetaboliteName = fragmentMetaboliteName(i1);
end

% Check whether all fragments have different names, 
% if not, rename the fragments
[uniqueFragmentNames, ~, i2] = unique(fragmentNames);
if length(uniqueFragmentNames) < length(fragmentNames)
    disp 'WARNING: fragments have the same name. Renaming fragments:'
    for i=1:length(uniqueFragmentNames)
        if nnz(i2==i)>1
            duplicateI = find(i2==i);
            for j=1:length(duplicateI)
                newName = strcat(fragmentNames(duplicateI(j)), strrep(num2str(fragmentCarbons{(duplicateI(j))}), ' ', ''));
                oldName = simulateMetabolites{duplicateI(j)};
                newName = strcat(newName, oldName(strfind(oldName,':'):end));
                fprintf('Old entry: %s\n', oldName)
                fprintf('New entry: %s\n', newName{1})
                simulateMetabolites(duplicateI(j)) = newName;
            end
        end
    end
end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if second argument with stroichiometric matrix is provided, 
% check that the metabolite names and carbon numbers are the same
if nargin>1
    sampleM = varargin{1};
    if isstruct(sampleM)
        if isfield(sampleM, 'M')
            if isfield(sampleM.M, 'names') && isfield(sampleM.M, 'ncarbons')
                for i=1:length(fragmentMetaboliteName)
                    modelidx = find(ismember(sampleM.M.names, fragmentMetaboliteName{i}));
                    if ~isempty(modelidx)
                        if max(fragmentCarbons{i})>sampleM.M.ncarbons(modelidx)
                            fprintf('ERROR: number of carbons in %s is larger than in the provided model(%d)\n', simulateMetabolites{i}, sampleM.M.ncarbons(modelidx))
                            simulateMetabolites = [];
                            return;
                        end
                    else
                        fprintf('ERROR: fragment %s not found in the provided model\n', simulateMetabolites{i})
                        simulateMetabolites = [];
                        return;
                    end
                end
            else
                disp 'WARNING: provided model has incorrect format. simulateMetabolites check not completed.'
            end
        else
            disp 'WARNING: provided model has incorrect format. simulateMetabolites check not completed.'
        end
    else
        disp 'WARNING: provided model has incorrect format. simulateMetabolites check not completed.'
    end
end
    

