function [r, modelReactions, excludeMetabolites, inputMetabolites, outputMetabolites, symMetabolites, ratioConstrains, fluxConstrains] = model_inca_bsub()

%prepare the list of model reactions
modelReactions = {...
... % Transport
... % ---------------------------------------------------------------------
      'glc_up' 'glucose (abcdef) -> G6P (abcdef)';...                  
      'CO2up' 'CO2in (a) -> CO2 (a)';...
      'ac_out' 'Ac (ab) -> Acetate (ab)';...                            
      'co2_out' 'CO2 (a) -> CO2out (a)';...                          
      'G6P_bm' 'G6P (abcdef) -> G6Pbm (abcdef)'
      'PGA_bm' 'PGA (abc) -> PGAbm (abc)'
      'P5P_bm' 'P5P (abcde) -> P5Pbm (abcde)'
      'PEP_bm' 'PEP (abc) -> PEPbm (abc)'
      'PYR_bm' 'PYR (abc) -> PYRbm (abc)'
      'OGA_bm' 'OGA (abcde) -> OGAbm (abcde)'
      'OAA_bm' 'OAA (abcd) -> OAAbm (abcd)'
      'E4P_bm' 'E4P (abcd) -> E4Pbm (abcd)'
...
... % Glycolysis
... % ---------------------------------------------------------------------
      'pgi' 'G6P (abcdef) <-> F6P (abcdef)';...                 
      'pfk' 'F6P (abcdef) <-> FBP (abcdef)';...                  
      'fba' 'FBP (abcdef) <-> DHAP (cba) + GAP (def)';...       
      'tpi' 'DHAP (abc) <-> GAP (abc)';...                    
      'gapdh' 'GAP (abc) <-> BPG (abc)';...
      'bpg' 'BPG (abc) <-> PGA (abc)';...                      
      'eno' 'PGA (abc) <-> PEP (abc)';...                      
      'pyk' 'PEP (abc) -> PYR (abc)';...                       
...
... % Pentose phosphate pathway
... % ---------------------------------------------------------------------
      'zwf' 'G6P (abcdef) -> PG6 (abcdef)';...                  
      'gnd' 'PG6 (abcdef) -> P5P (bcdef) + CO2 (a)';...        
      'TK1' 'P5P (abcde) + P5P (fghij) <-> GAP (cde) + S7P (abfghij)';...         
      'TK2' 'P5P (abcde) + E4P (fghi) <-> GAP (cde) + F6P (abfghi)';...          
      'TA' 'S7P (abcdefg) + GAP (hij) <-> E4P (defg) + F6P (abchij)';...     
...
... % Tricarboxylic acid cycle
... % ---------------------------------------------------------------------
      'pdh' 'PYR (abc) -> AcCoA (bc) + CO2 (a)';...            
      'citl' 'OAA (cdef) + AcCoA (ab) -> Cit (fedcba)';...      
      'idh' 'Cit (abcdef) <-> OGA (abcef) + CO2 (d)';...       
      'sdh' 'OGA (abcde) -> Suc (bcde) + CO2 (a)';...       
      'fum' 'Suc (abcd) <-> Mal (abcd)';...                     
      'mdh' 'Mal (abcd) <-> OAA (abcd)';...                     
...
... % Amphibolic reactions
... % ---------------------------------------------------------------------
      'mae' 'Mal (abcd) -> PYR (abc) + CO2 (d)';...            
      'pyc' 'PYR (abc) + CO2 (d) -> OAA (abcd)';...            
      'pck' 'OAA (abcd) -> PEP (abc) + CO2 (d)';...      
... % Acetic acid formation
... % ---------------------------------------------------------------------
      'accoa_ac' 'AcCoA (ab) -> Ac (ab)';...                       
    };

%prepare the reaction structure for the INCA software
r = reaction(modelReactions(:,2));

%make the lists of excluded, input and output metabolites for the flux
%sampling procedure
excludeMetabolites = { 'CO2in' };

inputMetabolites ={'glucose' 'CO2in'}; %; % SUBSTRATES

outputMetabolites ={'G6Pbm' 'PGAbm' 'P5Pbm' 'PEPbm' 'PYRbm' 'OGAbm' 'OAAbm' 'E4Pbm' 'Acetate' 'CO2out'}; % PRODUCTS ALLOWED

%2016-09-28 symMetabolites is added;
%in case no symMetabolites are dedined in the network, leave empty
%symMetabolites = []; 
symMetabolites = [{'Suc'} 4]; %define symmetric metabolites in the model [name number_of_carbons]

ratioConstrains = { {'pgi'} {'zwf'};...
                    {'pyc'} {'mdh'};...
                  };
fluxConstrains = { 'glc_up' 'net' 0 10;...
                   'accoa_ac' 'net' 1 100;...
                 };