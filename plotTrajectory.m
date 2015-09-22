function plotTrajectory(sessiondate)

getBehavioralFileIndicies;
day = sessiondate;
daystr = num2str(day);

load(fp{1});

plotBoundary = 12;
%%
for i=1:size(trial,2);   
    targetLocation = trial(i).target;
    outcome = trial(i).outcome;    
    joystickTime = trial(i).js(1,:);
    targetAppeared = trial(i).states_t(trial(i).states==103);
    targetReached = trial(i).monkey0State_t(trial(i).monkey0State==204)+0.5;
    
    begin = nearestpoint(targetAppeared,joystickTime);
    finish = nearestpoint(targetReached,joystickTime);
    if ~isempty(finish) % monkey reached the target
        plot(trial(i).js(2,begin:finish),trial(i).js(3,begin:finish),'k')
        axis([-plotBoundary plotBoundary -plotBoundary plotBoundary])
        text(0,-5,num2str(targetLocation))
        text(0,-7,num2str(outcome))
        pause;
        close all;
    else                % monkey did not attempt to reach the target
        continue;
    end
end

