function [X_CURR,SUCCESS] = check_up_down_time(CURRENT_STATE,PREVIOUS_STATE,X_PREV,GMINUP,GMINDOWN,NG)
%% --------------------------------------------------------------------------------------------------------------
% Checks wether the transition from previous state to the current state is feasible
% from the minimum up and down times point of view.
% OUTPUT:
% X_CURR [NG x 1]   - vector of working hours for the new state (NaN if transition is not possible)
% SUCCESS           - indicator: 1 - transition is possible; 0 - transition is not possible
%----------------------------------------------------------------------------------------------------------------
X_CURR = zeros(NG,1);
SUCCESS = 1;
% for the current state of generators, first check if any generator
% has been ON less than GMINUP or been OFF less than GMINDOWN
% all((X_PREV - GMINUP).*(PREVIOUS_STATE - CURRENT_STATE) >=0 & (-X_PREV - GMINDOWN).*(CURRENT_STATE - PREVIOUS_STATE) >=0)
if all((X_PREV - GMINUP).*(PREVIOUS_STATE - CURRENT_STATE) >=0 & (-X_PREV - GMINDOWN).*(CURRENT_STATE - PREVIOUS_STATE) >=0)
    for I=1:NG
        % current state is feasible regarding min up and down times; now calculate X_CURR - working times for each unit
        if (X_PREV(I) >= 1) & (CURRENT_STATE(I) == 1)                      % +1 hour on ON hours
            X_CURR(I) = X_PREV(I) + 1;
        elseif (X_PREV(I) <= -GMINDOWN(I)) & (CURRENT_STATE(I) == 1)       % transition from OFF to ON, +1 
            X_CURR(I) = 1;
        elseif (X_PREV(I) <= -1) & (CURRENT_STATE(I) == 0)                 % -1 hour on OFF hours
            X_CURR(I) = X_PREV(I) - 1;
        elseif (X_PREV(I) >= GMINUP(I)) & (CURRENT_STATE(I) == 0)          % transition from ON to OFF, -1 
            X_CURR(I) = -1;
        end
    end
else                                % current state violates min up and down times
    SUCCESS = 0;                    % set the indicator to zero (failed),
    X_CURR = ones(NG,1 )*NaN;       % also set the working times to NaNs
    return                          % and stop further working time calculation
end
end

