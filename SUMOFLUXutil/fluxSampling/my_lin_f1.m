function [val,nErr] = my_lin_f1(x, refvec)

nErr = 0;

%compute objective function value
val = sum((1/(max(abs(x))+eps)).*((x-refvec).^2));

