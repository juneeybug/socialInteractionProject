
ntrials=size(trial,2);
target=ones(ntrials,3)*nan;
autoplayTarget=ones(ntrials,3)*nan;

for i=1:ntrials
    if ((trial(i).outcome == 104)||(trial(i).outcome == 105)||(trial(i).outcome == 106)||(trial(i).outcome == 107))
    start=trial(i).start_t;
    finish=trial(i).end_t;
    try
    target(i,1)=target_x(find((target_x(:,2)>start & target_x(:,2)<finish),1,'last'),2);
    target(i,2)=target_x(find((target_x(:,2)>start & target_x(:,2)<finish),1,'last'),1);
    ty=find((target_y(:,2)>start & target_y(:,2)<finish),1,'last');
    if isempty(ty)
        target(i,3)=0;
    else
        target(i,3)=target_y(find((target_y(:,2)>start & target_y(:,2)<finish),1,'last'),1);
    end
    
    autoplayTarget(i,1)=autoplayTarget_x_2(find((autoplayTarget_x_2(:,2)>start & autoplayTarget_x_2(:,2)<finish),1,'last'),2);
    autoplayTarget(i,2)=autoplayTarget_x_2(find((autoplayTarget_x_2(:,2)>start & autoplayTarget_x_2(:,2)<finish),1,'last'),1);
    
    aty = find((autoplayTarget_y_2(:,2)>start & autoplayTarget_y_2(:,2)<finish),1,'last');
    if isempty(aty)
        autoplayTarget(i,3)= 0;
    else
        autoplayTarget(i,3)=autoplayTarget_y_2(find((autoplayTarget_y_2(:,2)>start & autoplayTarget_y_2(:,2)<finish),1,'last'),1);  
    end
    
    catch
        i
    end
    else
        continue;
    end
end


for i=1:ntrials
    trial(i).target = target(i,:);
    trial(i).autoplayTarget=autoplayTarget(i,:);
end





% nonzeroxpos = find(target_x(:,1));
% nonzeroypos = find(target_y(:,1));
% 
% c=1;
% if size(trial,2) == length(nonzeroypos)
%     
%     for i=1:length(nonzeroypos)
%         time = target_y(nonzeroypos(i),2);
%         xtimepos = find(target_x(:,2)==time);
%         target(c,:)=[target_x(xtimepos,2) target_x(xtimepos,1) target_y(nonzeroypos(i),1)];
%         
%         auto_xtimepos=max(find(autoplayTarget_x_2(:,2)==time));
%         auto_ytimepos=max(find(autoplayTarget_y_2(:,2)==time));        
%         
%         autoplayTarget(c,:) = [autoplayTarget_x_2(auto_xtimepos,2) autoplayTarget_x_2(auto_xtimepos,1) autoplayTarget_y_2(auto_ytimepos,1)];
%         
%         c=c+1;
%     end
%     
% elseif size(trial,2) == length(nonzeroxpos)
%     for i=1:length(nonzeroxpos)
%         time = target_x(nonzeroxpos(i),2);
%         ytimepos = find(target_y(:,2)==time);
%         target(c,:)=[target_x(nonzeroxpos(i),2) target_x(nonzeroxpos(i),1) target_y(ytimepos,1)];
%         
%         auto_xtimepos=find(autoplayTarget_x_2(:,2)==time);
%         auto_ytimepos=find(autoplayTarget_y_2(:,2)==time);        
%         autoplayTarget(c,:) = [autoplayTarget_x_2(auto_xtimepos,2) autoplayTarget_x_2(auto_xtimepos,1) autoplayTarget_y_2(auto_ytimepos,1)];
%         c=c+1;
%     end
% 
% 
% else disp('mismatch in targetx and targety length as compared to trial!')
% end 






% target = [target_x(:,2) target_x(:,1) target_y(:,1)];
% autoplayTarget2 = [autoplayTarget_x_2(:,2) autoplayTarget_x_2(:,1) autoplayTarget_y_2(:,1)];
% aa = find(target(:,2)==0 & target(:,3)==0);
% target(aa,:)=[];
% 
% bb = find(autoplayTarget2(:,2)==0 & autoplayTarget2(:,3)==0);
% autoplayTarget2(bb,:)=[];
% 
% [B,i,j]=unique(autoplayTarget2(:,1));% target = [target_x(:,2) target_x(:,1) target_y(:,1)];
% autoplayTarget2 = [autoplayTarget_x_2(:,2) autoplayTarget_x_2(:,1) autoplayTarget_y_2(:,1)];
% aa = find(target(:,2)==0 & target(:,3)==0);
% target(aa,:)=[];
% 
% bb = find(autoplayTarget2(:,2)==0 & autoplayTarget2(:,3)==0);
% autoplayTarget2(bb,:)=[];
% 
% [B,i,j]=unique(autoplayTarget2(:,1));
% autoplayTarget=[B autoplayTarget2(i,2) autoplayTarget2(i,3)];
% 
% 
% % target(1295,:)=[];
% % autoplayTarget(1295,:)=[];
% 
% lt = length(target(:,1));new account
% lta = length(autoplayTarget(:,1));
% 
% 
% ntrials = size(trial,2);
% 
% if lt > ntrials 
%     difft = lt-ntrials;
% end
% target(end-difft+1)=[];
% 
% if lta > ntrials 
%     diffta = lta-ntrials;
% end
% autoplayTarget(end-difft+1)=[];

% autoplayTarget=[B autoplayTarget2(i,2) autoplayTarget2(i,3)];
% 
% 
% % target(1295,:)=[];
% % autoplayTarget(1295,:)=[];
% 
% lt = length(target(:,1));
% lta = length(autoplayTarget(:,1));
% 
% 
% ntrials = size(trial,2);
% 
% if lt > ntrials 
%     difft = lt-ntrials;
% end
% target(end-difft+1)=[];
% 
% if lta > ntrials 
%     diffta = lta-ntrials;
% end
% autoplayTarget(end-difft+1)=[];






















