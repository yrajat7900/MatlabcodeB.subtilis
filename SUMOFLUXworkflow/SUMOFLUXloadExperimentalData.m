function [experimentalData, experimentalStrains, metabolites_measured]=...
            SUMOFLUXloadExperimentalData(isotopes_measured)
    
disp '***********************************************************************************************'
disp 'Provide experimental data file'
disp '(for E. coli demo, choose SUMOFLUXexperimentalData_ECOLI113C.mat or'
disp 'SUMOFLUXexperimentalData_ECOLI20U13C.mat,' 
disp 'for B. subtilis demo choose SUMOFLUXexperimentalDataBSUB.mat)'
disp ' '
     
experimentalData=[];
experimentalStrains=[];
metabolites_measured=[];

FilterSpec = '*.mat; *.xlsx; *.xls';
DialogTitle = 'Provide the experimental data file';
DefaultName = 'SUMOFLUXexperimentalData_ECOLI113C.mat';

fullSUMOFLUXfilename = mfilename('fullpath');
[SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
parentFolder = strfind(SUMOFLUXpathstr, filesep);
SUMOFLUXpathstr = SUMOFLUXpathstr(1:parentFolder(end));
SUMOFLUXpathstr = [SUMOFLUXpathstr, 'SUMOFLUXdata', filesep, 'experimental', filesep];

varNames = {'experimentalData', 'experimentalStrains', 'metabolites_measured'};
repeat = 1;
while(repeat)
    loadedData = openReadFileDialog(SUMOFLUXpathstr, FilterSpec, DialogTitle, DefaultName, 'on', varNames);

    if isempty(loadedData.experimentalData) || isempty(loadedData.metabolites_measured)
        disp 'Error reading the data file'
        loadAnotherFile = getYNoutput('Load another measurement file?', 1, 0);
        if loadAnotherFile
            repeat = 1;
        else
            return;
        end
    else
        %check whether the measured metabolites are the same as in the
        %sample
        experimentalData = loadedData.experimentalData;
        experimentalStrains = loadedData.experimentalStrains;
        metabolites_measured = loadedData.metabolites_measured;

        if iscell(experimentalData)
            experimentalData = cat(1,experimentalData{:});
            metabolites_measured = cat(1, metabolites_measured{:});
        end
            
        [isotopes_measured_loaded] = extractIsotopes(isotopes_measured, metabolites_measured);
     
        if ~isequal(isotopes_measured_loaded, isotopes_measured)
            experimentalData = [];
            experimentalStrains = [];
            metabolites_measured = [];
            disp 'Error: Measured and simulated metabolites lists are not equal'
            loadAnotherFile = getYNoutput('Load another measurement file?', 1, 0);
            if loadAnotherFile
                repeat = 1;
            else
                repeat = 0;
            end
        else
            repeat = 0;
        end
                   
    end
end