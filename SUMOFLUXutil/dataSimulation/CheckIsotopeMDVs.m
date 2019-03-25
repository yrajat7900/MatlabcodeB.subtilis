function [passcheck] = CheckIsotopeMDVs(Smdv, isotopes)

isotopeNames = cellfun(@(x)x(1:strfind(x, '_')-1), isotopes, 'UniformOutput', 0);
isotopeNames_unique = unique(isotopeNames, 'stable');

passcheck = zeros(1, size(Smdv,2));
for i=1:length(isotopeNames_unique)
    curiso = ismember(isotopeNames, isotopeNames_unique{i});
    mdvSum = sum(abs(Smdv(curiso,:)));
    passcheck = passcheck + ( abs(mdvSum-1) > 0.0000001 ) + isnan(mdvSum) + isinf(mdvSum);
end

passcheck = passcheck==0;
