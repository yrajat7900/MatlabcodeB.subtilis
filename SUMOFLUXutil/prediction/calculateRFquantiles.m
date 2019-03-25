function [quantRFres, weights, predictweights] = calculateRFquantiles(Xtrain, Ytrain, Xtest, rfmodel, quantValues)
%calculate quantiles for the randomforest prediction according to Meinshausen 2006
%Xtrain the training sample
%Ytrain the training targets
%Xtest the test sample
%rfmodel is the random forest model crated in regRF_train function
%quantValues are the quantiles to calculate

% perform variable size checks
if size(Xtrain,2) ~= length(rfmodel.importance)
    Xtrain = Xtrain';
    if size(Xtrain,2) ~= length(rfmodel.importance)
        disp 'ERROR: Number of features in the training sample does not match the number of features in the rfmodel'
        quantRFres = [];
        weights = [];
        return
    end
end

if size(Xtrain,1) ~= size(Ytrain, 1)
    Ytrain = Ytrain';
    if size(Xtrain,1) ~= size(Ytrain, 1)
        disp 'ERROR: Size of targetFR is different from the size of training data'
        quantRFres = [];
        weights = [];
        return
    end
end
    
if size(Xtrain,2) ~=  size(Xtest,2)
    Xtest = Xtest';
    if size(Xtrain,2) ~=  size(Xtest,2)
        disp 'ERROR: Number of features in the test sample does not match the number of features in the rfmodel'
        quantRFres = [];
        weights = [];
        return
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extra_options.nodes = 1;
extra_options.predict_all = 1;

[~, ~, nodes] = regRF_predict(Xtrain, rfmodel, extra_options);

[~, ~, nodesTest] = regRF_predict(Xtest, rfmodel, extra_options);

weights = zeros(size(Xtrain, 1), size(Xtest, 1));

bestnodes = 1:length(rfmodel.rsq);

for i=1:size(Xtest, 1)
    %calculate weight for each initial observation in each tree
    weightsTree = zeros(size(Xtrain, 1), size(bestnodes,2));
    for j=1:length(bestnodes) 
        curObsNode = nodesTest(i,bestnodes(j));
        initObsinNode = nodes(:,bestnodes(j)) == curObsNode;
        curWeight = 1/nnz(initObsinNode);
        weightsTree(initObsinNode,j) = curWeight;
    end
    weights(:,i) = mean(weightsTree,2);
end
%%%%%%%%%%%
predictweights = weights;
%%%%%%%%%%%
[~, sortord] = sort(Ytrain, 'ascend');
weights = weights(sortord,:);
cumweights = cumsum(weights);
for i=1:size(cumweights,2)
    cumweights(:,i) = cumweights(:,i) / cumweights(end,i);
end
origObs = Ytrain(sortord);

quantRFres = zeros(size(Xtest, 1), length(quantValues));
for i = 1:length(quantValues)

    qc = quantValues(i);
    
    larg = cumweights<qc;
    wc = sum(larg)+1;
    ind1 = wc<1.1;
    indn1 = wc>1.1;
    
    quantRFres(ind1, i) = repmat(origObs(1),nnz(ind1),1);
    quantmax = origObs(wc(indn1));
    quantmin = origObs(wc(indn1)-1);
    weightmax = cumweights(sub2ind(size(cumweights), wc(indn1),find(indn1)));
    weightmin = cumweights(sub2ind(size(cumweights), wc(indn1)-1,find(indn1)));
    factor = zeros(nnz(indn1),1);
    indz = weightmax-weightmin<10^(-10);
    factor(indz) = 0.5;
    factor(~indz) = (qc-weightmin(~indz))/(weightmax(~indz)-weightmin(~indz));
    quantRFres(indn1, i) = quantmin + factor.*(quantmax-quantmin);
end

weights = cumweights;
