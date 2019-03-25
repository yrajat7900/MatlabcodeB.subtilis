function plotScatterValidation(real, lowReal, highReal, predicted, lowPred, highPred, varargin)

% check whether the real and predicted are vertical vectors
if size(real,1) < size(real,2)
    real = real';
end
if size(predicted,1) < size(predicted,2)
    predicted = predicted';
end

msize = 10;
%plot the figure
%fig = figure;

plot([0 1], [0 1], 'k')
hold on

plot(real, predicted, 'o', 'MarkerFaceColor', [.35 .7 .9], 'MarkerEdgeColor', 'none', 'MarkerSize', msize)


errorbar(real, predicted, predicted-lowPred, highPred-predicted, '.', 'Color', [.35 .7 .9], 'LineWidth', 1 )
herr = herrorbar(real, predicted, real-lowReal, highReal-real, '.');
set(herr, 'Color', [.35 .7 .9])
set(herr,'LineWidth', 1 )

axis square
xlim([0 1])
ylim([0 1])

fsize = 10;
set(gca, 'XTick', [0 0.5 1])
set(gca, 'XTickLabel', {'0' '0.5' '1'})
set(gca, 'YTick', [0 0.5 1])
set(gca, 'YTickLabel', {'0' '0.5' '1'})
set(gca, 'fontSize', fsize);


[corrcoef, picorr] = corr(real, predicted);
if nargin>6
    tag = varargin{1};
    title({tag sprintf('Corr=%.2f, p=%.2f', corrcoef, picorr)}, 'fontSize', fsize)
else
    title(sprintf('Corr=%.2f, p=%.2f', corrcoef, picorr), 'fontSize', fsize)
end    
