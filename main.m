function main()
%------------------------------------------------------------------------------------------------
% UNIT COMMITMENT BY DYNAMIC PROGRAMMING METHOD
%------------------------------------------------------------------------------------------------
%%
tic                                     % initialize timer
clc
warning off
%------------------------------------------------------------------------------------------------
% read input data from a file
DP_input_data;

GMIN            = gen_data(:, 2);           % generator min power                           [MW]
GMAX            = gen_data(:, 3);           % generator max. power                          [MW]
GINC            = gen_data(:, 4);           % incremental heat rate                         [BTU/kWh]
GNLC            = gen_data(:, 5);           % generator no load cost                        [?/h]
GSC             = gen_data(:, 6);           % generator start up cost (cold), also BETA     [?]
GFC             = gen_data(:, 7);           % generator fuel cost                           [?/MBTU]
GMINUP          = gen_data(:, 8);           % generator min. up time                        [h]
GMINDOWN        = gen_data(:, 9);           % generator min. down time                      [h]
GSTATINI        = gen_data(:,10);           % generator initial status (time on/off)        [h]
GSH             = gen_data(:,11);           % generator start up cost (hot), also ALPHA     [?]
GCSTIME         = gen_data(:,12);           % generator cold start time                     [h]
GRAMPUP         = gen_data(:,13);           % generator ramp up rate                        [MW/h]
GRAMPDOWN       = gen_data(:,14);           % generator ramp down rate                      [MW/h]
COEF_A          = gen_data(:,15);           % free term in quadratic-cost function          [?]
COEF_B          = gen_data(:,16);           % linear term in quadratic-cost function        [?/MWh]
COEF_C          = gen_data(:,17);           % 2nd order term in quadratic-cost function     [?/(MW^2)h]
GSDC            = gen_data(:,18);           % generator shut down cost                      [?]
TAU             = gen_data(:,19);           % generator shut up cost exp. coef.             [?]
%------------------------------------------------------------------------------------------------
NG              = size(gen_data,1);         % no. of generators
NT              = size(DEMAND,1);           % number of time periods (hours)
%------------------------------------------------------------------------------------------------

%------------------------------------------------------------------------------------------------
% check up the availability of data for certain cases:
if (DISPATCH_METHOD == 2 || DISPATCH_METHOD == 3) & (any(isnan(GNLC)) || any(isnan(GFC)) || any(isnan(GINC)))
    STR = ['To use linear cost model, you must provide data for NO LOAD COSTS,'...
        'FUEL COSTS and INCREMENTAL COSTS.'];   % there are no data for quick dispatch method,
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');       % write a message
    return
elseif DISPATCH_METHOD == 1 & (any(isnan(COEF_A)) | any(isnan(COEF_B)) | any(isnan(COEF_C)))
    STR = ['To use quadratic cost model, you must provide data for the cost coefficients:,'...
        'COEFF_A (?), COEFF_B (?/MWh) and COEFF_C (?/MW^2h).'];   % there are no data for quick dispatch method,
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');       % write a message
    return
end
if MIN_UP_DOWN_TIME_FLAG == 1 & (any(isnan(GMINUP)) | any(isnan(GMINDOWN)))
    STR = ['To use minimum up and down time constraints, you must provide data for GMINUP'...
        ' and GMINDOWN.'];
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');
    return
end
if RAMP_UP_DOWN_FLAG == 1 & (any(isnan(GRAMPUP)) | any(isnan(GRAMPDOWN)))
    STR = ['To use rump constraints, you must provide data for GRAMPUP '...
        'and GRAMPDOWN.'];
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');
    return
end
if COMPLETE_ENUMERATION_FLAG == 0 & (any(isnan(GNLC)) | any(isnan(GFC)) | any(isnan(GINC)))
    STR = ['To use priority list, you must provide data for NO LOAD COSTS,'...
        'FUEL COSTS and INCREMENTAL COSTS.'];
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');
    return
end
if START_UP_COST_METHOD == 2 & (any(isnan(GSH)) | any(isnan(GCSTIME)) )
    STR = ['To use cold/hot start up cost method, you must provide data for GSH '...
        'and GCSTIME.'];
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');
    return
elseif START_UP_COST_METHOD == 3 & (any(isnan(GSH)) | any(isnan(TAU)) )
    STR = ['To use exponential start up cost method, you must provide data for GSH '...
        'and TAU.'];
    msgbox(STR,'DATA AVAILABILITY CHECK FAILURE!','warn');
    return
end
%------------------------------------------------------------------------------------------------

% enabling / disabling some of the constraints
if MIN_UP_DOWN_TIME_FLAG == 0               % minimum up and down time enabled/disabled
    GMINUP(:)   = 1;                        % if disabled, all min up and down times
    GMINDOWN(:) = 1;                        % are set to 1
end
if RAMP_UP_DOWN_FLAG == 0                   % ramping constraints enabled/disabled
    GRAMPUP(:)   = Inf;                     % if disabled, ramp rates are
    GRAMPDOWN(:) = Inf;                     % set to a large number
end
if COMPLETE_ENUMERATION_FLAG == 0           % use either priority list or...
    [GMAXlst,GMINlst,LIST_STATES,GEN_ORDER] = priority_list(GNLC,GFC,GMAX,GMIN,GINC,NG);
else                                        % ...complete enumeration (consisting of all possible combinations)
    [GMAXlst,GMINlst,LIST_STATES,GEN_ORDER] = complete_enumeration(GNLC,GFC,GMAX,GMIN,GINC,NG);
end
if RESERVE_FLAG == 1
    if exist('RES_UP','var') ~= 1 | isempty(RES_UP) % if reserve-up vector is not defined or if it is empty
        RES_UP = K_RES_UP * DEMAND;                 % create reserve-up vector in proportion to demand
    end
    if exist('RES_DN','var') ~= 1 | isempty(RES_DN) % if reserve down vector is not defined or if it is empty
        RES_DN = K_RES_DN * DEMAND;                 % create reserve down vector in proportion to demand
    end
else
    RES_UP = zeros(size(DEMAND));                   % if reserve not required,
    RES_DN = zeros(size(DEMAND));                   % set it to zero.
end
if START_UP_COST_METHOD == 3                        % if start-up costs are exponential
    ALPHA = GSH;                                    % then define ALPHA
    BETA  = GSC;                                    % and BETA
else
    ALPHA = NaN*ones(NG,1);                         % otherwise, just define the names for variables
    BETA  = NaN*ones(NG,1);                         % since they will be passed to the functions
end
%------------------------------------------------------------------------------------------------

% Determines the initial status (ON/OFF = 1/0) for each generator, based on the input data (GSTATINI).
% (GSTATINI contains the number of hours that a generator was ON/OFF before the 1st time step)
% INI_STATE [NG x 1] - initial states of generators (1-commited, 0-not commited)
% INI_STATE_NUM      - position (column) of vector INI_STATE in the list of states
INI_STATE = (GSTATINI > 0);
[I, INI_STATE_NUM]= ismember(INI_STATE',LIST_STATES','rows')

%------------------------------------------------------------------------------------------------
% main loop of the program - search for optimal commitment by dynamic programming
%------------------------------------------------------------------------------------------------
% Here is the brief explanation of the algorithm:
% State is a unique combination of commited and non-commited generators.
% Commited generators are designated with "1" and non-commited generators are designated with "0".
%
% For each hour, program finds the potentially feasible states. Potentially feasible states are
% the states where demand (and reserve) can be supplied by the commited generators.
% If there are no potentially feasible states, program displays the error message and terminates.
%
% For each potentially feasible state, program takes all feasible states from the previous hour
% and checks if the transition to the current state (in current hour) is possible.
% If it is not possible, the corresponding transition (start-up) cost is set to Inf.
% However, if the transition is possible, calculated are the transition costs. Production for
% the current hour is calculated based on demand taking into account production at previous hour (ramp-up and
% down constraints). Finally, total cost is the sum of the transition cost, production cost, and
% the total cost at the state in previous hour. This procedure is repeated for all the states in
% previous hour. Total costs are then sorted and MN of them are saved (this is enhancement comparing
% to the classical dynamic program where only 1 previous state is saved). If the transition to
% a state in current hour is not possible from any of the states in previous hour, then current state is
% regarded as infeasible and is not considered anymore. If all the states in an hour are infeasible,
% program displays the error message and terminates.
%------------------------------------------------------------------------------------------------
for HOUR = 1:NT
    fprintf('Currently processing hour: %2d \n',HOUR)
    fprintf('DEMAND: %2d \n',DEMAND(HOUR))
    if HOUR == 1
        PREV_STATES_NUM = INI_STATE_NUM;             % Positions (columns) of feasible states in the list of states, for previous hour
        X_PREV  = GSTATINI;                         % number of hours generators are ON (>0) or OFF (<0).
        PRODUCTION_PREV = zeros(size(X_PREV));       % generator outputs
        TR_PREV = PREV_STATES_NUM;                  % transition path matrix
        FC_PREV = 0;                                % cumulative cost vector
    else
        X_PREV = X_CURR;                            % keep the number of gen. working hours for each state (at previous hour)
        PRODUCTION_PREV = PRODUCTION_CURR;          % and the gen. outputs for previous hour states
        TR_PREV = TR;                               % rows of matrix TR define the transition path
        FC_PREV = FC;                               % save the cumulative cost vector from the previous hour
        PREV_STATES_NUM = TR_PREV(1:COUNTER,end);   % states in the previous hour are given in the last column of TR
    end
%     pause
    % FEASIBLE_STATES_NUM = positions (columns) of potentially feasible states in the list of states, for current hour.
    [FEASIBLE_STATES_NUM,SUCCESS] = find_feasible_states(GMINlst,GMAXlst,DEMAND,HOUR,RES_UP,RES_DN);
    if SUCCESS == 0                                 % if unable to find any feasible state to match demand,
        return                                      % quit the program
    end
%     length(PREV_STATES_NUM)
%     N_PRED
    MN = min(length(PREV_STATES_NUM),N_PRED);                       % number of predecessors to be examined
%     pause
    X_CURR = zeros(NG,MN*length(FEASIBLE_STATES_NUM));             % prepare the number of gen. working hours for each state (at current hour)
    PRODUCTION_CURR = zeros(NG,MN*length(FEASIBLE_STATES_NUM));    % prepare generator outputs for each state at current hour
    TR = zeros(MN*length(FEASIBLE_STATES_NUM),HOUR+1);             % prepare transition path matrix
    FC = zeros(MN*length(FEASIBLE_STATES_NUM),1);                  % prepare cumulative cost vector
    COUNTER = 0;
    % take each feasible (current hour) state and...
    for J = 1: length(FEASIBLE_STATES_NUM)
        GEN_START_SHUT_COST = zeros(NG,1);                         % start up (shut down) costs
%         length(PREV_STATES_NUM)
        TOTAL_COST = zeros(1,length(PREV_STATES_NUM));             % total cost (production cost + start up cost + total cost of previous hour)
        % X_TEMP - temporarily stores number of gen. working hours for combination of current state and all previous hour states
        X_TEMP = zeros(NG,length(PREV_STATES_NUM));
        % PRODUCTION_TEMP - temporarily stores gen. outputs for combination of current state and all previous hour states
        PRODUCTION_TEMP = zeros(NG,length(PREV_STATES_NUM));
        % take a state (from all feasible states), one by one; let it be CURRENT_STATE
%         FEASIBLE_STATES_NUM(J)
        CURRENT_STATE  = LIST_STATES(:,FEASIBLE_STATES_NUM(J));
        %----------------------------------------------------------------------------------
        % ... compare it with each feasible state at previous hour
        for K = 1: length(PREV_STATES_NUM)
            
%             PRSN = PREV_STATES_NUM(K)
%             CRSN = FEASIBLE_STATES_NUM(J)
%             pause
            if HOUR == 1;
                PREVIOUS_STATE = INI_STATE;
            else
                PREVIOUS_STATE = LIST_STATES(:,PREV_STATES_NUM(K));
            end
            % check if the transition from previous state to the current state is possible regarding min up and down times
            [X,SUCCESS] = check_up_down_time(CURRENT_STATE,PREVIOUS_STATE,X_PREV(:,K),GMINUP,GMINDOWN,NG);
            if SUCCESS==0                                                   % if it is not possible,
                GEN_START_SHUT_COST(:,K) = Inf;                             % mark the transition cost and
                PROD_COST = ones(NG,1)*Inf;                                 % production cost as extremely high
                GEN_PRODUCTION = ones(NG,1)*NaN;
            else                                                            % othervise, calculate the transition cost
                STATE_DIFF = CURRENT_STATE - PREVIOUS_STATE;
                % STATE_DIFF = 1  means unit is commited
                % STATE_DIFF = -1 means unit is decommited
                if START_UP_COST_METHOD == 1   % start-up costs are constant and equal to cold start cost
                    GEN_START_SHUT_COST(:,K) = (STATE_DIFF > 0) .* GSC;
                elseif START_UP_COST_METHOD == 2
                    GEN_START_SHUT_COST(:,K) =                            ((STATE_DIFF > 0) & (-X_PREV(:,K) >= (GMINDOWN + GCSTIME))) .* GSC;  % cold start-up cost
                    GEN_START_SHUT_COST(:,K) = GEN_START_SHUT_COST(:,K) + ((STATE_DIFF > 0) & (-X_PREV(:,K) <  (GMINDOWN + GCSTIME))) .* GSH;  % hot start-up cost
                else
                    GEN_START_SHUT_COST(:,K) = (STATE_DIFF > 0) .* (ALPHA + BETA .* (1-exp(X_PREV(:,K) ./ TAU)));   % exponential start-up costs
                end
                GEN_START_SHUT_COST(:,K) = GEN_START_SHUT_COST(:,K) + (STATE_DIFF  < 0) .* GSDC;   % shut down cost

                % find the generation [MW] and production cost for each unit
                % Economic Dispatch
                [GEN_PRODUCTION,PROD_COST] = production(CURRENT_STATE,PREVIOUS_STATE,GMIN,GMAX,DEMAND,HOUR,GNLC,GFC,GINC,NG,GRAMPUP,GRAMPDOWN,PRODUCTION_PREV(:,K),GEN_ORDER,COEF_A,COEF_B,COEF_C,DISPATCH_METHOD);
            end
            X_TEMP(:,K) = X; % save the updated gen. work. times when moved from previous state to the current one
            PRODUCTION_TEMP(:,K) = GEN_PRODUCTION; % also save the updated gen. outputs
            if HOUR == 1
                TOTAL_COST(K) = sum(PROD_COST) + sum(GEN_START_SHUT_COST(:,K));
            else
                TOTAL_COST(K) = sum(PROD_COST) + sum(GEN_START_SHUT_COST(:,K)) + FC_PREV(K);
            end % if HOUR
        end  % K

        % among all transitions from each feasible state at previous hour
        % to the current state (at current hour), save up to MN with minimal total cost
%         TOTAL_COST
%         pause
        [MM,II] = sort(TOTAL_COST(TOTAL_COST ~= 0));       %% sort for ascending total cost
%         FC
%         TR_PREV
        
%         pause
        for K = 1:MN
            if MM(K) ~= Inf
                COUNTER = COUNTER +1;
                FC(COUNTER,1) = MM(K);
%                 size(TR_PREV,2)
%                 COUNTER
                TR(COUNTER,1:size(TR_PREV,2)) = TR_PREV(II(K),:);
                TR(COUNTER,end) = FEASIBLE_STATES_NUM(J);
                X_CURR(:,COUNTER) = X_TEMP(:,II(K));
                PRODUCTION_CURR(:,COUNTER) = PRODUCTION_TEMP(:,II(K));
%                 TR
%                 pause
            end % if MM(K)
        end % if K
%         PRODUCTION_CURR
    end   % J

    if COUNTER == 0;                                                                    % If the rest of the list is empty, then it means
        STR = ['NO FEASIBLE STATES FOR HOUR ',num2str(HOUR),'! PROGRAM TERMINATES!'];   % there are no feasible states,
        msgbox(STR,'NO FEASIBLE STATES','warn');                                        % and program terminates
        return
    end
end   % HOUR

%============================================
% END OF SEARCHING PROCEDURE
% ============================================
% The search is complete. Now program finds the best solution (least expensive state) at the last hour of the optimization horizon.
[M,I]=min(FC(1:COUNTER))
BEST_PATH = TR(I,:).';    % find the best transition path
% evaluate the solution and print the results
evaluate_solution(NT,BEST_PATH,LIST_STATES,GMIN,GMAX,DEMAND,GEN_ORDER,GNLC,GFC,GINC,GSC,INI_STATE,NG,...
    GRAMPUP,GRAMPDOWN,COEF_A,COEF_B,COEF_C,DISPATCH_METHOD,DETAIL_PRINT_FLAG,GSDC,GSTATINI,...
    GMINUP,GMINDOWN,START_UP_COST_METHOD,GCSTIME,GSH,ALPHA,BETA,TAU)
warning on
t=toc;
fprintf('\n Elapsed time: %15.4f sec.\n\n',t)
end
