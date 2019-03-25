function [training_idx, val_idx] = divideSamples(target, val_perc) 
%% divide sample to training and validation
% mat_noise - data matrix 
% val_perc - percantage of validation set

% divide sample to training and validation
val_idx = randperm(length(target), ceil(length(target)*val_perc));

val_idx = unique(sort(val_idx));

training_idx = setdiff( (1:length(target)), val_idx );
