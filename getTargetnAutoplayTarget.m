
ntrials=size(trial,2);


for i=1:ntrials
    if ((trial(i).outcome == 104)||(trial(i).outcome == 105)||(trial(i).outcome == 106)||(trial(i).outcome == 107))
        
        % target location is logged at state = 103, so looking around that
        % time
        start = trial(i).states_t(trial(i).states == 103)-0.2;
        finish = trial(i).states_t(trial(i).states == 103)+0.2;
        
        try
        %% finding the target location
        tx = target_x(target_x(:,2) > start & target_x(:,2) < finish,1);
        ty = target_y(target_y(:,2) > start & target_y(:,2) < finish,1);
        trial(i).target = [tx ty];
        clear tx ty 
        
        %% finding the Autoplay target location for monkey 2 (autoplayTarget_x_2)
        tx = autoplayTarget_x_2(autoplayTarget_x_2(:,2) > start & autoplayTarget_x_2(:,2) < finish,1);
        ty = autoplayTarget_y_2(autoplayTarget_y_2(:,2) > start & autoplayTarget_y_2(:,2) < finish,1);
        trial(i).autoplayTarget = [tx ty];
        clear tx ty
        catch
            warning('inconsistencies in target/ autoplaytarget locations')
        end
    end
end

y=1;








