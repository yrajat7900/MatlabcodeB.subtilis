function [ynOUTPUT,fullSaveName] = getYNoutput(inputString, defaultOPTION, exitOPTION)
%SUMOFLUX user interface get yes/no output
%INPUT: inputString is yes/no question
%INPUT: defaultOPTION is 1 if YES and 0 if NO
%INPUT: exitOPTION is 1 if there is option to exit by pressing Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%returns ynOUTPUT = 0 if the answer is NO
%returns ynOUTPUT = 1 if the answer is YES
%returns ynOUTPUT = -1 if the exit option was chosen
%returns fullSaveName if the user chose to save the workspace to file

fullSaveName = '';

if exitOPTION
    allowedValues = {'Y', 'N', 'Q'};
else
    allowedValues = {'Y', 'N'};
end

repeat = 1;
    while repeat    %Inquire the simulation procedure
        if defaultOPTION
            str = input(sprintf('%s (Y/N) [Y]  >>', inputString), 's');
        else
            str = input(sprintf('%s (Y/N) [N]  >>', inputString), 's');
        end
        if isempty(str)
           ynOUTPUT = defaultOPTION;
           repeat = 0;
        elseif ~ismember(upper(str), allowedValues)
            if exitOPTION
                disp('***input error, try again (Y/N) (or press Q to exit)***');
            else
                disp('***input error, try again (Y/N)***');
            end
        else
            if isequal(upper(str), 'Y')
                 ynOUTPUT = 1;
                 repeat = 0;
            end
            if isequal(upper(str), 'N')
                 ynOUTPUT = 0;
                 repeat = 0;
            end
            if isequal(upper(str), 'Q')
                if exitOPTION
                  fullSaveName = exitSUMOFLUX(1); %confirm the exit and get file name if save
                else
                    disp('***input error, try again (Y/N)***');
                end
            end
        end
    end