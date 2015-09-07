% for Autoplay/perturb of Monkey2

xmean = mean(perturb_4d_js_x_2(:,1));
ymean = mean(perturb_4d_js_y_2(:,1));

if(xmean>0 | ymean>0)
disp('Autoplay values are DC shifted!')
disp('Correcting..')
perturb_4d_js_x_2(:,1) = perturb_4d_js_x_2(:,1) - xmean;
perturb_4d_js_y_2(:,1) = perturb_4d_js_y_2(:,1) - ymean;
disp('..Done!')
end



i0jx = nearestpoint([trial.start_t],perturb_4d_js_x_2(:,2));
i1jx = nearestpoint([trial.end_t],perturb_4d_js_x_2(:,2));
i0jy = nearestpoint([trial.start_t],perturb_4d_js_y_2(:,2));
i1jy = nearestpoint([trial.end_t],perturb_4d_js_y_2(:,2));


ntrials = size(trial,2)
% now we have to loop :-(
for i=1:ntrials

  iijs = i0jx(i):i1jx(i);
  jjjs = i0jy(i):i1jy(i);
   
%   cd('/mnt/crackle/arjun/codes/');
  
  % js_trl
  try
    trial(i).perturb_4d_js2 = [perturb_4d_js_x_2(iijs,2) perturb_4d_js_x_2(iijs,1) perturb_4d_js_y_2(jjjs,1)]';
  catch
%      cd('resample_discont/');
     if (length(iijs) < length(jjjs))
      tmp = double(resample_discont(perturb_4d_js_y_2(jjjs,1), perturb_4d_js_y_2(jjjs,2), perturb_4d_js_x_2(iijs,2)));
      trial(i).perturb_4d_js2 = [perturb_4d_js_x_2(iijs,2) perturb_4d_js_x_2(iijs,1) tmp]';
    else
      tmp = double(resample_discont(perturb_4d_js_x_2(iijs,1), perturb_4d_js_x_2(iijs,2), perturb_4d_js_y_2(jjjs,2)));
      trial(i).perturb_4d_js2 = [perturb_4d_js_y_2(jjjs,2) tmp perturb_4d_js_y_2(jjjs,1)]';
    end
  end
  
  
  end

clear i0jx i1jx i0jy i1jy;
clear ii jj iijs jjjs
clear tmp;
