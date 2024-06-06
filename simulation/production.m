function [GENERATION,PROD_COST] = production(CURRENT_STATE,PREVIOUS_STATE,GMIN,GMAX,DEMAND,HOUR,GNLC,GFC,GINC,NG,GRAMPUP,GRAMPDOWN,PRODUCTION_PREV,GEN_ORDER,COEF_A,COEF_B,COEF_C,DISPATCH_METHOD)
%% --------------------------------------------------------------------------------------------------------------
% For the given state, calculates the MW output for each commited generator
% so the total production costs are minimal.
% INPUT: DISPATCH_METHOD
% DISPATCH_METHOD = 3 - uses quick linear generator dispatch (one segment cost curve)
% DISPATCH_METHOD = 2 - same as previous, just using linprog from optimization toolbox
% DISPATCH_METHOD = 1 - generator dispatch using quadprog from optimization toolbox;
%                          in this case cost curve is quadratic: GEN_COST = A + B*PG + C*PG^2
%                          where A,B,C are the coefficents and PG is generator output.
% OUTPUT:
% GENERATION [NG x 1] - vector of power output for each generator
% PROD_COST  [NG x 1] - vector of generation cost for each generator
% ---------------------------------------------------------------------------------------------------------------
if DISPATCH_METHOD == 3                          % DISPATCH_METHOD = 3 means quick linear dispatch
    lb = zeros(size(GMIN));
    ub = zeros(size(GMAX));
    if HOUR ==1
        lb = GMIN .* CURRENT_STATE;                % lower bounds for generator output
        ub = GMAX .* CURRENT_STATE;                 % upper bounds for generator output
    else
        
        lb(CURRENT_STATE == 1) = max([GMIN(CURRENT_STATE == 1),PRODUCTION_PREV(CURRENT_STATE == 1)-GRAMPDOWN(CURRENT_STATE == 1)],[],2)...
            .* CURRENT_STATE(CURRENT_STATE == 1);                 % lower bounds for generator output

        ub(PREVIOUS_STATE == 0) = min([GMAX(PREVIOUS_STATE == 0),max([GRAMPUP(PREVIOUS_STATE == 0),GMIN(PREVIOUS_STATE == 0)],[],2)],[],2)...
            .* CURRENT_STATE(PREVIOUS_STATE == 0);
        ub(PREVIOUS_STATE == 1) = min([GMAX(PREVIOUS_STATE == 1),PRODUCTION_PREV(PREVIOUS_STATE == 1)+GRAMPUP(PREVIOUS_STATE == 1)],[],2)...
            .* CURRENT_STATE(PREVIOUS_STATE == 1);                 % upper bounds for generator output
    end

    if (sum(lb) > DEMAND(HOUR)) | (sum(ub) < DEMAND(HOUR)) | any((ub-lb) < 0)
        GENERATION = ones(NG,1)*NaN;
        PROD_COST = ones(NG,1)*Inf;
    else
        GENERATION = dispatch(CURRENT_STATE,lb,ub,DEMAND,HOUR,GEN_ORDER);
        PROD_COST =  GNLC .* CURRENT_STATE + GFC .* GINC .* GENERATION .* CURRENT_STATE / 1000; % and calculate their costs
    end
    return
else
    Aeq = double(CURRENT_STATE.');              % sum of output of commited generators
    beq = DEMAND(HOUR);                         % must match demand

    lb = zeros(size(GMIN));
    ub = zeros(size(GMAX));
    if HOUR ==1
        lb = GMIN .* CURRENT_STATE;                 % lower bounds for generator output
        ub = GMAX .* CURRENT_STATE;                 % upper bounds for generator output
    else
        lb(CURRENT_STATE == 1) = max([GMIN(CURRENT_STATE == 1),PRODUCTION_PREV(CURRENT_STATE == 1)-GRAMPDOWN(CURRENT_STATE == 1)],[],2)...
            .* CURRENT_STATE(CURRENT_STATE == 1);                 % upper bounds for generator output

        ub(PREVIOUS_STATE == 0) = min([GMAX(PREVIOUS_STATE == 0),max([GRAMPUP(PREVIOUS_STATE == 0),GMIN(PREVIOUS_STATE == 0)],[],2)],[],2)...
            .* CURRENT_STATE(PREVIOUS_STATE == 0);
        ub(PREVIOUS_STATE == 1) = min([GMAX(PREVIOUS_STATE == 1),PRODUCTION_PREV(PREVIOUS_STATE == 1)+GRAMPUP(PREVIOUS_STATE == 1)],[],2)...
            .* CURRENT_STATE(PREVIOUS_STATE == 1);                 % upper bounds for generator output
    end
    options = optimset('Display','Off');        % supress displays of linprog function
    if DISPATCH_METHOD == 2                      % economic dispatch using linprog
        f = GFC .* GINC .* CURRENT_STATE / 1000;    % vector of fuel cost for each generator
        [GENERATION,FVAL,EXITFLAG] = linprog(f,[],[],Aeq,beq,lb,ub,[],options);      % calculate the optimal production for each generator
        if EXITFLAG > 0
            PROD_COST =  GNLC .* CURRENT_STATE + GFC .* GINC .* GENERATION .* CURRENT_STATE / 1000; % and calculate their costs PRIORITY LIST FORMULA
        else
            GENERATION = ones(NG,1)*NaN;
            PROD_COST = ones(NG,1)*Inf;
        end
    end
    if DISPATCH_METHOD == 1                      % economic dispatch using quadrog
        %-------------------------------------------------------------------------
        % If quadprog is called with all set of generators, no matter if they are commited or not,
        % then the dimension of the quadratic programming problem is NG (NG decision variables), even
        % though some of generators can not generate (lb = ub = 0). This approach can lead quadprog to
        % infeasible solution (EXITFLAG = -2). With some experimenting, it is concluded that initial
        % guess is of crucial importance for this case. If X0 is determined by a quick dispatch function,
        % no infeasibility has reported.
        %-------------------------------------------------------------------------
        %         H = 2*diag(COEF_C .* CURRENT_STATE);
        %         f = COEF_B .* CURRENT_STATE;    % vector of fuel cost for each generator
        %         X0 = dispatch(CURRENT_STATE,GMIN,GMAX,DEMAND,HOUR,GEN_ORDER);                   % find approximate initial conditions
        %         [GENERATION,FVAL,EXITFLAG] = quadprog(H,f,[],[],Aeq,beq,lb,ub,X0,options);      % calculate the optimal production for each generator
        %         if EXITFLAG > 0
        %             PROD_COST =  COEF_A.*CURRENT_STATE + COEF_B.*GENERATION.*CURRENT_STATE + COEF_C.*GENERATION.^2.*CURRENT_STATE; % and calculate their costs
        %         else
        %             GENERATION = ones(NG,1)*NaN;
        %             PROD_COST = ones(NG,1)*Inf;
        %         end
        %-------------------------------------------------------------------------
        % However, in order to avoid call to a quick dispatch function and therefore to speed up
        % the program, only commited generators should be provided to quadprog. (where CURRENT_STATE=1)
        % In this case, the size of the problem reduces (size <= NG) and no infeasibility has encountered.
        GENERATION = zeros(NG,1);
        X0 = [];
        H = 2*diag(COEF_C(CURRENT_STATE));
        f = COEF_B(CURRENT_STATE);
        Aeq = Aeq(:,CURRENT_STATE);
        lb = lb(CURRENT_STATE);
        ub = ub(CURRENT_STATE);
        [GENERATION1,FVAL,EXITFLAG] = quadprog(H,f,[],[],Aeq,beq,lb,ub,X0,options);      % calculate the optimal production for each generator
        if EXITFLAG > 0
            GENERATION(CURRENT_STATE) = GENERATION1;
            PROD_COST =  (COEF_A.*CURRENT_STATE) + (COEF_B.*GENERATION.*CURRENT_STATE) + (COEF_C.*GENERATION.^2.*CURRENT_STATE); % and calculate their costs
        else
            GENERATION = ones(NG,1)*NaN;
            PROD_COST = ones(NG,1)*Inf;
        end
        %-------------------------------------------------------------------------
    end
end
end