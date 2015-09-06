% COMMON_PARSE.M
% 
% this file contains basic "parsing logic" common
% to each of the bmi3 task behavior files.
%
% it is a script, not a function, so be very careful not to 
% stomp on existing variables
%
% $Id: common_parse.m 769 2010-03-04 03:16:00Z joey $

% file is loaded here

warning('OFF','MATLAB:load:variableNotFound');
warning('OFF','MATLAB:load:variablePatternNotFound');  

WORKSPACE_BOUNDS = [-25 25 ; -25 25];   % very generous workspace boundaries
MY_EPS = 1e-4; % a small number, but not thaaat small

if (~exist('cursor_x','var'))
  cursor_x = pos_x;
  cursor_y = pos_y;
end

% this can happen if the task is only in the x-axis (i.e. never update y)
if (~exist('cursor_y','var'))
  cursor_y = [0 0];
end

% isnt this bad?
if any(cursor_x(:,1) < WORKSPACE_BOUNDS(1,1))
    cursor_x(cursor_x(:,1) < WORKSPACE_BOUNDS(1,1),:) = [];
end
if any(cursor_x(:,1) > WORKSPACE_BOUNDS(1,2))
    cursor_x(cursor_x(:,1) > WORKSPACE_BOUNDS(1,2),:) = [];
end
if any(cursor_y(:,1) < WORKSPACE_BOUNDS(2,1))
    cursor_y(cursor_y(:,1) < WORKSPACE_BOUNDS(2,1),:) = [];
end
if any(cursor_y(:,1) > WORKSPACE_BOUNDS(2,2))
    cursor_y(cursor_y(:,1) > WORKSPACE_BOUNDS(2,2),:) = [];
end

if ~exist('ST_DEFAULT','var')
  if exist('ST_READY','var')
    ST_DEFAULT = ST_READY;
  else
    error('no ST_DEFAULT or ST_READY');
  end
end

if ~exist('ST_OVERRIDE','var')
  ST_OVERRIDE = -1;
end

% the first stab at trial start and end encodes
trial_start = find(state(:,1) == ST_DEFAULT);	
trial_end = find( (state(:,1) == ST_INTERTRIAL) );

% look for sequential juice override button presses
% Turn: 109 105 109 105 109 105 101
% Into: 109 109 109 105 101
tmp = find(state(:,1) == ST_OVERRIDE);
try
  % find an intertrial b/t two overrides
  tmp2 = state(tmp+1,1) == ST_INTERTRIAL & state(tmp+2,1) == ST_OVERRIDE;
catch
  % override at end of session
  tmp2 = state(tmp(1:end-1)+1,1) == ST_INTERTRIAL & state(tmp(1:end-1)+2,1) == ST_OVERRIDE;
end

if (any(tmp2))
  state((tmp(tmp2)+1),:) = [];	% clear excess intertrials
  trial_start = find(state(:,1) == ST_DEFAULT);	
  trial_end = find( (state(:,1) == ST_INTERTRIAL) );
end

% we also have to handle the case where a juice override is nestled
% between two intertrials through bad luck
% Turn: 105 109 105 101
% Into: 105 109 101
tmp = find(state(:,1) == ST_INTERTRIAL);
if (~isempty(tmp))
  % ignore if intertrial comes very close to the end
  if ( length(state) - tmp(end) <= 2 )
    tmp(end) = [];
  end
  % find an override b/t two intertrials
  tmp2 = state(tmp+1,1) == ST_OVERRIDE & state(tmp+2,1) == ST_INTERTRIAL;
  if (any(tmp2))
    % clear the second intertrial in each tripplet
    state((tmp(tmp2))+2,:) = [];
    trial_start = find(state(:,1) == ST_DEFAULT);	
    trial_end = find( (state(:,1) == ST_INTERTRIAL) );
  end
  clear tmp2;
end
clear tmp;

% ignore trial(s) that are started right before the task is ended
tmp = length(trial_start)-length(trial_end);
if (tmp>0)
    trial_start = trial_start(1:end-tmp); 
end
clear tmp;

ntrials = length(trial_start);

if (ntrials == 0)
  warning('common_parse:no_trials','No completed trials in session!'); 
  return
end

% preallocate trial structure
trial(ntrials) = struct( ...
    'outcome', [], ...
    'outcome_t', [], ...
    'start_t', [], ...      % ST_DEFAULT
    'end_t', [], ...        % ST_INTERTRIAL
    'len', [], ...
    'states', [], ...       % the states for this trial
    'states_t', [] ...      % time of these states
);

outcome = state(trial_end-1,1); % whatever comes before ST_INTERTRIAL
outcome_time = state(trial_end-1,2);  % time of outcome state
start_time = state(trial_start,2);  
end_time = state(trial_end,2);
trial_len = end_time - start_time;

% fill the trial structure
for i=1:ntrials
   trial(i).outcome = outcome(i);
   trial(i).outcome_t = outcome_time(i);
   trial(i).start_t = start_time(i);
   trial(i).end_t = end_time(i);
   trial(i).len = trial_len(i);
   trial(i).states = state(trial_start(i):trial_end(i),1);
   trial(i).states_t = state(trial_start(i):trial_end(i),2);
end

clear i;
clear outcome outcome_time start_time end_time trial_len;
