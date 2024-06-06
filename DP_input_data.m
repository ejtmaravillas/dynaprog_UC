%-----------------------------------------------------------------------
% Data from:
% A. J. Wood and B. F. Wollenberg: "Power Generation Operation and Control", 1984, John Wiley, New York
% obtained identical results to the reported ones.
%-----------------------------------------------------------------------
%                                                                                                                                                                                             cost coeff: a + b*PG + c*PG^2
% PARAMETERS setting
MIN_UP_DOWN_TIME_FLAG       = 1;        % take minimum up and down times into account (1) or not (0)
RAMP_UP_DOWN_FLAG           = 0;        % take ramp    up and down rates into account (1) or not (0)
N_PRED                      = 1;        % number of predecesors to be searched (N_PRED >= 1)
COMPLETE_ENUMERATION_FLAG   = 1;        % 1 - complete enumeration, 0 - priority list
DETAIL_PRINT_FLAG           = 1;        % detailed results printing: 0 - no, 1 - yes
DISPATCH_METHOD             = 3;        % 1 - quadprog, 2 - linprog, 3 - quick dispatch
RESERVE_FLAG                = 0;        % take spinning reserve in calculation (1) or not (0)
START_UP_COST_METHOD        = 2;        % 1-cold start-up (const), 2-cold/hot start-up, 3-exponential start-up                                                                                                                                                                                          -----------------------------------                                         
% Unit_no.    Pmin   Pmax  Inc.heat_rate  No_load_cost  Start_cost_cold  Fuel_cost  Min_up_time  Min_down_time In.status   Start_cost_hot     Cold_start_[h]    Ramp-up      Ramp-down      coef_a      coef_b        coef_c        shut_down_cost       TAU
%             [MW]   [MW]    [BTU/kWh]        [?/h]        [?]           [$/MBTU]      [h]           [h]          [h]         [?]                [h]            [MW/h]         [MW/h]        [?]        [?/MWh]      [?/MW^2h]           [?]             [h]
gen_data = [...                                                                                                                                                                                                                                           
      1        25     80      10440           213.00       350            2.00          4             2           -5          150                4                50             75          NaN         NaN           NaN               0               NaN 
      2        60    250       9000           585.62       400            2.00          5             3           +8          170                5                80            120          NaN         NaN           NaN               0               NaN 
      3        75    300       8730           684.74      1100            2.00          5             4           +8          500                5               100            150          NaN         NaN           NaN               0               NaN 
      4        20     60      11900           252.00      0.02            2.00          1             1           -6            0                0                80            120          NaN         NaN           NaN               0               NaN 
];                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                         
DEMAND = [450;530;600;540;400;280;290;500];
K_RES_UP = 0.00;    % if not specified, reserve up   is calculated as RES_UP(HOUR) = K_RES_UP*DEMAND(HOUR)
K_RES_DN = 0.00;    % if not specified, reserve down is calculated as RES_DN(HOUR) = K_RES_DN*DEMAND(HOUR)


% %-----------------------------------------------------------------------
% % Data from: 
% % A.Y.Abdelaziz, M.Z.Kamh, S.F.Mekhamer, M.A.L.Badr: "An Augmented Hopfield Neural Network for
% % Optimal Thermal Unit Commitment", International Journal of Power System Optimization, 
% % January-June 2010, Volume 2, No. 1, pp. 37-49
% % 
% % PARAMETERS setting:
% MIN_UP_DOWN_TIME_FLAG       = 1;        % take minimum up and down times into account (1) or not (0)
% RAMP_UP_DOWN_FLAG           = 0;        % take ramp    up and down rates into account (1) or not (0)
% N_PRED                      = 1;        % number of predecesors to be searched (N_PRED >= 1)
% COMPLETE_ENUMERATION_FLAG   = 1;        % 1 - complete enumeration, 0 - priority list
% DETAIL_PRINT_FLAG           = 0;        % detailed results printing: 0 - no, 1 - yes
% DISPATCH_METHOD             = 1;        % 1 - quadprog, 2 - linprog, 3 - quick dispatch
% RESERVE_FLAG                = 1;        % take spinning reserve in calculation (1) or not (0)
% START_UP_COST_METHOD        = 1;        % 1-cold start-up (const), 2-cold/hot start-up, 3-exponential start-up
% % reported solution: ?539353, my solution ?535273; there is a slight difference between reported commited units and my solution
% %
% % Unit_no.  Pmin   Pmax  Inc.heat_rate  No_load_cost  Start_cost_cold  Fuel_cost  Min_up_time  Min_down_time In.status   Start_cost_hot     Cold_start_[h]    Ramp-up      Ramp-down      coef_a      coef_b        coef_c      shut_down_cost    TAU
% %           [MW]   [MW]    [BTU/kWh]        [?/h]        [?]           [?/MBTU]      [h]           [h]          [h]         [?]                [h]            [MW/h]         [MW/h]        [?]        [?/MWh]      [?/MWh^2]         [?]          [h]
% %-----------------------------------------------------------------------
% % Unit_no.  Pmin   Pmax  Inc.heat_rate  No_load_cost  Start_cost_cold  Fuel_cost  Min_up_time  Min_down_time In.status   Start_cost_hot     Cold_start_[h]    Ramp-up      Ramp-down      coef_a      coef_b        coef_c       shut_down_cost      TAU
% %           [MW]   [MW]    [BTU/kWh]*       [?/h]*       [?]           [?/MBTU]*     [h]           [h]          [h]         [?]                [h]            [MW/h]         [MW/h]        [?]        [?/MWh]      [?/MWh^2]          [?]            [h]
% gen_data = [...                                                                                                                                                                                                                                       
%      1     300.0  1000.0       NaN            NaN              2050         NaN	        5           4          -10           NaN                NaN             NaN           NaN           820         9.023       0.00113             0            NaN 
%      2     130.0  400.0       NaN            NaN              1460         NaN	        3           2           10           NaN                NaN             NaN           NaN           400         7.654       0.00160             0            NaN 
%      3     165.0  600.0       NaN            NaN              2100         NaN	        2           4          -10           NaN                NaN             NaN           NaN           600         8.752       0.00147             0            NaN 
%      4     130.0  420.0       NaN            NaN              1480         NaN	        1           3          -10           NaN                NaN             NaN           NaN           420         8.431       0.00150             0            NaN 
%      5     225.0  700.0       NaN            NaN              2100         NaN	        4           5          -10           NaN                NaN             NaN           NaN           540         9.223       0.00234             0            NaN 
%      6      50.0  200.0       NaN            NaN              1360         NaN	        2           2           10           NaN                NaN             NaN           NaN           175         7.054       0.00515             0            NaN 
%      7     250.0  750.0       NaN            NaN              2300         NaN	        3           4          -10           NaN                NaN             NaN           NaN           600         9.121       0.00131             0            NaN 
%      8     110.0  375.0       NaN            NaN              1370         NaN	        1           3           10           NaN                NaN             NaN           NaN           400         7.762       0.00171             0            NaN 
%      9     275.0  850.0       NaN            NaN              2200         NaN	        4           3          -10           NaN                NaN             NaN           NaN           725         8.162       0.00128             0            NaN 
%      10     75.0  250.0       NaN            NaN              1180         NaN	        2           1           10           NaN                NaN             NaN           NaN           200         8.149       0.00452             0            NaN 
% ];
% DEMAND = [1025;1000;900;850;1025;1400;1970;2400;2850;3150;3300;3400;3275;2950;2700;2550;2725;3200;3300;2900;2125;1650;1300;1150];
% RES_UP = [85;85;65;55;85;110;165;190;210;230;250;275;240;210;200;195;200;220;250;210;170;130;100;90];
% RES_DN = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];

% %-----------------------------------------------------------------------
% % Data from: 
% % F.Benhamida, E.N.Abdallah and A.H.Rashed: "Thermal Unit Commitment Solution Using an Improved Lagrangian Relaxation"
% % International Conference on Renewable Energies and Power Quality (ICREPQ), Sevilla, Spain, 2007
% 
% % PARAMETERS setting
% MIN_UP_DOWN_TIME_FLAG       = 1;        % take minimum up and down times into account (1) or not (0)
% RAMP_UP_DOWN_FLAG           = 0;        % take ramp    up and down rates into account (1) or not (0)
% N_PRED                      = 1;        % number of predecesors to be searched (N_PRED >= 1)
% COMPLETE_ENUMERATION_FLAG   = 1;        % 1 - complete enumeration, 0 - priority list
% DETAIL_PRINT_FLAG           = 0;        % detailed results printing: 0 - no, 1 - yes
% DISPATCH_METHOD             = 1;        % 1 - quadprog, 2 - linprog, 3 - quick dispatch
% RESERVE_FLAG                = 1;        % take spinning reserve in calculation (1) or not (0)
% START_UP_COST_METHOD        = 2;        % 1-cold start-up (const), 2-cold/hot start-up, 3-exponential start-up
% 
% % reported solution: ?563938, my solution ?564916; the only difference between reported commited units and my solution is Unit 4 at hour 4
% % %-----------------------------------------------------------------------
% % % Unit_no.  Pmin   Pmax  Inc.heat_rate  No_load_cost  Start_cost_cold  Fuel_cost  Min_up_time  Min_down_time In.status   Start_cost_hot     Cold_start_[h]    Ramp-up      Ramp-down      coef_a      coef_b        coef_c      shut_down_cost    TAU
% % %           [MW]   [MW]    [BTU/kWh]        [?/h]        [?]           [?/MBTU]      [h]           [h]          [h]         [?]                [h]            [MW/h]         [MW/h]        [?]        [?/MWh]      [?/MWh^2]         [?]          [h]
% gen_data = ...                                                                                                                                                                                                                                       
% [     1     150    455         NaN             NaN        9000             NaN         8             8           +8          4500                 5              NaN            NaN         1000         16.19       0.00048            0           NaN 
%       2     150    455         NaN             NaN       10000             NaN         8             8           +8          5000                 5              NaN            NaN          970         17.26       0.00031            0           NaN 
%       3      20    130         NaN             NaN        1100             NaN         5             5           -5           550                 4              NaN            NaN          700         16.60       0.00200            0           NaN 
%       4      20    130         NaN             NaN        1120             NaN         5             5           -5           560                 4              NaN            NaN          680         16.50       0.00211            0           NaN 
%       5      25    162         NaN             NaN        1800             NaN         6             6           -6           900                 4              NaN            NaN          450         19.70       0.00398            0           NaN 
%       6      20     80         NaN             NaN         340             NaN         3             3           -3           170                 2              NaN            NaN          370         22.26       0.00712            0           NaN 
%       7      25     85         NaN             NaN         520             NaN         3             3           -3           260                 2              NaN            NaN          480         27.74       0.00079            0           NaN 
%       8      10     55         NaN             NaN          60             NaN         1             1           -1            30                 0              NaN            NaN          660         25.92       0.00413            0           NaN 
%       9      10     55         NaN             NaN          60             NaN         1             1           -1            30                 0              NaN            NaN          665         27.27       0.00222            0           NaN 
%      10      10     55         NaN             NaN          60             NaN	     1             1           -1            30                 0              NaN            NaN          670         27.79       0.00173            0           NaN 
% ];
% 
% DEMAND = [700;750;850;950;1000;1100;1150;1200;1300;1400;1450;1500;1400;1300;1200;1050;1000;1100;1200;1400;1300;1100;900;800];
% K_RES_UP = 0.10;    % if reserve is not explicitly given, reserve up is calculated as RES_UP(HOUR) = K_RES_UP*DEMAND(HOUR)
% K_RES_DN = 0.00;    % and reserve down is calculated as RES_DN(HOUR) = K_RES_DN*DEMAND(HOUR)
% -----------------------------------------------------------------------


% %-----------------------------------------------------------------------
% % Data from: 
% % V.S.Pappala,I.Erlich, "A New Approach for Solving the Unit Commitment Problem by Adaptive Particle Swarm Optimization",
% % Power and Energy Society general meeting-conversion and delivery of electrical energy in the 21st century, IEEE, USA (2008) p. 1?6.
% % reported solution: ?561586, my solution ?557150; there is difference between reported commited units and my solution
% % PARAMETERS
% MIN_UP_DOWN_TIME_FLAG       = 1;        % take minimum up and down times into account (1) or not (0)
% RAMP_UP_DOWN_FLAG           = 0;        % take ramp    up and down rates into account (1) or not (0)
% N_PRED                      = 1;        % number of predecesors to be searched (N_PRED >= 1)
% COMPLETE_ENUMERATION_FLAG   = 1;        % 1 - complete enumeration, 0 - priority list
% DETAIL_PRINT_FLAG           = 0;        % detailed results printing: 0 - no, 1 - yes
% DISPATCH_METHOD             = 1;        % 1 - quadprog, 2 - linprog, 3 - quick dispatch
% RESERVE_FLAG                = 1;        % take spinning reserve in calculation (1) or not (0)
% START_UP_COST_METHOD        = 3;        % 1-cold start-up (const), 2-cold/hot start-up, 3-exponential start-up
% 
% %-----------------------------------------------------------------------
% % % Unit_no.  Pmin   Pmax  Inc.heat_rate  No_load_cost  Start_cost_cold  Fuel_cost  Min_up_time  Min_down_time In.status   Start_cost_hot     Cold_start_[h]    Ramp-up      Ramp-down        coef_a      coef_b        coef_c      shut_down_cost      TAU
% % %           [MW]   [MW]      [BTU/kWh]        [?/h]     (=BETA)[?]     [?/MBTU]      [h]           [h]          [h]       (=ALPHA) [?]           [h]            [MW/h]         [MW/h]        [?]        [?/MWh]      [?/MWh^2]       [?]              [h]
% gen_data = ...                                                                                                                                                                                                                                
% [     1     150    455          NaN             NaN       4500            NaN         5             5           +8          4500                 NaN              NaN            NaN         1000         16.19       0.00048         0                4
%       2     150    455          NaN             NaN       5000            NaN         5             5           +8          5000                 NaN              NaN            NaN          970         17.26       0.00031         0                4
%       3      20    130          NaN             NaN        550            NaN         2             2           -5           550                 NaN              NaN            NaN          700         16.60       0.00200         0                2
%       4      20    130          NaN             NaN        560            NaN         2             2           -5           560                 NaN              NaN            NaN          680         16.50       0.00211         0                2
%       5      25    162          NaN             NaN        900            NaN         2             2           -6           900                 NaN              NaN            NaN          450         19.70       0.00398         0                2
%       6      20     80          NaN             NaN        170            NaN         2             2           -3           170                 NaN              NaN            NaN          370         22.26       0.00712         0                2
%       7      25     85          NaN             NaN        260            NaN         1             1           -3           260                 NaN              NaN            NaN          480         27.74       0.00079         0                2
%       8      10     55          NaN             NaN         30            NaN         0             0           -1            30                 NaN              NaN            NaN          660         25.92       0.00413         0                1
%       9      10     55          NaN             NaN         30            NaN	      0             0           -1            30                 NaN              NaN            NaN          665         27.27       0.00222         0                1
%      10      10     55          NaN             NaN         30            NaN	      0             0           -1            30                 NaN              NaN            NaN          670         27.79       0.00173         0                1
% ];
% 
% DEMAND = [700;750;850;950;1000;1100;1150;1200;1300;1400;1450;1500;1400;1300;1200;1050;1000;1100;1200;1400;1300;1100;900;800];
% K_RES_UP = 0.05;    % if not specified, reserve up   is calculated as RES_UP(HOUR) = K_RES_UP*DEMAND(HOUR)
% K_RES_DN = 0.00;    % if not specified, reserve down is calculated as RES_DN(HOUR) = K_RES_DN*DEMAND(HOUR)
% % -----------------------------------------------------------------------

