function varargout = compareBehavior(sessiondate,varargin)

plotFlag = 0;

getBehavioralFileIndicies;
day = sessiondate;
daystr = num2str(day);

load(fp{1});
load(fm{1},'trialType','assist_control');


avatarMonkeyBegantoPlay = assist_control(find(assist_control(:,1)==1,1,'last'),2);
firstTwomonkeyTrial = find([trial.start_t] < avatarMonkeyBegantoPlay,1,'last')

% initialize the arrays with NaNs
RT = ones(1,size(trial,2)).*nan;
MT = RT;
avgVel = RT;
outcome = RT;



for i=firstTwomonkeyTrial:size(trial,2)
       RT(i) = trial(i).RT;
       MT(i) = trial(i).MT;
       avgVel(i) = trial(i).avgVel;
       outcome(i) = trial(i).outcome;
end

numAutoplayPos = 4;
numTargetPos = 3;

for i=1:numAutoplayPos
    for j=1:numTargetPos
        RTbyType{i,j} = (RT(trialType{i,j}));
        MTbyType{i,j} = (MT(trialType{i,j}));
        RTplusMT{i,j} = (RT(trialType{i,j})+MT(trialType{i,j}));
        avgVelbyType{i,j} = (avgVel(trialType{i,j}));
        outcomebyType{i,j} = (outcome(trialType{i,j}));

    end
end


% classification
switch varargin{1}
    case 'RT'
        temp = RTbyType;
    case 'MT'
        temp = MTbyType;
    case 'RT+MT'
        temp = RTplusMT;
    case 'avgVel'
        temp = avgVelbyType;
    otherwise
        warning('no classification type supplied. So, outputting RT+MT by default.')
        temp = RTbyType+MTbyType;
end

varargout{1} = temp;
        

%% Plotting and testing within session
if plotFlag ==1
    
    % categorize into target locations
    same = [temp{2,1},temp{3,2},temp{4,3}];
    opp  = [temp{2,2},temp{2,3},temp{3,1},temp{3,3},temp{4,1},temp{4,2}];
    none = [temp{1,1},temp{1,2},temp{1,3}];
    
    % boxplot
    plotBoxplot(temp{1,1},temp{1,2},temp{1,3})
    hold on
    plotBoxplot(temp{2,1},temp{3,2},temp{4,3})
    plotBoxplot([temp{3,1} temp{4,1}],[temp{2,2},temp{4,2}],[temp{2,3},temp{3,3}])
    
end
y=1;

