function evaluate_solution(NT,BEST_PATH,LIST_STATES,GMIN,GMAX,DEMAND,GEN_ORDER,GNLC,GFC,GINC,GSC,INI_STATE,NG,...
    GRAMPUP,GRAMPDOWN,COEF_A,COEF_B,COEF_C,DISPATCH_METHOD,DETAIL_PRINT_FLAG,GSDC,GSTATINI,...
    GMINUP,GMINDOWN,START_UP_COST_METHOD,GCSTIME,GSH,ALPHA,BETA,TAU)
%% --------------------------------------------------------------------------------------------------------------
% For the given set BEST_PATH of the states in each time step, calculates production costs, transition costs
% total costs etc.
% In the end, this function calls function to print the results in a tabulated form.
% This function follows pretty much the same fashion as the main procedure and will not be described in details.
% The only difference is that now the optimal path is known, so there is no need for searching.
% For each state in the path this procedure calculates the costs and finally calls the printing routine.
% ---------------------------------------------------------------------------------------------------------------
GEN_START_SHUT_COST1 = zeros(NG,NT);
GEN_PRODUCTION1      = zeros(NG,NT);
PROD_COST1           = zeros(NG,NT);
FCOST1               = zeros(NT,1);
GENERATING_COST1     = zeros(NT,1);
GEN_PRODUCTION       = zeros(NG,1);
X  = GSTATINI;
for HOUR = 1:NT
    PREV_STATES_NUM = BEST_PATH(HOUR);
    FEASIBLE_STATES_NUM = BEST_PATH(HOUR+1);
    X_PREV = X;
    if HOUR==1 & PREV_STATES_NUM == 0
        PREVIOUS_STATE = INI_STATE;
    else
        PREVIOUS_STATE = LIST_STATES(:,PREV_STATES_NUM);
    end
    CURRENT_STATE  = LIST_STATES(:,FEASIBLE_STATES_NUM);
    PRODUCTION_PREV = GEN_PRODUCTION;
    [GEN_PRODUCTION,PROD_COST] = production(CURRENT_STATE,PREVIOUS_STATE,GMIN,GMAX,DEMAND,HOUR,GNLC,GFC,GINC,NG,GRAMPUP,GRAMPDOWN,PRODUCTION_PREV,GEN_ORDER,COEF_A,COEF_B,COEF_C,DISPATCH_METHOD);

    STATE_DIFF = CURRENT_STATE - PREVIOUS_STATE;
    [X,SUCCESS] = check_up_down_time(CURRENT_STATE,PREVIOUS_STATE,X_PREV,GMINUP,GMINDOWN,NG);


    if START_UP_COST_METHOD == 1   % start-up costs are constant and equal to cold start cost
        GEN_START_SHUT_COST = (STATE_DIFF > 0) .* GSC;
    elseif START_UP_COST_METHOD == 2
        GEN_START_SHUT_COST =                       ((STATE_DIFF > 0) & (-X_PREV >= (GMINDOWN + GCSTIME))) .* GSC;  % hot start-up cost
        GEN_START_SHUT_COST = GEN_START_SHUT_COST + ((STATE_DIFF > 0) & (-X_PREV <  (GMINDOWN + GCSTIME))) .* GSH;  % cold start-up cost
    else
        GEN_START_SHUT_COST = (STATE_DIFF > 0) .* (ALPHA + BETA .* (1-exp(X_PREV ./ TAU)));
    end

    GEN_START_SHUT_COST = GEN_START_SHUT_COST + (STATE_DIFF < 0 ) .* GSDC;       % shut down cost

    if HOUR == 1
        TOTAL_COST = sum(PROD_COST) + sum(GEN_START_SHUT_COST);
    else
        TOTAL_COST = sum(PROD_COST) + sum(GEN_START_SHUT_COST) + FCOST1(HOUR-1);
    end % if HOUR
    FCOST1(HOUR) = TOTAL_COST;
    GENERATING_COST1(HOUR) = sum(PROD_COST);
    GEN_PRODUCTION1(:,HOUR) = GEN_PRODUCTION;
    PROD_COST1(:,HOUR) = PROD_COST;
    GEN_START_SHUT_COST1(:,HOUR) = GEN_START_SHUT_COST;

end   % HOUR = 1:NT
GEN_START_SHUT_COST_TOTAL = sum(GEN_START_SHUT_COST1).';

print_results(BEST_PATH,LIST_STATES,INI_STATE,NT,NG,GMIN,GMAX,DEMAND,FCOST1,GENERATING_COST1,GEN_PRODUCTION1,PROD_COST1,GEN_START_SHUT_COST1,DETAIL_PRINT_FLAG)
end


