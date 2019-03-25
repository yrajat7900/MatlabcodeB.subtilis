function crossValidateParameters(mat_noise, targetFR, nvalid, ntreevec, mtryvec)

lcCrossValidationMAE = zeros(length(ntreevec), length(mtryvec));
lcCrossValidationTime = zeros(length(ntreevec), length(mtryvec));
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nvalid-fold cross validation for the metaparameter search
validGroups = randi(nvalid, length(targetFR),1);
for ntree_i=1:length(ntreevec)
    for mtry_i = 1:length(mtryvec)
        numtrees = ntreevec(ntree_i);
        mtry = mtryvec(mtry_i);
        avgtime = 0;
        maeValid = 0;
        for vi=1:nvalid
            tic
                [rfmodel] = regRF_train(mat_noise(:, validGroups~=vi)', targetFR(validGroups~=vi)', numtrees, mtry);
            eltime=toc;
            [rfvalidoutput] = regRF_predict(mat_noise(:, validGroups==vi)', rfmodel);
            maeValid = maeValid + sum(abs(targetFR(validGroups==vi)-rfvalidoutput'));
            avgtime = avgtime+eltime;
        end
        maeValid = maeValid/length(target);

        lcCrossValidationMAE(ntree_i, mtry_i) = maeValid;
        lcCrossValidationTime(ntree_i, mtry_i) = avgtime/nvalid;
    end
end