% this is a script
% load variables here

try
  [trial.hcbc_ctrl] = dealify([trial.outcome_t], hcbc_control, 'previous');
catch
  [trial.hcbc_ctrl] = deal(-1);
end

try
  [trial.hand_ctrl] = dealify([trial.outcome_t],hand_control,'previous');
catch
  try
    [trial.hand_ctrl] = dealify([trial.outcome_t],arm_hand_control,'previous');
  catch
    [trial.hand_ctrl] = deal(-1);
  end
end

try
  [trial.brain_ctrl] = dealify([trial.outcome_t],brain_control,'previous');
catch
  try
    [trial.brain_ctrl] = dealify([trial.outcome_t],position_control,'previous');
  catch
    [trial.brain_ctrl] = deal(-1);
  end
end

try
  [trial.autobutton] = dealify([trial.outcome_t],js_auto_button,'previous');
catch
  try
    [trial.autobutton] = dealify([trial.outcome_t],auto_button,'previous');
  catch
    [trial.autobutton] = deal(0);
  end
end

% transformation matrix;
try
  a00_trl = trialify([trial.outcome_t],trans_A_00,'previous');
  a01_trl = trialify([trial.outcome_t],trans_A_01,'previous');
  a10_trl = trialify([trial.outcome_t],trans_A_10,'previous');
  a11_trl = trialify([trial.outcome_t],trans_A_11,'previous');
catch
  try  
  load(f, '*gain*');
  if (exist('cursor_gain_x','var'))
    a00_trl = trialify([trial.outcome_t],cursor_gain_x,'previous');
    a01_trl = 0*a00_trl;
    a10_trl = 0*a00_trl;
    a11_trl = trialify([trial.outcome_t],cursor_gain_y,'previous');
  else
    warning('no trans_A_xx nor cursor_gain_x variables. assuming gain=1');
    a00_trl = ones(ntrials,1);
    a01_trl = zeros(ntrials,1);
    a10_trl = zeros(ntrials,1);
    a11_trl = ones(ntrials,1);
  end
  
  catch
    a00_trl = ones(ntrials,1);
    a01_trl = zeros(ntrials,1);
    a10_trl = zeros(ntrials,1);
    a11_trl = ones(ntrials,1);
  end
end

% for cursor
i0cx = nearestpoint([trial.start_t],cursor_x(:,2));
i1cx = nearestpoint([trial.end_t],cursor_x(:,2));
i0cy = nearestpoint([trial.start_t],cursor_y(:,2));
i1cy = nearestpoint([trial.end_t],cursor_y(:,2));

% for joystick
if (~exist('js_x','var'))
  js_x = js_x_lo;
  js_y = js_y_lo;
end
i0jx = nearestpoint([trial.start_t],js_x(:,2));
i1jx = nearestpoint([trial.end_t],js_x(:,2));
i0jy = nearestpoint([trial.start_t],js_y(:,2));
i1jy = nearestpoint([trial.end_t],js_y(:,2));

% now we have to loop :-(
ntrials=size(trial,2);
for i=1:ntrials

  ii = i0cx(i):i1cx(i);
  jj = i0cy(i):i1cy(i);
  iijs = i0jx(i):i1jx(i);
  jjjs = i0jy(i):i1jy(i);

  % handle weirdness
  if (isempty(ii))
    continue;
  end

  % cursor
  try
    trial(i).cursor = [cursor_x(ii,2) cursor_x(ii,1) cursor_y(jj,1)]';
  catch
    %cd('/mnt/crackle/arjun/codes/resample_discont/'); 
    if (length(ii) < length(jj))
      tmp = double(resample_discont(cursor_y(jj,1), cursor_y(jj,2), cursor_x(ii,2)));
      trial(i).cursor = [cursor_x(ii,2) cursor_x(ii,1) tmp]';
    else
      tmp = double(resample_discont(cursor_x(ii,1), cursor_x(ii,2), cursor_y(jj,2)));
      trial(i).cursor = [cursor_y(jj,2) tmp cursor_y(jj,1)]';
    end
  end
%cd('/mnt/crackle/arjun/codes/bmi_parsers/');
trial(i).states_cursor = nearestpoint(trial(i).states_t, trial(i).cursor(1,:));

  % js_trl
  try
    trial(i).js = [js_x(iijs,2) js_x(iijs,1) js_y(jjjs,1)]';
  catch
   % cd('/mnt/crackle/arjun/codes/resample_discont/');
    if (length(iijs) < length(jjjs))
      tmp = double(resample_discont(js_y(jjjs,1), js_y(jjjs,2), js_x(iijs,2)));
      trial(i).js = [js_x(iijs,2) js_x(iijs,1) tmp]';
    else
      tmp = double(resample_discont(js_x(iijs,1), js_x(iijs,2), js_y(jjjs,2)));
      trial(i).js = [js_y(jjjs,2) tmp js_y(jjjs,1)]';
    end
  end
  %cd('/mnt/crackle/arjun/codes/bmi_parsers/');
  trial(i).states_js = nearestpoint(trial(i).states_t, trial(i).js(1,:));

  % button
  % if button_state does not exist, assume that button is always touched
  try
    tmp = nearestpoint(trial(i).cursor(1,:),button_state(:,2),'previous');
    tmp(isnan(tmp)) = 1;        % I HATE NaNs
    trial(i).button = button_state(tmp,1);
  catch
    trial(i).button  = ones(length(trial(i).cursor(1,:)),1);
  end

  % transformation matrix
  trial(i).A = [a00_trl(i) a01_trl(i) ; a10_trl(i) a11_trl(i)];

  if ( trial(i).A(1,2) == 0 && trial(i).A(2,1) == 0) % just gain
    trial(i).gain_x = trial(i).A(1,1);
    trial(i).gain_y = trial(i).A(2,2);
    trial(i).rot_theta = 0;
  elseif ( det(trial(i).A) == 1 & min(min(inv(trial(i).A)==trial(i).A')) ) % just rotation
    trial(i).rot_theta = acos(a00_trl(i));
    trial(i). gain_x = 1;
    trial(i). gain_y = 1;
  else                          % more complicated
    trial(i).rot_theta = NaN;
    trial(i).gain_x = NaN;
    trial(i).gain_y = NaN;
  end

end

clear a00_trl a01_trl a10_trl a11_trl;
clear i0cx i1cx i0cy i1cy;
clear i0jx i1jx i0jy i1jy;
clear ii jj iijs jjjs
clear tmp;
