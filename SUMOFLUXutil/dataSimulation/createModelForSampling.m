function M = createModelForSampling(m, r, modelReactions, inputMetabolites, outputMetabolites, excludeMetabolites)

M.M.names = m.mets.id;
M.M.ncarbons = zeros(size(M.M.names));
for i=1:length(m.mets.id)
    M.M.ncarbons(i) = length(m.mets(i).atoms.id);
end
M.M.num = length(M.M.names);

M.param.b = zeros(1,M.M.num);
M.param.max_exch = zeros(length(r), 1);
M.param.min_exch = zeros(length(r), 1);
M.param.lb = zeros(1,length(r));
M.param.ub = 100*ones(1,length(r));

irrev = cellfun(@(x) isempty(strfind(x, '<->')), modelReactions(:,2));
M.param.max_exch(~irrev) = -1; %default negatove value to be changed afterwards
M.param.lb(~irrev) = -100;

M.param.hr.points_wu = 200;
M.param.hr.points_hr = 5000;
M.param.hr.points_exch = 1;
M.param.hr.iterations = 500;

M.R.id = modelReactions(:,1);
M.R.num = length(M.R.id);
M.R.list = modelReactions(:,2);
M.R.irrev = irrev;

M.inp.num = length(inputMetabolites);
[~,M.inp.ind] = intersect(M.M.names, inputMetabolites, 'stable');
M.inp.names = M.M.names(M.inp.ind);
M.inp.ncarbons = M.M.ncarbons(M.inp.ind);

M.out.num = length(outputMetabolites);
[~,M.out.ind] = intersect(M.M.names, outputMetabolites, 'stable');
M.out.names = outputMetabolites;
M.out.ind = M.out.ind';

M.excl.num = length(excludeMetabolites);
[~,M.excl.ind] = intersect(M.M.names, excludeMetabolites, 'stable');
M.excl.names = excludeMetabolites;
M.excl.ind = M.excl.ind';

M.inner.names = setdiff(M.M.names, [excludeMetabolites inputMetabolites outputMetabolites]);
M.inner.num = length(M.inner.names);
[~,M.inner.ind] = intersect(M.M.names, M.inner.names, 'stable');
M.inner.ind = M.inner.ind';

%create stoichiometric matrix
M.R.SM = zeros(M.M.num, M.R.num);
fluxidx = 1;
for i=1:length(m.rates.flx)
    fluxdir = strfind(m.rates.flx(i).id, '.b');
    if isempty(fluxdir{1}) %it is not backward flux
        [~, subidx] = cellfun(@(x) find(ismember(M.M.names, x)), m.rates.flx(i).sub.id);
        [~, prodidx] = cellfun(@(x) find(ismember(M.M.names, x)), m.rates.flx(i).prod.id);
        for j=1:length(subidx)
            M.R.SM(subidx(j), fluxidx) = M.R.SM(subidx(j), fluxidx)-m.rates.flx(i).sub.val(j);
        end
        for j=1:length(prodidx)
            M.R.SM(prodidx(j), fluxidx) = M.R.SM(prodidx(j), fluxidx) + m.rates.flx(i).prod.val(j);
        end
        fluxidx = fluxidx+1;
    end
end
