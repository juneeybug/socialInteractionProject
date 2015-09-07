function parseDatafile(f)

% DEFINE THE STROBES

ST_NULL = 100;      % task is not "running"
ST_DEFAULT= 101;    % default state.  both buttons are not pressed.
ST_MOVE_CENTER= 102;% monkeys are in the trial (one or more buttons pressed), move to center
ST_MOVE_PERI= 103;  % monkeys are moving towards peripheral targets
ST_MK1_WINS= 104;   % both monkeys finished the trial, Monkey 1 won
ST_MK2_WINS= 105;   % both monkeys finished the trial, Monkey 2 won
ST_MK1_ONLY= 106;   % only monkey 1 finished trial, monkey 2 timed out or buttoned out
ST_MK2_ONLY= 107;   % only monkey 2 finished trial, monkey 1 timed out or buttoned out
ST_INTERTRIAL= 108; % intertrial pause
ST_ERR= 109;        % error pause



load(f, 'state', 'cursor_x', 'cursor_y')

common_parse

[msgid,msgid] = lastwarn;
if (strcmp(msgid,'common_parse:no_trials'))
	lastwarn('','');
	return;
end

load(f,	'js*', ...
	'*target_*', ...
	'cursor_*', ...
    'trans_A_*', ...
	'use_*', ...
	'*_time', '*_timeout','autoplayTarget_*','perturb_4d_js_*','monkey_0_state','monkey_1_state')


basicTask_parse;


% to add target and autoplay target positions in trial structure
getTargetnAutoplayTarget; 

% to add avatar arm movement data into trial structure
getPerturbdata;


% adding monkey1 and monkey1 states into trial structure
getMonkeyState;


parsedfilename = strcat(f(1:length(f) - 4), '_parsed.mat');

save(parsedfilename,'trial', 'ST_*');

