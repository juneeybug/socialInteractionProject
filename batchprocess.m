%% MONKEY NAME AND DATA PATH
global mk 
mk = 'mango';

global DATADIR
DATADIR ='E:\work\data\socialInteractionProject\';


%% EXPERIMENTAL SESSIONS
% MANGO - Monkey M
% one session AND 3 targets 
% NOTE: In april, Omitdup was not set to 0 in BMI. Therefore, target_x is
% not equal to target_y
% sessions = [20130409,20130416,20130502,20130507];
% juice ratios (in the order of sessions) = [600/150, 600/100, 600/100, 600/100]

% two sessions with different reward ratios AND 3 targets 
% sessions = [20130508,20131010]; % 600/300, 300/100, 300/100 % session on
% 20130509 has some missing strobes!!
% sessions = [201305081,201305091,201305101]; % 700/100, 600/100, 600/100


% two sessions with different levels of competition AND 4 targets (instead of 3)
sessions = [20131011,20131014,20131015]; %500/200, 500/200, 500/200


% OPHELIA - Monkey O (watch out for alignment issues!)
% one session AND 3 targets 
% sessions = [20130304,20130306,20130308,20130318,20130325];

% sessions = [20130409,20130416,20130502,20130507];
 
% sessions = [20130409,20130416,20130502,20130507,20130508,201305081,201305091,20130510,201305101];
% sessions = [20130508,20130510,201305081,201305091,201305101];
sessions = [20130502];

RT = cell(4,3);
RT2 = RT;
outcome = cell(4,3);
outcome2 = outcome;
%% Sessionwise analysis 

for i=1:length(sessions)
sessiondate = sessions(i);
  

%% convert plx2mat
% cd('E:\work\plx2mat');
% convertPlx2Mat(sessiondate);
% cd('E:\work\data\socialInteractionProject\');



%% preprocessing
% preProcess(sessiondate);
% % % 
% getTrialtypes(sessiondate)
% getTrialtypes4(sessiondate)
% % % 
% % % % %% integrate and bin neural data
% integrateAndBinAllNeuralData(sessiondate,50,1); % 50 msec bins 
% integrateAndBinAllNeuralData(sessiondate,10,1); % 10 msec bins

 
%% behavioral assessments
% 1) obtain and save RT, MT and average velocity
% getRT(sessiondate)

% 2) Get RT or MT or RT+MT or avgVel, sorted by trialtype and merge the
% cells across sessions.
% [temp_RT,temp_outcome] = compareBehavior(sessiondate,'RT+MT');
% RT = cellfun(@(x,y) [x,y],RT,temp_RT,'un',0);
% outcome = cellfun(@(x,y) [x,y],outcome,temp_outcome,'un',0);
% temp_RT =[];temp_outcome=[];
% % 
% if i>2
%     [temp_RT,temp_outcome] = compareBehavior(sessiondate,'RT+MT');
%     RT2 = cellfun(@(x,y) [x,y],RT2,temp_RT,'un',0);
%     outcome2 = cellfun(@(x,y) [x,y],outcome2,temp_outcome,'un',0);
%     temp_RT =[];temp_outcome=[];
% end

% 3) plot trajectory
plotTrajectory(sessiondate)




end
y=1;

%% Multiple session analysis scripts
% compareBehaviorAcrossSessions

compareBetweenSamedaySessions.m







y=1;