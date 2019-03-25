function labelingStrategy = inputLabelingStrategy_Glucose_100_113C()
% inputLabelingStrategy - define labeling strategy in the format
% {'metabolite name' [carbon purity array] [metabolite fraction]
% For example, 100% 1-13C labeled glucose:
labelingStrategy = {   'glucose' [0.99 0.01 0.01 0.01 0.01 0.01] 1;};
% For example, 20% [U-13C] labeled and 80% unlabeled glucose:
% labelingStrategy = {   'glucose' [0.01 0.01 0.01 0.01 0.01 0.01] 0.8;...
%                        'glucose' [0.99 0.99 0.99 0.99 0.99 0.99] 0.2;...
%                    };
% For example, 100% [U-13C] labeled glucose  and 100% unlabeled acetate:
% labelingStrategy = { 'glucose' [0.99 0.99 0.99 0.99 0.99 0.99] 1;...
%                      'acetate' [0.01 0.01] 1;...
%                    };
% NOTE: The input metabolite name has to be the same as in the provided
% NOTE: stoichiometric model.
% NOTE: Labeling fractions of the same metabolite have to sum to 1

% 80% [1-13C] and 20% [U-13C] labeled glucose
% labelingStrategy = {   'glucose' [0.99 0.01 0.01 0.01 0.01 0.01] 1;...
%                        'glucose' [0.99 0.99 0.99 0.99 0.99 0.99] 0;...
%                    };
end