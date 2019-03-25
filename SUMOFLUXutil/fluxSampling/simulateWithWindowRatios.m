function V = simulateWithWindowRatios(M, varargin)

M.param.hr.points_wu = 10;
M.param.hr.points_hr = 100; % unique fluxes
M.param.hr.iterations = 500;
M.param.hr.points_exch = 1;%how many exchange fluxes for each net flux
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COMMENTS
% don't forget to release CO2 to unlimited uptake/secretion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FLUX SAMPLING
% sample uniformly across the flux ratio range
if nargin==1
     V = samplingBoundRatioNoGrowth_inca(M);
     return
end    
if nargin>1
    fluxnames = varargin{1};
    fluxidx = cell(size(fluxnames));
    for i=1:numel(fluxnames)
        curnames = fluxnames{i};
        if iscell(curnames)
            for j=1:length(curnames)
                cursign=1;
                if isequal(curnames{j}(1),'-')
                    cursign=-1;
                    curnames{j} = curnames{j}(2:end);
                end
                curidx = find(cellfun(@(x)~isempty(x), strfind(M.R.id, curnames{j})));
                if isempty(fluxidx{i})
                    fluxidx{i} = curidx*cursign;
                else
                    fluxidx{i} = [fluxidx{i} curidx*cursign];
                end
            end
        else
             curidx = find(cellfun(@(x)~isempty(x), strfind(M.R.id, curnames)));
             fluxidx{i} = curidx;
        end
    end
    ratioConstrainsValues = [zeros(size(fluxidx,1),1) ones(size(fluxidx,1),1)];
    ratioVaryIndex = ones(size(fluxidx,1),1);
end
if nargin>2
    M.param.hr.points_hr = varargin{2};
end
if nargin>3
    ratioConstrainsValues = varargin{3};
end
if nargin>4
    ratioVaryIndex = varargin{4};
end
    


%set the stepwise boundaries for two flux ratios 
steps = (0:0.25:1);
ratio_boundaries = cell(power((length(steps)-1), nnz(ratioVaryIndex)),1);
idx = 1;
switch nnz(ratioVaryIndex)
    case 1
        for i=2:length(steps)
           ratio_boundaries{idx} = ratioConstrainsValues;
           ratio_boundaries{idx}(ratioVaryIndex==1,:) = ratioConstrainsValues(ratioVaryIndex==1,1) + [steps(i-1) steps(i)].*(ratioConstrainsValues(ratioVaryIndex==1,2)-ratioConstrainsValues(ratioVaryIndex==1,1));
           idx = idx+1;
        end
    case 2
        segmentStart = ratioConstrainsValues(ratioVaryIndex==1,1);
        segmentLength = ratioConstrainsValues(ratioVaryIndex==1,2)-ratioConstrainsValues(ratioVaryIndex==1,1);
        for i=2:length(steps)
            for j=2:length(steps)
               ratio_boundaries{idx} = ratioConstrainsValues;
               ratio_boundaries{idx}(ratioVaryIndex==1,:) = [  segmentStart(1) + [steps(i-1) steps(i)]*segmentLength(1);...
                                                            segmentStart(2) + [steps(j-1) steps(j)]*segmentLength(2)];

               idx = idx+1;
            end
        end
    case 3
        segmentStart = ratioConstrainsValues(ratioVaryIndex==1,1);
        segmentLength = ratioConstrainsValues(ratioVaryIndex==1,2)-ratioConstrainsValues(ratioVaryIndex==1,1);
        for i=2:length(steps)
            for j=2:length(steps)
                for k=2:length(steps)
                    ratio_boundaries{idx} = ratioConstrainsValues;
                    ratio_boundaries{idx}(ratioVaryIndex==1,:) = [  segmentStart(1) + [steps(i-1) steps(i)]*segmentLength(1);...
                                                                 segmentStart(2) + [steps(j-1) steps(j)]*segmentLength(2);...
                                                                 segmentStart(3) + [steps(k-1) steps(k)]*segmentLength(3)];

                    idx = idx+1;
                end
            end
        end
end

clear steps

%for each range of flux ratios sample from the distribution
Vtotal = cell(length(ratio_boundaries),1);
warning off
parfor i=1:length(ratio_boundaries)
     %Vtotal{i} = samplingBoundRatioNoGrowth_inca(M,[idx1 idx2 0; idx3 idx4 idx5], ratio_boundaries{i});
     Vtotal{i} = samplingBoundRatioNoGrowth_inca(M,fluxidx,ratio_boundaries{i});
end
warning on
%combine the V with different ratios into one
V.net = zeros(length(M.R.id), length(ratio_boundaries)*M.param.hr.points_hr);
V.f = zeros(length(M.R.id), length(ratio_boundaries)*M.param.hr.points_hr);
V.b = zeros(length(M.R.id), length(ratio_boundaries)*M.param.hr.points_hr);
V.ex = zeros(length(M.R.id), length(ratio_boundaries)*M.param.hr.points_hr);
idx = 1;%size(V.net,2);
for i=1:length(Vtotal)
    if isstruct(Vtotal{i})
       V.net(:, idx:idx+size(Vtotal{i}.net,2)-1) = Vtotal{i}.net;
       V.f(:, idx:idx+size(Vtotal{i}.net,2)-1) = Vtotal{i}.f;
       V.b(:, idx:idx+size(Vtotal{i}.net,2)-1) = Vtotal{i}.b;
       V.ex(:, idx:idx+size(Vtotal{i}.net,2)-1) = Vtotal{i}.ex;
       %V.mu(idx:idx+size(Vtotal{i}.net,2)-1) = Vtotal{i}.mu;
       idx = idx+size(Vtotal{i}.net,2);
    end
end
V.net(:, idx:end)=[];
V.f(:, idx:end)=[];
V.b(:, idx:end)=[];
V.ex(:, idx:end)=[];
V.mu = zeros(1,size(V.net,2));
clear Vtotal idx ratio_boundaries
clear idx1 idx2 idx3 idx4 idx5 idx6 flux1 flux2 flux3 flux4 flux5 flux6 r1 r2 r3
