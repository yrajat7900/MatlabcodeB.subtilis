function [V] = samplingBoundRatioNoGrowth_inca(M, varargin)

V = [];

%if upper and lower boundaries of a reaction are 0, remove it from the
%system
zeroRxnIdx = M.param.lb==0 & M.param.ub==0;
M.param.lb(zeroRxnIdx) = [];
M.param.ub(zeroRxnIdx) = [];
M.param.max_exch(zeroRxnIdx) = [];
M.param.min_exch(zeroRxnIdx) = [];
M.R.id(zeroRxnIdx) = [];
M.R.num = M.R.num-nnz(zeroRxnIdx);
M.R.list(zeroRxnIdx) = [];
M.R.irrev(zeroRxnIdx) = [];
M.R.SM(:,zeroRxnIdx) = [];



%reference vector for the optimization function
refvec = ones(size(M.R.SM, 2),1) * (max(abs(M.param.b))/2);
%refvec(M.inner.ind) = max(abs(ls.b))/2;
%define optimization function for flux vector x with additional parameter refvec
opt_fun = @(x)my_lin_f1(x,refvec);

% get intracellular flux equation indeces
inner_idx = setdiff(1:M.M.num,[M.excl.ind M.out.ind]);%M.inner.ind;
x0 = zeros(size(M.R.SM, 2),1); %initial solution
Aequal = M.R.SM(inner_idx,:); %equality constraints Aequal x=beq
beq = M.param.b(inner_idx)';
lb = M.param.lb';%upper and lower bounds for the fluxes in vector x
ub = M.param.ub';

%add flux ratio inequality constraints
%if they are provided in varargin in the format "flux indeces", "lb ub"
% A = zeros(1, size(Aequal, 2));
% b = 0;
A = -M.R.SM(M.out.ind,:);
b = M.param.b(M.out.ind)';

if nargin == 3
    fluxIDX = varargin{1};
    %adjust the indices if zero reactions have been removed
    allIDX = (1:length(zeroRxnIdx));
    allIDX(zeroRxnIdx) = [];
    for fi = 1:numel(fluxIDX)
        for ffi=1:length(fluxIDX{fi})
            if fluxIDX{fi}(ffi)
                fluxIDX{fi}(ffi) = find(ismember(allIDX, abs(fluxIDX{fi}(ffi))))*sign(fluxIDX{fi}(ffi));
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    ratioBounds = varargin{2};
    A = zeros(2*size(fluxIDX,1), size(Aequal, 2));
    b = zeros(2*size(fluxIDX,1),1);
    idx = 1;
    for i=1:size(fluxIDX,1)
        nominator = fluxIDX{i,1};
        denominator = fluxIDX{i,2};
        A(idx, abs(nominator)) = (ratioBounds(i,1)-1).*sign(nominator);
        A(idx, abs(denominator)) = ratioBounds(i,1).*sign(denominator);
        
        idx = idx+1;
        A(idx, abs(nominator)) = (1-ratioBounds(i,2)).*sign(nominator);
        A(idx, abs(denominator)) = (-ratioBounds(i,2)).*sign(denominator);
       
        idx = idx+1;
    end
    %add inequality constraints
    A = [-M.R.SM(M.out.ind,:); A];
    b = [M.param.b(M.out.ind)'; b];
end

options = optimset('Algorithm', 'interior-point', 'Display', 'off');
y = fmincon(opt_fun, x0, A, b, Aequal, beq, lb, ub, [], options);
% small values equal zero (computational zero)
y(abs(y)<=eps) = 0;   
           
% uniform sampling
n = 1;
% calculate the null space of A and generate fluxes from the null space
xn = null(Aequal,'r');
null_space_dim = size(xn,2);
% normalize vectors from the null space
for i = 1:null_space_dim
    %xn(:,i)=xn(:,i)./sum(xn(:,i));
    %xn(:,i)=xn(:,i)./max(xn(:,i)); %latest working version
    xn(:,i)=xn(:,i)./sqrt(sum(max(xn(:,i)).^2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try to not add anything to reactions with ub=0
zeroxn = sum(xn(M.param.ub==0,:), 1);% + sum(xn(M.param.ub==M.param.lb,:), 1);
xn = xn(:,zeroxn==0);
xn(M.param.ub==M.param.lb,:) = 0;
null_space_dim = size(xn,2);

% factor to multiply random numbers (is half of the input flux)
[~, inputflux] = find(M.R.SM(M.inp.ind(M.inp.ncarbons==max(M.inp.ncarbons)),:)==-1);
maxinputflux = max(y(inputflux));
fac = maxinputflux/2;
%fac = max(abs(M.param.b))/2;
%tolerance for equality constraints
tol = 1e-13;

X = zeros(size(xn,1),M.param.hr.points_hr);
iterations_count = 0;
%number of iterations to walk from the optimal solution
iterations = null_space_dim*5;
%amount of hit-and-run attempts to consider infeasibility
total_attempt_amount = 5*M.param.hr.points_hr;
current_attempt = 0;
while n <= M.param.hr.points_hr
    moved = 0;
    for i = 1:null_space_dim
        % generate random number from [-1;1]
        lambda = 2*rand-1;
        % new flux vector (y) - add a null vector multiplied by factor 
        % and random number 
        new_y = y + fac*lambda*xn(:,i);
        % if all the constraints are satisfied, move to this new
        % solution
        if ~(sum(new_y<lb) || sum(new_y>ub))
            if not(sum(abs(Aequal*new_y-beq)>tol) || sum(A*new_y>b))
                y = new_y;
                iterations_count = iterations_count+1;
                moved = moved + 1;
            end
        end
    end
    % if walked more then 10 x null_dim times, add new flux vector
    % (to ensure that walked far enough)
    if iterations_count >= iterations
        X(:,n) = y;
        iterations_count = 0;
        % increase number of fluxes (unique)
        n = n + 1;
    end

    current_attempt = current_attempt+1;
    if current_attempt>total_attempt_amount && n == 1
        %V = 0;
        disp 'Constraint seem to be infeasible'
        return
    end
end


% now we have X - vector of randomized net fluxes
% randomize exchange fluxes within net fluxes

F = X;
V.net = zeros(M.R.num,M.param.hr.points_exch*size(F,2));
V.f = zeros(M.R.num,M.param.hr.points_exch*size(F,2));
V.b = zeros(M.R.num,M.param.hr.points_exch*size(F,2));
V.ex = zeros(M.R.num,M.param.hr.points_exch*size(F,2));
%V.mu = zeros(1,M.param.hr.points_exch*size(F,2));

n = 1;
for vi = 1:size(F,2) % for each flux vector
    for ei = 1:M.param.hr.points_exch 
        for ri = 1:M.R.num  %for each flux (rection)
            if M.R.irrev(ri) %if flux is irreversible, xch=0
                V.f(ri,n) = F(ri,vi);
                V.b(ri,n) = 0;
                V.ex(ri,n) = 0;
                V.net(ri,n) = F(ri,vi);
            else
                if abs(F(ri,vi))<1e-12 %if net flux is (almost)zero, f=b
                    V.f(ri,n) = rand*M.param.ub(ri); %forward is some random value in the range
                    V.b(ri,n) = V.f(ri,n);
                    V.ex(ri,n) = V.f(ri,n);
                    V.net(ri,n) = 0;
                else
                    switch sign(F(ri,vi)) %switch sign of the net flux
                        case 0 %the same as flux~0
                            V.f(ri,n) = rand*M.param.ub(ri); 
                            V.b(ri,n) = V.f(ri,n);
                            V.net(ri,n) = 0;
                            V.ex(ri,n) = 1;
                        case 1 %Vf>Vb
                            %ub_exch = min([(M.param.ub(ri)-F(ri,vi))/(M.param.ub(ri)+eps) M.param.max_exch(ri)]);
                            ub_exch = M.param.max_exch(ri);
                            V.ex(ri,n) = F(ri,vi) * (rand*(ub_exch-M.param.min_exch(ri))+M.param.min_exch(ri));
                            V.f(ri,n) = F(ri,vi)+V.ex(ri,n);
                            V.b(ri,n) = V.ex(ri,n);
                            V.net(ri,n) = F(ri,vi);
                        case -1 %Vf<Vb
                            %ub_exch = min([(M.param.lb(ri)-F(ri,vi))/(M.param.lb(ri)+eps) M.param.max_exch(ri)]);
                            ub_exch = M.param.max_exch(ri);
                            V.ex(ri,n) = -F(ri,vi) * (rand*(ub_exch-M.param.min_exch(ri))+M.param.min_exch(ri));
                            V.b(ri,n) = V.ex(ri,n)-F(ri,vi);
                            V.f(ri,n) = V.ex(ri,n);
                            V.net(ri,n) = F(ri,vi);
                    end
                end
            end
        end
        %V.mu(n) = F(ri+1,vi)/100;
        n = n + 1;
    end
end

% add zeros for reactions which are zeros (lb=ub=0)
if nnz(zeroRxnIdx)
    V.net(zeroRxnIdx==0,:) = V.net;
    V.net(zeroRxnIdx==1,:) = zeros(nnz(zeroRxnIdx), size(V.net,2));
    V.f(zeroRxnIdx==0,:) = V.f;
    V.f(zeroRxnIdx==1,:) = zeros(nnz(zeroRxnIdx), size(V.f,2));
    V.b(zeroRxnIdx==0,:) = V.b;
    V.b(zeroRxnIdx==1,:) = zeros(nnz(zeroRxnIdx), size(V.b,2));
    V.ex(zeroRxnIdx==0,:) = V.ex;
    V.ex(zeroRxnIdx==1,:) = zeros(nnz(zeroRxnIdx), size(V.ex,2));
end