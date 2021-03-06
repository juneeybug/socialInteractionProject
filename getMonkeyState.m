ntrials = size(trial,2);



ST_MONKEY_DEFAULT = 200;     %monkey is waiting for something to happen
ST_MONKEY_MOVE_CENTER = 201; %monkey is moving
ST_MONKEY_IN_CENTER= 202;    %monkey is in center
ST_MONKEY_MOVE_PERI= 203;    %monkey is moving
ST_MONKEY_IN_PERI= 204;      %monkey is in peripheral target
ST_MONKEY_IN_DIS= 205;       %monkey is in peripheral distractor
ST_MONKEY_REWARD= 206;       %monkey is rewarded
ST_MONKEY_WAIT= 207;         %monkey is waiting for other monkey to finish		



% Add monkey state to trial structure
for i=1:ntrials
    
   start = trial(i).states_t(trial(i).states == 101);
   finish = trial(i).states_t(trial(i).states == 108);
    
   trial(i).monkey0State = monkey_0_state((monkey_0_state(:,2)>start & monkey_0_state(:,2)<finish),1);
   trial(i).monkey0State_t = monkey_0_state((monkey_0_state(:,2)>start & monkey_0_state(:,2)<finish),2);
   
   trial(i).monkey1State = monkey_1_state((monkey_1_state(:,2)>start & monkey_1_state(:,2)<finish),1);
   trial(i).monkey1State_t = monkey_1_state((monkey_1_state(:,2)>start & monkey_1_state(:,2)<finish),2);
    
end  

% save(parsedFile,'trial', 'ST_MONKEY*','-append');