%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUMOFLUX workflow for targeted flux ratio estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
disp('Initializing SUMOFLUX demo...');

fullSUMOFLUXfilename = mfilename('fullpath');
[SUMOFLUXpathstr] = fileparts(fullSUMOFLUXfilename);
SUMOFLUXpathstrDirectories = regexp(genpath(SUMOFLUXpathstr),['[^' pathsep ']*'],'match');

pathCell = regexp(path, pathsep, 'split');
%check whether SUMOFLUX is in path
if ispc  % Windows is not case-sensitive
  onPath = cellfun(@(x) any(strcmpi(x, pathCell)), SUMOFLUXpathstrDirectories);
else
  onPath = cellfun(@(x) any(strcmp(x, pathCell)), SUMOFLUXpathstrDirectories);
end
addpath(strjoin(SUMOFLUXpathstrDirectories(onPath==0), pathsep));

%Prerequisites:
% INCAv1.4 software
% freely available at
% http://mfa.vueinnovations.com/about
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp('******************************************************');
disp('SUMOFLUX demo options')
disp('note: leave blank to use default value in square bracket []');
disp(' ')
disp('    1: Regenerate SUMOFLUX manuscript figures')
disp('    2: Demo SUMOFLUX workflow for E. coli or B. subtilis')
disp(' ')

repeat = 1;
while repeat
    task = input('Specify SUMOFLUX demo option (type 1 or 2) [exit]  >>');
    if isempty(task)
        disp('No task chosen. SUMOFLUX terminated')
        return
    end
    if task >0 && task < 3
        repeat = 0;
    else
        disp('***input error, try again***');
    end
end
switch task
    case 1
        %Generate figures from the SUMOFLUX manuscript
        GenerateSUMOFLUXfigures();
        return
    case 2
        %start SUMOFLUX workflow
        SUMOFLUXworkflow();
    otherwise
        disp 'Unknown task. SUMOFLUX closing...';
        return;
end


