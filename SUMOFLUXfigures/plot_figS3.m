%load predictors for E. coli flux ratios
if exist('SUMOFLUXfigS3.mat', 'file')
    load('SUMOFLUXfigS3.mat');
else
    disp 'Supplementary Figure 3 data not found (file 'SUMOFLUXfigS3.mat')'
    return;
end

targets={'gluconeogenesis / PEP from OAA'...
        'anaplerosis / OAA from PYR'...
        'MAE / PYK'...
        'pgi/zwf'...
               };
 
figure;
fsize = 12;
subplotidx = 1;
subplotRows = length(targets);
subplotColumns = 3;

for i=[4 1 3 2]

    tagFR = targets(i);

    testFR = targetFRcell{i};
    rfTestFR = rfTestOutput{i};
    analyticalTestFR = analyticalTestOutput{i};
    
    subplot(subplotRows,subplotColumns,subplotidx);
    plotHeatmapValidation(testFR, rfTestFR, tagFR);
    ylabel('SUMOFLUX', 'fontSize', fsize);
    
    if subplotidx > (subplotRows-1)*subplotColumns
        xlabel('True ratios', 'fontSize', fsize);
    end 
    
    subplotidx = subplotidx+1;
        
%     %apply to experimental data
    subplot(subplotRows,subplotColumns,subplotidx);
    plotScatterValidation(analyticalEstimates{i}(:,2), analyticalEstimates{i}(:,1), analyticalEstimates{i}(:,3),experimentalPrediction{i}(:,2), experimentalPrediction{i}(:,1), experimentalPrediction{i}(:,3), tagFR{1});
   
    if subplotidx > (subplotRows-1)*subplotColumns
        xlabel('Analytical', 'fontSize', fsize)
    end
    ylabel('SUMOFLUX', 'fontSize', fsize)
    subplotidx = subplotidx+1;
    
    tagFR = targets(i);
    subplot(subplotRows,subplotColumns,subplotidx);
    plotHeatmapValidation(testFR, analyticalTestFR, tagFR);
    ylabel('Analytical', 'fontSize', fsize)
    
    if subplotidx > (subplotRows-1)*subplotColumns
        xlabel('True ratios', 'fontSize', fsize)
    end
    subplotidx = subplotidx+1;
   
end
suptitle('Supplementary Figure 3')

