function saveFileName = openSaveFileDialog(FilterSpec, DialogTitle, DefaultName)
 
saveFileName = '';
repeat = 1;
    while(repeat)
       ynOUTPUTsave = getYNoutput('Save created variable(s) to a .mat file?', 1, 0);
       if ynOUTPUTsave == 1
            [FileName,PathName] = uiputfile(FilterSpec,DialogTitle,DefaultName);

            if ischar(FileName)
                if ~isempty(FileName)
                    %save as MATLAB file
                    saveFileName = [PathName, FileName];
                    repeat = 0;
                end
            else
                disp 'No file was chosen'
                repeat = 1;
            end                
       else
            repeat = 0;
       end
    end