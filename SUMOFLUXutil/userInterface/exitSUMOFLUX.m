function [ynOUTPUTexit, fullSaveName] = exitSUMOFLUX(exitOption)
% exitSUMOFLUX exits with save workspace option
%INPUT: if exitOption==1, the user is asked whether he wants to exit
%INPUT: if exitOption=0, SUMOFLUX terminated due to error, and no option is
%INPUT: available, but the user can choose to save variables to a mat file

fullSaveName = '';

if exitOption
    ynOUTPUTexit = getYNoutput('Are you sure you want to exit?', 0, 0);
else
    ynOUTPUTexit = 1;
end
if ynOUTPUTexit == 1
    repeat = 1;
    while(repeat)
       ynOUTPUTsave = getYNoutput('Save all variables to a .mat file?', 1, 0);
       if ynOUTPUTsave == 1
            FilterSpec = {'*.mat'};
            DialogTitle = 'Save SUMOFLUX workflow';
            DefaultName = 'mySUMOFLUXworkflow';
            [FileName,PathName] = uiputfile(FilterSpec,DialogTitle,DefaultName);

            if ~isempty(FileName)
                %save as MATLAB file
                fullSaveName = [PathName, FileName];
                repeat = 0;
            else
                disp 'No file was chosen'
                repeat = 1;
            end                
       else
            repeat = 0;
       end
    end
end