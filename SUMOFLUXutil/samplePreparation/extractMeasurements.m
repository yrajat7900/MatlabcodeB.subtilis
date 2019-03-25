function [mat_noise, isotopes_measured] = extractMeasurements(mat_noise, isotopes_simulated, metabolites_measured)

isotopes_simulated_names = cellfun(@(x) x(1:strfind(x,'_')-1), isotopes_simulated, 'UniformOutput', 0);
num_isotopes_measured = nnz(ismember(isotopes_simulated_names, metabolites_measured));
isotopes_measured = cell(num_isotopes_measured, 1);

idx = 1;
for i=1:length(metabolites_measured)
    curiso = isotopes_simulated(ismember(isotopes_simulated_names, metabolites_measured{i}));
    isotopes_measured(idx:(idx+length(curiso)-1)) = curiso;
    idx = idx+length(curiso);
end

[~,~,idx] = intersect(isotopes_measured, isotopes_simulated, 'stable');
mat_noise = mat_noise(idx,:);
