function GENERATION = dispatch(CURRENT_STATE,GMIN,GMAX,DEMAND,HOUR,GEN_ORDER)
%% --------------------------------------------------------------------------------------------------------------
% For the given state, calculates the MW output for each commited generator
% Generators are dispatched in a merit order (first the least expensive, last the most expensive)
% Note: GEN_ORDER is based on No Load Cost, Fuel Cost and Incremental costs.
% OUTPUT:
% GENERATION [NG x 1] - vector of power output for each generator
% ---------------------------------------------------------------------------------------------------------------
GENERATION = GMIN.*CURRENT_STATE;               % first set the output for each commited generator to their minimal stable generation
LOAD = DEMAND(HOUR) - sum(GENERATION);          % then reduce the load for the total minimal generation
for K = 1:length(CURRENT_STATE);                % note that CURRENT_STATE is the feasible one, ie.  demand may be supplied by commited generators
    L = GEN_ORDER(K);                                                           % GEN_ORDER is the merit list of dispatching generators
    GENERATION(L) = GENERATION(L) + min(GMAX(L)-GMIN(L),LOAD)*CURRENT_STATE(L); % increase the power of the next generator in the list
    LOAD = LOAD - min(GMAX(L)-GMIN(L),LOAD)*CURRENT_STATE(L);                   % either to their max. or to match the load
end                                                                             % whenever generation increases, load reduces, until they match
end