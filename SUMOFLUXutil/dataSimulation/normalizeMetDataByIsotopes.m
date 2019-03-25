function [mat_noise_norm] = normalizeMetDataByIsotopes(mat_noise, isotopes)
%normalize values in mat_noise matrix so that isotopes sum to 1
mat_noise_norm = zeros(size(mat_noise));
iso_unique = unique(cellfun(@(x) x(1:(strfind(x, '_')-1)), isotopes, 'UniformOutput', 0), 'stable');

for i=1:length(iso_unique)
    curiso = cell2mat(cellfun(@(x) ~isempty(strfind(x, iso_unique{i})), isotopes, 'UniformOutput', 0));
    curiso = find(curiso);
    for j=1:length(curiso)
        mat_noise_norm(curiso(j),:) = mat_noise(curiso(j),:)./sum(mat_noise(curiso,:), 1);
        mat_noise_norm(curiso(j),isnan(mat_noise_norm(curiso(j),:))) = 1;
    end
end
