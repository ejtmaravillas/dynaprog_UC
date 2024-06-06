function prints_states(NG,GMINcum,GMAXcum,LIST_STATES)
%% --------------------------------------------------------------------------------------------------------------
% Prints out the list of all possible states
% Note that priority list consists of NG states and the enumeration lists contains 2^NG states
% ---------------------------------------------------------------------------------------------------------------
fprintf('   State No.      MW min        MW max                     Units\n')
fprintf('%s',repmat(' ',1,23))
fprintf(['               ',repmat('    %5d ', 1, NG)],1:NG)
fprintf('\n %s \n',repmat('-',1,80'))
for I=1:size(LIST_STATES,2)
    fprintf('      %2d       %8.1f      %8.1f ',I,GMINcum(I),GMAXcum(I))
    fprintf([repmat('       %2d ', 1, size(LIST_STATES,1)) '\n'], LIST_STATES(:,I));
end
end