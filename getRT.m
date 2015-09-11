function varargout = getRT(sessiondate)

getBehavioralFileIndicies;

day = sessiondate;
daystr = num2str(day);



load(fp{1});
load(fm{1},'js_x','js_y');



%% load and resample self movements
SRATE=100;
[x1_raw, tx1] =loadandresamp('js_x',fm{1},SRATE);
[y1_raw, ty1] =loadandresamp('js_y',fm{1},SRATE);
times10 = tx1;

x1 = (x1_raw - mean(x1_raw))./std(x1_raw);
y1 = (y1_raw - mean(y1_raw))./std(y1_raw);

vx1U = diff(x1)./diff(tx1);
vy1U = diff(y1)./diff(ty1);

h = fspecial('gaussian', [20 1], 20);
vx1 = imfilter(vx1U,h,'same');
vy1 = imfilter(vy1U,h,'same');


%%  GET GOOD TRIALS  = ALL trials
goodtrial = 1:size(trial,2);

i=1;ss=0;ee=0;
for j=1:length(goodtrial)  
    
    outcome = trial(j).outcome;
    monkeyPerformed = (sum(trial(j).monkey0State==204) > 0);
    
    if monkeyPerformed
        
        tstates = trial(j).states;
        tstates_t = trial(j).states_t;
        
        monkeyStates = trial(j).monkey0State;
        monkeyStates_t = trial(j).monkey0State_t;
        
        ttrial(i) = tstates_t(find(tstates == 103,1,'first'));
        rtrial(i) = monkeyStates_t(find(monkeyStates == 204,1,'last'))+0.5;        
        
        tt = nearestpoint(ttrial(i),times10);
        tr = nearestpoint(rtrial(i),times10);
        
        time=tt:tr;
        
        xpos = x1(time);
        ypos = y1(time);
        dpos = sqrt(xpos.^2+ypos.^2);
        ddpos = dpos-dpos(1);
        
        xt = vx1(time);
        yt = vy1(time);
        timet = tx1(time);
        dt = sqrt(xt.^2+yt.^2);
        ddt = dt-dt(1);
        
        
        % raw velocities
        xtU = vx1U(time);
        ytU = vy1U(time);
        timet = tx1(time);
        dtU = sqrt(xtU.^2+ytU.^2);
        ddtU = dtU-dtU(1);
        
        %     plot(timet,ddt,'-k.')
        %     hold on
        %     plot(timet,ddpos,'-r.')
        
        maxposindex = find(ddpos == max(ddpos));
        pvIndex = find(ddt== max(ddt));
        if pvIndex > maxposindex
            pvIndex = find(ddt== max(ddt(1:maxposindex)));
        end              
        peakVelTime = timet(pvIndex);
        %     plot([peakVelTime peakVelTime],[-5 25],'r')
        
        
        try
            sflag=0; eflag=0;
            % search around peak velocity
            till = 50;
            % marking the beginning
            if pvIndex < 53 % taking care of 50-2 
                till = pvIndex-3;
            end
            
            for k=1:till
                
                if ddt(pvIndex-k) < max(ddt)/6 & ddt(pvIndex-k) < ddt(pvIndex-k+1) & ddt(pvIndex-k) < ddt(pvIndex-k+2) & sflag==0
                    startIndex = pvIndex-k;
                    sflag=1;
                end
            end
                
          % marking the end
          till = 50;
            if length(ddt) <  pvIndex+50 % taking care of 50-2 
                till = length(ddt) - pvIndex;
            end    
                
           for k=1:till        
                if ddt(pvIndex+k) < max(ddt)/6 & ddt(pvIndex+k) < ddt(pvIndex+k-1) & ddt(pvIndex+k) < ddt(pvIndex+k-2) & eflag==0
                    endIndex = pvIndex+k;
                    eflag=1;
                end
            end
            
            if sflag==0
                startIndex = pvIndex-k;
                ss=ss+1;
            end
            
            if eflag==0
                endIndex = pvIndex+k;
                ee=ee+1;
                
            end
            
            
            startVelTime = timet(startIndex);
            %     plot([startVelTime startVelTime],[-5 25],'b')
            
            endVelTime = timet(endIndex);
            plot([endVelTime endVelTime],[-5 25],'b')
            
            
            RT(i) = startVelTime - ttrial(i);
            MT(i) = endVelTime - startVelTime;
            plot(timet,ddt,'-k.')
            hold on
            plot(timet,ddpos,'-r.')
            plot(timet,ddtU,'-b.')
            plot([startVelTime startVelTime],[-5 25],'b')
            plot([endVelTime endVelTime],[-5 25],'b')
            plot([peakVelTime peakVelTime],[-5 25],'r')
            text(endVelTime,15,num2str(j))
            

            i=i+1;
        catch
            y=1;
        end
        
        close all
        clear ddt dt xpos ypos xt yt timet
        
        
    end
    
end


varargout{1} = RT;


y=1;