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

% two sessions with different levels of competition AND 3 targets 
% sessions = [20130508,20131009,20131010];

% two sessions with different levels of competition AND 4 targets (instead of 3)
% sessions = [20131011,20131014,20131015];


% OPHELIA - Monkey O (watch out for alignment issues!)
% one session AND 3 targets 
% sessions = [20130304,20130306,20130308,20130318,20130325];

sessions = [20130507];
%% Sessionwise analysis 

for i=1:length(sessions)
sessiondate = sessions(i);
  

%% convert plx2mat
% cd('E:\work\plx2mat');
% convertPlx2Mat(sessiondate);
% cd('E:\work\data\socialInteractionProject\');



%% preprocessing
% preProcess(sessiondate);

% getTrialtypes(sessiondate)
% 
% %% integrate and bin neural data
% integrateAndBinAllNeuralData(sessiondate,50,1); % 50 msec bins 
% integrateAndBinAllNeuralData(sessiondate,10,1); % 10 msec bins

 
%% behavioral assessments 
RT(i) = getRT(sessiondate)


end



y=1;