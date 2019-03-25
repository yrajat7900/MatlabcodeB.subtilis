function [numoutliers, nummarginal, fig] = detectOutlierFeatures(simdata, realdata, varargin)
% detect those festures in experimental (real) data, which are not within
% the "distribution" of simulated features
% numoutliers - number of real features lying beyond uotliers
% nummarginal - number of real features beyond [25 75]% interval

if ~ismember(size(simdata,2), size(realdata))
    simdata = simdata';
end
if size(realdata,2) ~= size(simdata,2)
    realdata = realdata';
end

fig = figure;
if nargin>2
    boxplot(simdata,varargin{1},'labelorientation', 'inline', 'symbol', 'b+')
else
    boxplot(simdata, 'symbol', '+', 'Color', [.5 .5 .5])
end
title('Labeled fraction distributions of simulated(grey) and real(green) data', 'fontSize', 16)
h = findobj(gcf,'tag','Upper Whisker');
% get upper outliers
yupper = get(h,'YData');
yupper = cell2mat(yupper);
ymax = flipud(max(yupper, [], 2));
% get upper quantile
yboxmax = flipud(min(yupper, [], 2));

% get lower outliers
h = findobj(gcf,'tag','Lower Whisker');
ylower = get(h,'YData');
ylower = cell2mat(ylower);
ymin = flipud(min(ylower, [], 2));
% get lower quantile
yboxmin = flipud(max(ylower, [], 2));

numoutliers = zeros(size(realdata, 2), 1);
nummarginal = zeros(size(realdata, 2), 1);
for i=1:size(realdata, 2)
    numoutliers(i) = nnz( realdata(:,i) < ymin(i) | realdata(:,i) > ymax(i) ) / size(realdata, 1);
    nummarginal(i) = nnz( realdata(:,i) < yboxmin(i) | realdata(:,i) > yboxmax(i) ) / size(realdata, 1);
end

% plot the real data
hold on
plot(realdata', '*', 'Color', [0 0.75 0], 'MarkerSize', 5)
ylim([0 1])