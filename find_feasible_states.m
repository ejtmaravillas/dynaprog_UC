function [FEASIBLE_STATES_NUM,SUCCESS] = find_feasible_states(GMINlst,GMAXlst,DEMAND,HOUR,RES_UP,RES_DN)
%% --------------------------------------------------------------------------------------------------------------
% Determines all feasible states from the list of possible states
% Feasable states are the states where demand is between total min and total max output of commited generators
% If no feasible states found, program prepares termination
% OUTPUT:
% FEASIBLE_STATES_NUM   - vector of positions (columns) of feasible states in the list of states for current hour
% SUCCESS               - indicator: 1 - found at least one feasible states; 0 - no feasible states found
%----------------------------------------------------------------------------------------------------------------
FEASIBLE_STATES_NUM = find((GMINlst <= DEMAND(HOUR)-RES_DN(HOUR)) & (DEMAND(HOUR)+RES_UP(HOUR) <= GMAXlst));

if isempty(FEASIBLE_STATES_NUM)         % if there are no feasible states found
    SUCCESS = 0;                        % prepare for program termination
    STR = ['NO FEASIBLE STATES FOR HOUR ',num2str(HOUR),'! PROGRAM TERMINATES!'];
    msgbox(STR,'NO FEASIBLE STATES','warn');
    return
else
    SUCCESS = 1;
end
end