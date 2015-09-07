global DATADIR
global mk

%% BEHAVIORAL FILE PARSE
day = sessiondate;
daystr = num2str(day);

% get id of all relevant behavior files
fo = getdaysfiles(day,mk,'*.out');
fe = getdaysfiles(day,mk,'*events');
fm = getdaysfiles(day,mk,[mk,'*behavior*','*mat']);
fp = getdaysfiles(day,mk,[mk,'*_parsed']);