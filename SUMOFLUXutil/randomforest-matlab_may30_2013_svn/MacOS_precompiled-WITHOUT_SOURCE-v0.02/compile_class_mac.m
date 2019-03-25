% ********************************************************************
% * mex File compiling code for Random Forest (for linux)
% * mex interface to Andy Liaw et al.'s C code (used in R package randomForest)
% * Added by Abhishek Jaiantilal ( abhishek.jaiantilal@colorado.edu )
% * License: GPLv2
% * Version: 0.02
% ********************************************************************/
function compile_class_mac

    % execute this function in the src directory, and it will generate two
    % *.mexmaci64 files, that you have to move to the folder above

    %Matlab mex requires optimization to be all set in the mexopts.sh(or
    %.bat) file. So set it there not here

%%sometimes you have to add -lgfortran at the end of both command lines below
    mex mex_ClassificationRF_train.cpp  classRF.cpp classTree.cpp rfutils.cpp cokus.cpp rfsub.o -output mexClassRF_train -lm -DMATLAB -O
    mex mex_ClassificationRF_predict.cpp  classRF.cpp classTree.cpp rfutils.cpp cokus.cpp rfsub.o -output mexClassRF_predict -lm -DMATLAB -O

    fprintf('Mex compiled\n')
    
end