function getTrialtypes(sessiondate)

numAutoplayPos = 4;
numTargetPos = 3;

getBehavioralFileIndicies;

load(fp{1});

ntrials=size(trial,2);
targetpos = ones(ntrials,1).*nan;
autoplayTargetpos = ones(ntrials,1).*nan;

%% target location -- 3 possibilities
tpos = reshape([trial.target],2,ntrials);
temp = tpos(1,:).*tpos(2,:);

targetpos(temp < 0)  = 2;
targetpos(temp == 0) = 3;
targetpos(temp > 0)  = 4;

clear tpos temp


%% autoplay target location  -- 4 possibilities -- 3 target locations + does not move 
tpos = reshape([trial.autoplayTarget],2,ntrials);
temp = tpos(1,:).*tpos(2,:);

autoplayTargetpos(temp == 0 & tpos(2,:) == 0) = 1;
autoplayTargetpos(temp < 0)                   = 2;
autoplayTargetpos(temp == 0 & tpos(2,:) > 0)  = 3;
autoplayTargetpos(temp > 0)                   = 4;

clear tpos temp


%% designate trialType(a,t) -- a: autoplay target, t: monkey's target

for i=1:numAutoplayPos
    for j=1:numTargetPos
        trialType{i,j} = find(targetpos==j+1 & autoplayTargetpos==i);
    end
end


save(fm{1},'trialType','-append');

    
    
    
    
    
    
    
    

