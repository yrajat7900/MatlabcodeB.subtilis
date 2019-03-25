function LabelingIsoStrategy = getIsotopeLabelingFromCarbonLabeling(labelingStrategy, varargin)
% function getIsotopeLabelingFromCarbonLabeling(labelingStrategy, varargin):
% Calculate isotope labeling from the metabolite carbon purity information
% labelingStrategy is a cell array of the following format: 
% labelingStrategy = {   'glucose' [0.99 0.01 0.01 0.01 0.01 0.01] 0.8;...
%                        'glucose' [ 0.01 0.99 0.01 0.01 0.01 0.01] 0.2;...
%                    };
% The labeling fraction of each isotope of metabolite is calculated, 
% and considered for further processing if >0.001.
% If stoichiometric model is provided as a second input argument, 
% the function checks that the number of carbons in the model and in the
% labeling strategy for each metabolite is the same. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, check that there are three elements provided in the labelingStrategy

if size(labelingStrategy,2) ~= 3
     disp 'ERROR: labelingStrategy should contain'
     disp 'ERROR: {metabolitename [carbon purity array] [fraction]}' 
     disp 'ERROR: For example, {'glucose' [0.99 0.01 0.01 0.01 0.01 0.01] 1};'
     LabelingIsoStrategy = [];
     return;
end
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Second, check that all elements of labelingStrategy corresponding to the
% same metabolite have equal amount of carbons
% Third, check that the fraction of each metabolite sums to 1
metaboliteNames = labelingStrategy(:,1);
metaboliteCarbons = zeros(size(metaboliteNames));
for i=1:size(labelingStrategy,1)
    metaboliteCarbons(i) = length(labelingStrategy{i,2});
end
metaboliteFractions = cell2mat(labelingStrategy(:,3));

[metaboliteNames, i1, i2] = unique(metaboliteNames);
for i=1:length(metaboliteNames)
    if length(unique(metaboliteCarbons(i2==i)))>1
        fprintf('ERROR: Number of carbons in %s is different in the labeling strategy provided\n', metaboliteNames{i})
        LabelingIsoStrategy = [];
        return;
    end
    if sum(metaboliteFractions(i2==i))~=1
        fprintf('ERROR: Sum of fractions of %s in the labeling strategy is %.2f, but has to be 1\n', metaboliteNames{i}, sum(metaboliteFractions(i2==i)))
        LabelingIsoStrategy = [];
        return;
    end
end
metaboliteCarbons = metaboliteCarbons(i1); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fourth, if the stoichipometric model is provided, compare the number of
% carbons in the labeled metabolites
if nargin>1
    sampleM = varargin{1};
    if isstruct(sampleM)
        if isfield(sampleM, 'inp')
            if isfield(sampleM.inp, 'names') && isfield(sampleM.inp, 'ncarbons')
                for i=1:length(metaboliteNames)
                    modelMetIdx = find(ismember(sampleM.inp.names, metaboliteNames{i}),1);
                    if isempty(modelMetIdx)
                        fprintf('ERROR: Metabolite %s provided in the labeling strategy is not found in the model\n', metaboliteNames{i})
                        LabelingIsoStrategy = [];
                        return;
                    end
                    if sampleM.inp.ncarbons(modelMetIdx) ~= metaboliteCarbons(i)
                        fprintf('ERROR: Metabolite %s provided in the labeling strategy has different amount of carbons (%d)\n', metaboliteNames{i},metaboliteCarbons(i))
                        fprintf('ERROR: compared to the provided model (%d)\n', sampleM.inp.ncarbons(modelMetIdx))
                        LabelingIsoStrategy = [];
                        return;
                    end 
                end
                 else
                disp 'WARNING: provided model has incorrect format. Labeling strategy check not completed.'
            end
        else
            disp 'WARNING: provided model has incorrect format. Labeling strategy check not completed.'
        end
    else
        disp 'WARNING: provided model has incorrect format. Labeling strategy check not completed.'
    end
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create isotope labelingIsoStrategy from labelingStrategy
LabelingIsoStrategy  = {};
 for lab_i = 1:size(labelingStrategy, 1)
     %get the number of carbons in the current metabolite
     ncarbons = length(labelingStrategy{lab_i,2});       
     % create a matrix coding all isotopes of the metabolite
     carbonArray = de2bi(0:(2^ncarbons-1));
     % create a matrix indicating carbon probability for each isotope
     carbonArrayProbability = repmat(labelingStrategy{lab_i,2}, size(carbonArray,1),1); 
     carbonArrayProbability(carbonArray==0) = 1-carbonArrayProbability(carbonArray==0);   
     % calculate probability of each isotope as product of the
     % probabilities of its carbons
     carbonIsotopeProbability = prod(carbonArrayProbability,2); 
     % leave isotopes wit hsignificant probability (>0.001)
     labeledIsotopes = find(carbonIsotopeProbability>0.001);
     carbonIsotopeProbability = carbonIsotopeProbability(carbonIsotopeProbability>0.001);
     % multiply by the percentage of this metabolite given in the
     % labelingStrategy array
     carbonIsotopeProbability = labelingStrategy{lab_i,3} * carbonIsotopeProbability/sum(carbonIsotopeProbability);

     % create a currentLabelingStrategy structure in the SUMOFLUX format
     currentLabelingIsoStrategy = cell(length(carbonIsotopeProbability), 2);
     for i=1:length(carbonIsotopeProbability)
         curLabeledCarbons = find(carbonArray(labeledIsotopes(i),:));
         if isempty(curLabeledCarbons)
            curIsoName = ['N-', labelingStrategy{lab_i,1}, ': ', labelingStrategy{lab_i,1}, ' @'];
         else
            curLabeledCarbons = num2str(curLabeledCarbons);
            curIsoName = [strrep(curLabeledCarbons, ' ', '') '-', labelingStrategy{lab_i,1}, ': ', labelingStrategy{lab_i,1}, ' @ ' curLabeledCarbons];
         end
         currentLabelingIsoStrategy{i,1} = curIsoName;
         currentLabelingIsoStrategy{i,2} = carbonIsotopeProbability(i);
     end
    
     LabelingIsoStrategy = [LabelingIsoStrategy; currentLabelingIsoStrategy];
 end

% merge elements of the LabelingIsostrategy that are duplicates
% by summing their percentages
[~, i1, i2] = unique(LabelingIsoStrategy(:,1), 'stable');  

newLabelingStrategy = cell(length(i1),2);
for i=1:length(i1)
    newLabelingStrategy{i,1} = LabelingIsoStrategy{i1(i),1};
    newLabelingStrategy{i,2} = sum(cell2mat(LabelingIsoStrategy(i2 == i,2)));
end
LabelingIsoStrategy = newLabelingStrategy;
         
  