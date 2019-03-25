function [Smdv, fluxVectors, isotopes, incaModel] = simulateLabelingData(incaModel, fluxVectors, labelingStrategy, measuredMetabolites)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for the INCA functions, if present, remove the Systems Biology Toolbox 
% and Robust Control Toolbox from the search path to avoid function name conflicts. 
curpath = path;
curpath = strsplit(curpath, pathsep);
robustpath = cellfun(@(x) ~isempty(strfind(x, [filesep 'toolbox' filesep 'robust'])), curpath);
simbiopath = cellfun(@(x) ~isempty(strfind(x, [filesep 'toolbox' filesep 'simbio'])), curpath);
curpath(robustpath | simbiopath) = [];
path(strjoin(curpath, pathsep));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d = msdata(measuredMetabolites);
d.mdvs = mdv; % create devault MDVs, which will be replaced by simulated MDVs later.

%create a list of measured isotopes names
isotopes = cellfun(@(x) strsplit(x), d.atoms, 'UniformOutput', 0);
isotopes = strcat(d.id, isotopes);
isotopes = cellfun(@(x) strcat(x(1), '_', x), isotopes, 'UniformOutput', 0);
for i=2:length(isotopes)
    isotopes{1} = [isotopes{1} isotopes{i}];
end
isotopes = isotopes{1,1}';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% labeling
   
t = tracer(labelingStrategy(:,1));
t.frac = cell2mat(labelingStrategy(:,2)');

% flux measurements
f = data();
 
% add experiment information into the model
x = experiment(t);
x.data_flx = f;
x.data_ms = d;
   
incaModel.expts = x;    


   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulate MS measurements
incaModel.options.sim_tunit = 'h';              % hours are unit of time
incaModel.options.fit_reinit = false;
incaModel.options.sim_ss = true;
incaModel.options.sim_sens = false;
incaModel.options.sim_na = false;
incaModel.options.sim_more = false;
incaModel.options.hpc_on = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make flux vector in the format for INCA simulations
fluxval = zeros(size(fluxVectors.net,2),size(fluxVectors.net,1)*2);
fluxidx = 1;
for i=1:size(fluxVectors.net,1)
    fluxval(:,fluxidx) = fluxVectors.f(i,:);
    fluxidx = fluxidx+1;
    if length(incaModel.rates(i).flx)==2
        fluxval(:,fluxidx) = fluxVectors.b(i,:);
        fluxidx = fluxidx+1;
    end
end
fluxval(:,fluxidx:end) = [];
nfluxes = size(fluxval,1);

% simulate measurements for each flux solution

% mute disp function by redirecting to a dummy one
warning off
displocation = '';
if exist('disp1.m', 'file') == 2
    displocation = which('disp1.m');
    displocation = fileparts(displocation);
    movefile([displocation filesep 'disp1.m'],[displocation filesep 'disp.m'])
end

numisotopes = sum(cellfun(@(x) nnz(x==' ')+2, d.atoms));
Smdv = zeros(numisotopes, size(fluxval,1));
sModels = cell(1,nfluxes);

tic
parfor j=1:nfluxes
    curm = incaModel;
    curm.rates.flx.val = fluxval(j,:);
    s = simulate(curm);
    sModels{j} = s;
end
%restore the disp function
if exist('disp.m', 'file') == 2
    if ~isempty(displocation)
        movefile([displocation filesep 'disp.m'],[displocation filesep 'disp1.m'])
    end
end
warning on

for j=1:length(sModels)
    s = sModels{j};
    Smdv(:,j) =  cell2mat(vertcat(s.val)');  
end
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
passcheck = CheckIsotopeMDVs(Smdv, isotopes);
Smdv = Smdv(:, passcheck);
fluxVectors.net = fluxVectors.net(:, passcheck);
fluxVectors.f = fluxVectors.f(:, passcheck);
fluxVectors.b = fluxVectors.b(:, passcheck);
fluxVectors.ex = fluxVectors.ex(:, passcheck);
fluxVectors.mu = fluxVectors.mu(passcheck);
