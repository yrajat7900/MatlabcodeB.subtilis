function L = ratiolist(list, varargin)
% SUMOFLUX list of ratios
% If called without parameters, returns the list of ratios
% If called with the Ratio name as input, returns the fluxes in nominator
% and denominator
% Syntax: 
% {'Ratio name'}{coef 'flux_name' 'flux_type'}{coef 'flux_name' 'flux_type'}
%               ---------nominator---------- / -------denominator---------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add custom flux ratios to be included in the workflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list = {...
%    {'Glycolysis/PPP'} {1 'pgi' 'net'} {1 'pgi' 'net' 1 'zwf' 'net' };...
%    {'Pyruvate from ED'} {1 'edp2' 'net'} {1 'edp2' 'net' 1 'pyk' 'net' 1 'mae' 'net'};...
%    {'gluconeogenesis (PEP from oxaloacetate)' } {1 'pck' 'net' } {1 'pck' 'net' 1 'eno' 'net'};...
%    {'Pyruvate from malic enzyme'} {1 'mae' 'net' } {1 'mae' 'net'  1 'pyk' 'net' 1 'edp2' 'net'};...
%    {'BSUB Pyruvate from malic enzyme'} {1 'mae' 'net' } {1 'mae' 'net'  1 'pyk' 'net'};...
%    {'anaplerosis (OAA from pyruvate)'} {1 'pyc' 'net' } {1 'pyc' 'net'  1 'sdh' 'net' 1 'gs1' 'net'};...
%    {'BSUB anaplerosis (OAA from pyruvate)'} {1 'pyc' 'net' } {1 'pyc' 'net'  1 'mdh' 'net'};...
%    {'Oxaloacetate from TCA' } {1 'sdh' 'net' } {1 'pyc' 'net' 1 'sdh' 'net' 1 'gs1' 'net'};...
%    {'Oxaloacetate from glyoxylate shunt' } {1 'gs1' 'net'} {1 'sdh' 'net' 1 'gs1' 'net' 1 'pyc' 'net'};...
%    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here the input parameter is parsed
syn = {};
ind = [];
for i = 1:size(list,1)
    syn = [syn list{i,1}];
    ind = [ind ones(1,length(list{i,1}))*i];    
end  

if nargin == 1 % no additional argument --> return all ratios in list
    L = syn;
    return
elseif nargin>1 % multiple ratios given
    R = {};
    for i = 1:(nargin-1)
        if ischar(varargin{i})
            R = [R varargin{i}];
        end
    end
else % one argument given
    if ischar(varargin{1})
        R = {varargin{1}};
    end
end

% R: candidate list
L ={};
for i = 1:length(R)
    [tf,loc] = ismember(R{i},syn);
    if tf
        L = [L; R{i} list(ind(loc),2) list(ind(loc),3)];
    else
        disp(['   ! ' R{i} ' not found']);
    end
end