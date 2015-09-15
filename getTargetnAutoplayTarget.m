
ntrials=size(trial,2);


for i=1:ntrials
    tstates = find(trial(i).states ==103);
    
    % if ((trial(i).outcome == 104)||(trial(i).outcome == 105)||(trial(i).outcome == 106)||(trial(i).outcome == 107))
     if ~isempty(tstates)   
        % target location is logged at state = 103, so looking around that
        % time
        start = trial(i).states_t(trial(i).states == 103)-0.2;
        finish = trial(i).states_t(trial(i).states == 103)+0.2;
        
        try
        %% finding the target location
        tx = target_x(target_x(:,2) > start & target_x(:,2) < finish,1);
        ty = target_y(target_y(:,2) > start & target_y(:,2) < finish,1);
        
        % in sessions before May '13, omitdup was ON, target position was logged only if it changed
        % So, if no entry found for the current trial at state 103, the last set value is picked. 
        if length(tx) < 1 
            tx = target_x(find(target_x(:,2) < finish,1,'last')); 
        end
        
        if length(ty) < 1 
            ty = target_y(find(target_y(:,2) < finish,1,'last')); 
        end
        
        % weed out some spurious transitions in Target positions
        if length(tx) > 1 
            tx = tx(end);
        end
        if length(ty) > 1 
            ty = ty(end);
        end
        
        trial(i).target = [tx ty];
        clear tx ty 
        
        %% finding the Autoplay target location for monkey 2 (autoplayTarget_x_2)
        tx = autoplayTarget_x_2(autoplayTarget_x_2(:,2) > start & autoplayTarget_x_2(:,2) < finish,1);
        ty = autoplayTarget_y_2(autoplayTarget_y_2(:,2) > start & autoplayTarget_y_2(:,2) < finish,1);
        
        % handling omitdup = 1 as previously mentioned.
        if length(tx) < 1 
            tx = autoplayTarget_x_2(find(autoplayTarget_x_2(:,2) < finish,1,'last')); 
        end
        
        if length(ty) < 1 
            ty = autoplayTarget_y_2(find(autoplayTarget_y_2(:,2) < finish,1,'last')); 
        end
        
               
        % weed out some spurious transitions in autoplayTarget positions
        if length(tx) > 1 
            tx = tx(end);
        end
        if length(ty) > 1 
            ty = ty(end);
        end
            
        trial(i).autoplayTarget = [tx ty];
        clear tx ty
        catch
            warning('inconsistencies in target/ autoplaytarget locations')
        end
     else
        trial(i).target = [nan nan];
        trial(i).autoplayTarget = [nan nan]; 
end

y=1;








