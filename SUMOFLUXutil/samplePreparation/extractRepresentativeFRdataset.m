function [targetFR, mat_noise, sampleidx] = extractRepresentativeFRdataset(targetFR, mat_noise, varargin)

sampleidx = find(targetFR>=0 & targetFR <=1);
targetFR = targetFR(sampleidx);
mat_noise = mat_noise(:, sampleidx);

[targetFR, unique_idx] = unique(targetFR);
mat_noise = mat_noise(:, unique_idx);
sampleidx = sampleidx(unique_idx);

uniform_idx = UniformizeTarget(targetFR);
targetFR = targetFR(uniform_idx);
mat_noise = mat_noise(:, uniform_idx);
sampleidx = sampleidx(uniform_idx);

%check if there is a limit for the sample size
if nargin>2
    maxSampleSize = varargin{1};
    if length(sampleidx) > maxSampleSize
        sidx = randi(length(sampleidx), maxSampleSize, 1);
        targetFR = targetFR(sidx);
        mat_noise = mat_noise(:, sidx);
        sampleidx = sampleidx(sidx);
    end    
end

% targetFR is a vector of size [sample_size, 1]
% mat_noise is a matrix of size [sample_size, number_of_features]
if size(targetFR,1) == 1
    targetFR = targetFR';
end
if size(mat_noise, 1) ~=size(targetFR,1)
    mat_noise = mat_noise';
end

end


function sampleidx = UniformizeTarget(target)
    %bin target and take equal amount of samples from each bin

    [n, bins] = hist(target, 100);
    binsize = ceil(median(n)/2);
    binwidth = (bins(2)-bins(1))/2;
    totalSize = binsize*(length(n)+1);
    sampleidx = zeros(1, totalSize);
    curidx = 1;
    for i=1:length(bins)
        idx = find(target>=bins(i)-binwidth & target<=bins(i)+binwidth);

        if length(idx) < binsize
            portion = length(idx);
            sampleidx(curidx:(curidx+portion-1)) = idx;
            curidx = curidx+portion;
        else
            cursampleidx = randperm(length(idx),binsize);
            portion = length(cursampleidx);
            sampleidx(curidx:(curidx+portion-1)) = idx(cursampleidx);
            curidx = curidx+portion;
        end
    end
    sampleidx(sampleidx==0)=[];
end