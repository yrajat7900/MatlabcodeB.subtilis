function plotHeatmapValidation(real, predicted, varargin)

% check whether the real and predicted are vertical vectors
if size(real,1) < size(real,2)
    real = real';
end
if size(predicted,1) < size(predicted,2)
    predicted = predicted';
end

% bin the values into a 3d histogram to create a density matrix 
nBins_x = 50;
nBins_y = 50;
[counts, bin_centers] = hist3([real, predicted], [nBins_x nBins_y]);
x_bin_centers = bin_centers{1};
y_bin_centers = bin_centers{2};

%plot the figure
%fig = figure;
imagesc(x_bin_centers, y_bin_centers, counts')
axis xy

%define colormap
T = [ 1 1 1; 0.8 0.4 0; 0 0.45 0.7];
x = [0 0.5 1];
map = interp1(x, T, linspace(0,1,255));
cmap = [0.75 0.75 0.75; map];
%%%%%%%%%%%%%%%%


colormap(cmap)

hold on
plot([0 1], [0 1], 'k')

axis square
xlim([0 1])
ylim([0 1])
set(gca,'color',[0.75 0.75 0.75])

fsize = 10;
set(gca, 'XTick', [0 0.5 1])
set(gca, 'XTickLabel', {'0' '0.5' '1'})
set(gca, 'YTick', [0 0.5 1])
set(gca, 'YTickLabel', {'0' '0.5' '1'})
set(gca, 'fontSize', fsize);


colorbar

tag='';
if nargin>2
    tag = varargin{1};
end
mae = mean(abs(real-predicted));
title([tag, sprintf('mae=%.2f', mae)])
  
