function noisedSample = addNoise(sample, noise, varargin)
    noisedSample = zeros(size(sample));
% SUPERIMPOSE NOISE
    if noise
        for j = 1:size(sample, 2)
            e1 = randn(size(sample,1),1)*noise/5;
            e2 = (rand(size(sample,1),1)-0.5)*noise;
            new = sample(:,j)+e1+e2;
            if nargin<3
                new(new>1)=1;
                new(new<0)=0;
            else
                truncate01 = varargin{1};
                if truncate01
                    new(new>1)=1;
                    new(new<0)=0;
                end
            end
                    
            noisedSample(:,j)= new;
        end
    end
    