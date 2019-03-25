function M = parseFluxConstrains(M, fluxConstrains)
%Function parseFluxConstrains adds flöux constrains to the model M
%INPUT model M is SUMOFLUX model onject
%INPUT fluxConstrains is a cell array of following format:
%                   flux_name flux_type lower_bound upper_bound
%fluxConstrains = { 'glc_up' 'net' [] 10;...
%                   'accoa_ac' 'net' 1 100;...
%                 };
%flux_name has to be the same as in model M
%flux_type can be either net (net flux constrains) or exch (exchange flux
%constrains)

if isempty(fluxConstrains) %no constrains to parse
    return;
end

if size(fluxConstrains,2)~=4
    disp ' '
    disp 'ERROR: flux constrains format is unknown'
    disp 'ERROR: example of flux constrains format:'
    disp 'ERROR: Add the constrains to the model description file'
    disp 'fluxConstrains = { 'glc_up' 'net' [] 10;...^'
    disp '                   'accoa_ac' 'net' 1 100;};'
    disp ' '
    disp 'WARNING: Continue with default constrain values...'
    return;
else
    fluxNames = fluxConstrains(:,1);
    %check that all the flux names are in the model
    if nnz(~ismember(fluxNames, M.R.id))
        disp ' '
        disp 'ERROR: unknown flux names in flux constrains:'
        for i=1:length(fluxNames)
            if ~ismember(fluxNames{i}, M.R.id)
                fprintf('%s not found in the model\n', fluxNames{i});
            end
        end
        disp ' '
        disp 'Continue with default constrain values...'
        return;
    else
        %check that the flux type is correct:
        allowedTypes = {'net', 'exch'};
        fluxTypes = fluxConstrains(:,2);
        if nnz(~ismember(fluxTypes, allowedTypes))
            disp ' '
            disp 'ERROR: unknown flux types in flux constrains:'
            for i=1:length(fluxTypes)
                if ~ismember(fluxTypes{i}, allowedTypes)
                    fprintf('%s not found in the model\n', fluxNames{i});
                end
            end
            disp ' '
            disp 'Continue with default constrain values...'
            return;
        else
            try
                lowerBound = cell2mat(fluxConstrains(:,3));
                upperBound = cell2mat(fluxConstrains(:,4));
                wrongBounds = lowerBound>upperBound;
                if nnz(wrongBounds)
                    disp 'WARNING: lower bound is greater than upper bound in following reactions:'
                    for i=1:length(wrongBounds)
                        if wrongBounds(i)==1
                            fprintf('%s\n', fluxNames{i});
                        end
                    end
                    disp ' '
                    disp 'Continue with default constrain values...'
                    upperBound(wrongBounds) = [];
                    lowerBound(wrongBounds) = [];
                    fluxTypes(wrongBounds) = [];
                    fluxNames(wrongBounds) = [];
                end
                % ADD BOUNDS TO THE MODEL
                netConstrains = ismember(fluxTypes, 'net');
                exchConstrains = ismember(fluxTypes, 'exch');
                reactionIDXnet = ismember(M.R.id, fluxNames(netConstrains));
                M.param.lb(reactionIDXnet) = lowerBound(netConstrains);
                M.param.ub(reactionIDXnet) = upperBound(netConstrains);
                
                reactionIDXexch = ismember(M.R.id, fluxNames(exchConstrains));
                M.param.min_exch(reactionIDXexch) = lowerBound(exchConstrains);
                M.param.max_exch(reactionIDXexch) = upperBound(exchConstrains);
            catch ME
                disp 'ERROR: flux constrains format is unknown'
                disp '*************'
                disp(ME.message)
                disp '*************'
                disp 'ERROR: example of flux constrains format:'
                disp 'ERROR: Add the constrains to the model description file'
                disp 'fluxConstrains = { 'glc_up' 'net' [] 10;...^'
                disp '                   'accoa_ac' 'net' 1 100;};'
                disp ' '
                disp 'Continue with default constrain values...'
                return;
            end
        end
    end
end

        
        