function [mat,tags] = extractRatio(L,V,M)
% Usage: extract_ratio(L,V,M)
%        L list of ratios
%        V fluxes
%        M model

k = 1:size(V.net,2);
mat = zeros(size(L,1), size(V.net,2));
tags = cell(size(L,1),1);

% List of ratios has the format {ratio name; react1; react1,react2}
for ri = 1:size(L,1)
   R.tag = L{ri,1}; %get the name (tag) of ratio
   nom = reshape(L{ri,2},3,[]); %reshape nominator in form {1, name, type} 
   den = reshape(L{ri,3},3,[]); %reshape denominator in form {1, name, type}{1, name, type}
   nvec = 0; 
   for ni = 1:size(nom,2)
       [tf,loc] = ismember(nom{2,ni},M.R.id); % check if this reaction is in the reation list 
       if tf && isfinite(nom{1,ni})
           %multiply reaction by flux value for this reaction
           switch nom{3,ni}
               case 'net'
                   nvec = nvec + nom{1,ni}*V.net(loc(1),k);                      
               case 'b'
                   nvec = nvec + nom{1,ni}*V.b(loc(1),k);
               case 'f'
                   nvec = nvec + nom{1,ni}*V.f(loc(1),k);
               case 'ex'
                   nvec = nvec + nom{1,ni}*V.ex(loc(1),k);
               otherwise
                  disp(['! unknown flux kind in ' R.tag]); 
                  mat = [];
                  return
           end
       else
           disp(['! syntax error or unknown compound (' nom{2,ni} ') in definition of ' R.tag]);   
           mat = [];
           return
       end
   end
   dvec = 0;
   for di = 1:size(den,2)
       [tf,loc] = ismember(den{2,di},M.R.id);
       if tf && isfinite(den{1,di})
           switch den{3,di}
               case 'net'
                   dvec = dvec + den{1,di}*V.net(loc(1),k);
               case 'b'
                   dvec = dvec + den{1,di}*V.b(loc(1),k);
               case 'f'
                   dvec = dvec + den{1,di}*V.f(loc(1),k);
               case 'ex'
                   dvec = dvec + den{1,di}*V.ex(loc(1),k);
               otherwise
                  disp(['! unknown flux kind in ' R.tag]);   
                  mat = [];
                  return
           end
       else
           disp(['! syntax error or unknown compound (' den{2,di} ') in definition of ' R.tag]);  
           mat = [];
           return
       end
   end
   % mat is a vector of reaction ratios for all simulations (ri is the
   % reation ratio index)
   mat(ri,:) = nvec./(dvec+eps);
   tags{ri} = R.tag;
end