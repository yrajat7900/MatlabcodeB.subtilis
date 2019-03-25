function fluxRatio_list = SUMOFLUXstep4()
% STEP 4
% Calculate the flux ratio of interest
disp ' '
disp '***********************************************************************************************'
disp 'STEP 4: Define the flux ratios of interest'
disp ' '
disp 'Provide file containing the list of flux ratios of interest'
disp '(for E. coli or B. subtilis demo, choose inputRatios.m)'
disp ' '

% Load experimental data to define which measurements are available
FilterSpec = {'*.m'};
DialogTitle = 'Provide the flux ratios file';
DefaultName = 'inputRatios.m';

fullSUMOFLUXfilename = mfilename('fullpath');
[SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
parentFolder = strfind(SUMOFLUXpathstr, filesep);
SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
SUMOFLUXpathstr = [SUMOFLUXpathstr, 'SUMOFLUXinput', filesep];

varNames = {'fluxRatio_list'};
loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'off', varNames);
if ~isempty(loadedData)
        disp(' ')
        disp '***********************************************************************************************'
        disp 'Successfully loaded flux ratio list'
        fluxRatio_list = loadedData.fluxRatio_list;
        clear loadedData
else
    disp 'Error in reading file'
    return;
end


