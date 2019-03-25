function [m, M] = initializeModel(modelFileName, varargin)

%clear functions

%initialize reactions and model
% try
    modelFunction = str2func(modelFileName);
    
    if ~exist('reaction', 'file') 
        disp 'INCA functions not found. Verify that the INCA software is in the path'
        m=[];
        M=[];
        return
    end
    [r, modelReactions, excludeMetabolites, inputMetabolites, outputMetabolites, symMetabolites, ratioConstrains, fluxConstrains] = modelFunction(varargin{:});

    m = model(r);
% catch ME
%         disp '*************'
%         disp(ME.message)
%         disp '*************'
%     try 
%   %      clear classes
%         modelFunction = str2func(modelFileName);
%     
%         if ~exist('reaction', 'file') 
%             disp 'INCA functions not found. Verify that the INCA software is in the path'
%             m=[];
%             M=[];
%             return
%         end
%         [r, modelReactions, excludeMetabolites, inputMetabolites, outputMetabolites, symMetabolites, ratioConstrains, fluxConstrains] = modelFunction();
% 
%         m = model(r);
%     catch ME
%         
%         disp 'ERROR in model identification. Check the file name (pass the function name without extension).'
%         disp '*************'
%         disp(ME.message)
%         disp '*************'
%         m=[];
%         M=[];
%         return
%     end
% end

% Take care of symmetrical metabolites
% try 
    for i=1:size(symMetabolites,1)
        symName = symMetabolites{i,1};
        symCarbonNumber = symMetabolites{i,2};
        symCarbonMap = arrayfun(@(x) sprintf('%d:%d', x, symCarbonNumber+1-x), (1:symCarbonNumber), 'UniformOutput', 0);
        symCarbonMap = strjoin(symCarbonMap, ' ');

        m.mets{symName}.sym = list('rotate180',atommap(symCarbonMap));
    end
% catch ME
%         disp '*************'
%         disp(ME.message)
%         disp '*************'
%     disp 'Error in symmetrical metabolite structure. The format is ['Name' numberOfCarbons;'Name' numberOfCarbons;]'
%     m=[];
%     M=[];
%     return
% end

%create a model structure M for the sampling procedure
M = createModelForSampling(m, r, modelReactions, inputMetabolites,...
                                 outputMetabolites, excludeMetabolites);
%check ratio constrains and add them to the model
for i=1:numel(ratioConstrains)
    curConstraintName = ratioConstrains{i};
    if iscell(curConstraintName)
        for j=1:numel(curConstraintName)
            if ~ismember(curConstraintName{j}, M.R.id)
                fprintf('WARNING: constraint %s not found among model reactions\n',curConstraintName{j}) 
                disp 'Sampling will be without constraints'
                ratioConstrains = [];
                break;
            end
        end
    else
        if ~ismember(curConstraintName, M.R.id)
            fprintf('WARNING: constraint %s not found among model reactions\n',curConstraintName) 
            disp 'Sampling will be without constraints'
            ratioConstrains = [];
            break;
        end 
    end
end
M.param.ratioConstrains =  ratioConstrains;
    
M = parseFluxConstrains(M, fluxConstrains);

