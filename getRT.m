function varargout = getRT(sessiondate)

% change while testing code
plotflag=1;
saveflag=0;

getBehavioralFileIndicies;
day = sessiondate;
daystr = num2str(day);

load(fp{1});
load(fm{1},'js_x','js_y');


%% load and resample monkeys movements
SRATE=100; % resample at 100 Hz.
[x1_raw, tx1] =loadandresamp('js_x',fm{1},SRATE);
[y1_raw, ty1] =loadandresamp('js_y',fm{1},SRATE);
j_time = tx1; % joystick time

% standardize the movement positions.
x1_stan = (x1_raw - mean(x1_raw))./std(x1_raw);
y1_stan = (y1_raw - mean(y1_raw))./std(y1_raw);

% low pass filter before finding instantaneous velocity
% 2nd order Butterworth filter with 10Hz cut off frequence for joystick
% movement sample at 100Hz.
[b,a]=butter(2,10*2/100,'low');
x1=filtfilt(b,a,x1_stan);
y1=filtfilt(b,a,y1_stan);

% compute instantaneous velocities
vx1U = diff(x1)./diff(tx1);
vy1U = diff(y1)./diff(ty1);

% smoothen velocity data with a moving Gaussian kernel
vx1 = myGaussianFilter(20,20,vx1U);
vy1 = myGaussianFilter(20,20,vy1U);

%  GET GOOD TRIALS  = ALL trials
goodtrial = 1:size(trial,2);

RT = ones(size(trial,2),1).*nan;
MT = RT; avgVel = RT;
%% Loop into every trial to find movement beginning and end
i=1;ss=0;ee=0;
for j=1:length(goodtrial)
    
    outcome = trial(j).outcome;
    monkeyPerformed = (sum(trial(j).monkey0State==204) > 0);
    
    if monkeyPerformed
        
        tstates = trial(j).states;
        tstates_t = trial(j).states_t;
        
        monkeyStates = trial(j).monkey0State;
        monkeyStates_t = trial(j).monkey0State_t;
        
        %% Time from target onset to target reach
        ttrial(i) = tstates_t(find(tstates == 103,1,'first'));
        rtrial(i) = monkeyStates_t(find(monkeyStates == 204,1,'last'))+0.5;
        
        tt = nearestpoint(ttrial(i),j_time);
        tr = nearestpoint(rtrial(i),j_time);
        time=tt:tr;
        
        %% Gather absolute Positions, smoothened velocities, and raw velocities
        % positions
        xpos = x1(time);
        ypos = y1(time);
        pos = sqrt(xpos.^2+ypos.^2);
        dpos = pos-pos(1);
        
        % smoothened velocities
        Vx = vx1(time);
        Vy = vy1(time);
        timet = j_time(time);
        V = sqrt(Vx.^2+Vy.^2);
        dV = V-V(1);
        
        % raw velocities
        rVx = vx1U(time);
        rVy = vy1U(time);
        rV = sqrt(rVx.^2+rVy.^2);
        drV = rV-rV(1);
        
        
        %% Method: Identify the time when the maximum velocity was attained.
        % Then, scan around that timepoint to find the joystick movement onset and end.
        
        % find the time of peak velocity using the smoothened velocity
        % profile.
        maxposindex = find(dpos == max(dpos));
        
        pvIndex = find(dV== max(dV));
        if pvIndex > maxposindex
            pvIndex = find(dV== max(dV(1:maxposindex)));
        end
        peakVelTime = timet(pvIndex);
        
        
        % now search around peak velocity
        try
            sflag=0; eflag=0;
            till = 50; % search range = 50*100 = 500 ms. on each side of peak velocity
            
            % marking the beginning
            if pvIndex < 53 % taking care of 50-2
                till = pvIndex-3;
            end
            
            for k=1:till
                % conditions: 1. velocity should be 6 times lesser than peak
                % velocity 2. velocity at time=t should be lesser than two
                % previous velocity estimates.
                if dV(pvIndex-k) < max(dV)/6 & dV(pvIndex-k) < dV(pvIndex-k+1) & dV(pvIndex-k) < dV(pvIndex-k+2) & sflag==0
                    startIndex = pvIndex-k;
                    sflag=1;
                end
            end
            
            % marking the end
            till = 50;
            if length(dV) <  pvIndex+50 % taking care of 50-2
                till = length(dV) - pvIndex;
            end
            
            for k=1:till
                if dV(pvIndex+k) < max(dV)/6 & dV(pvIndex+k) < dV(pvIndex+k-1) & dV(pvIndex+k) < dV(pvIndex+k-2) & eflag==0
                    endIndex = pvIndex+k;
                    eflag=1;
                end
            end
            
            % Count the trials in which beginning and end were not found
            if sflag==0
                warning('beginning not found in trial %s',num2str(j));
                startIndex = pvIndex-k;                
                ss=ss+1;
                break;
            end
            
            if eflag==0
                warning('ending not found in trial %s',num2str(j));
                endIndex = pvIndex+k;                
                ee=ee+1;
            end
            
            % find the time corresponding to the beginning and end
            startVelTime = timet(startIndex);
            endVelTime = timet(endIndex);
            
            RT(j) = startVelTime - ttrial(i);
            MT(j) = endVelTime - startVelTime;
            avgVel(j) = mean(rV(startIndex:endIndex));
            
            if eflag==0 % end of the movement was not found correctly
                MT(j) = nan;
                avgVel(j) = nan;
            end            
                       
            if plotflag
                plot(timet,dV,'-k.')
                hold on
                plot(timet,dpos,'-r.')
                plot(timet,drV,'-b.')
                plot([startVelTime startVelTime],[-5 25],'b')
                plot([endVelTime endVelTime],[-5 25],'b')
                plot([peakVelTime peakVelTime],[-5 25],'r')
                text(endVelTime,15,num2str(j))
                close all
            end
            
            i=i+1;
        catch
            warning('onset and end of joystick movement not found in trial %s ',num2str(j));
        end
        
    end
    
end


varargout{1} = RT;
varargout{2} = MT;
varargout{3} = avgVel;

if saveflag
    for i=1:length(goodtrial)
        trial(i).RT = RT(i);
        trial(i).MT = MT(i);
        trial(i).avgVel = avgVel(i);
    end
    save(fp{1},'trial','-append');
end
y=1;



