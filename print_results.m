function print_results(BEST_PATH,LIST_STATES,INI_STATE,NT,NG,GMIN,GMAX,DEMAND,FCOST1,GENERATING_COST1,GENERATION,PROD_COST,START_COST,DETAIL_PRINT_FLAG)
if DETAIL_PRINT_FLAG == 0
    S = ['Hour         '
        'Demand       '
        'Tot.Gen      '
        'Min MW       '
        'Max MW       '
        'ST-UP Cost   '
        'Prod.Cost    '
        'F-Cost       '
        'State        '
        'Units ON/OFF '];
    fprintf('\n%s',repmat('=',1,150'))
    fprintf('\n       HOURLY RESULTS:')
    fprintf('\n%s \n',repmat('=',1,150'))
    fprintf([repmat('%12s ', 1, size(S,1))], S');
    fprintf('\n%s\n',repmat('-',1,150'))
else
    S = ['UNITS          '
        'ON/OFF         '
        'GENERATION     '
        'MIN MW         '
        'MAX MW         '
        'ST-UP Cost     '
        'PROD.COST      '];
end

if BEST_PATH(1) == 0
    LIST_STATES = [LIST_STATES,INI_STATE];
    BEST_PATH(1) = size(LIST_STATES,2);
end

for HOUR = 1:length(BEST_PATH)-1
    CURRENT_STATES_NUM  = BEST_PATH(HOUR+1);
    CURRENT_STATE   = LIST_STATES(:,CURRENT_STATES_NUM);

    MIN_MW = CURRENT_STATE.*GMIN;
    MAX_MW = CURRENT_STATE .*GMAX;
    if HOUR ==1 & DETAIL_PRINT_FLAG == 0
        fprintf('%3d  %12s  %12s %12.0f %12.0f %12.0f  %12.0f %12.0f %10.0f ',HOUR-1, '-','-',sum(LIST_STATES(:,BEST_PATH(HOUR)).*GMIN),sum(LIST_STATES(:,BEST_PATH(HOUR)).*GMAX),0,0,0,BEST_PATH(HOUR))
        fprintf(['       ',repmat('%2d', 1, size(LIST_STATES(:,BEST_PATH(HOUR)),1)),'\n'], LIST_STATES(:,BEST_PATH(HOUR)));
    end

    if DETAIL_PRINT_FLAG == 0;
        fprintf('%3d  %12.0f  %12.0f %12.0f %12.0f ',HOUR, DEMAND(HOUR), sum(GENERATION(:,HOUR)), sum(MIN_MW), sum(MAX_MW))
        fprintf('%12.0f  %12.0f %12.0f %10d ',sum(START_COST(:,HOUR)),sum(PROD_COST(:,HOUR)),FCOST1(HOUR),CURRENT_STATES_NUM)
        fprintf(['       ',repmat('%2d', 1, size(CURRENT_STATE,1)),'\n'], CURRENT_STATE);
    else
        TEMP = [(1:NG).',CURRENT_STATE,GENERATION(:,HOUR),MIN_MW,MAX_MW,START_COST(:,HOUR),PROD_COST(:,HOUR)];
        fprintf('\n\n\nHOUR: %2d             DEMAND:%7.1f MW           F-COST: %6.1f ?',HOUR,DEMAND(HOUR),FCOST1(HOUR))
        fprintf('\n%s \n',repmat('-',1,120'))
        fprintf([repmat('%15s ', 1, size(S,1)) '\n\n'], S');fprintf('\n');
        fprintf(['%3d %15d ',repmat('%15.1f', 1, size(TEMP,2)-2) '\n'], TEMP.');
        fprintf('%s \n',repmat('-',1,120'))
        fprintf('TOTAL: %12d  %14.1f %14.1f %14.1f %14.1f %14.1f\n',sum(CURRENT_STATE),sum(GENERATION(:,HOUR)), sum(MIN_MW), sum(MAX_MW),sum(START_COST(:,HOUR)),sum(PROD_COST(:,HOUR)))
    end
end
end
