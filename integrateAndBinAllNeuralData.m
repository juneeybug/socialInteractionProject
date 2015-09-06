function integrateAndBinAllNeuralDataCherry10(sessiondate,varargin)

flag=0;

if nargin>1 
    flag=varargin{1};
end

global DATADIR 
global mk 

% DATADIR = 'C:\work\data\timingTask\';

day = sessiondate;
daystr = num2str(day);
% mk = 'cherry';
% mk = 'mangocherry';

numcomputers = 1;%HERE
binsize = 10; % ms

%% BEHAVIORAL FILE PARSE
% get id of all relevant behavior files
fo = getdaysfiles(day,mk,'*.out');
fe = getdaysfiles(day,mk,'*events');
fm = getdaysfiles(day,mk,[mk,'*mat']);
fp = getdaysfiles(day,mk,[mk,'*_parsed']);

% %parse behavior into mat file (if it doesn't already exist)
% if(isempty(fm))
%     bmi_parse(1,fo{1},fe{1});
% end

%parse behavior into trial by trial file (if doesn't exist)
% if(isempty(fp))
%     fm = getdaysfiles(day,mk,[mk,'*mat']);
%     parseDatafile(fm)
%     fp = getdaysfiles(day,mk,[mk,'*_parsed']);
% end


%% LOADING, SAVING NEURAL DATA
fbin = getdaysfiles(day,mk,'*binned10.mat'); 
ftim = getdaysfiles(day,mk,'*times10.mat');
% fbin=[];
if(isempty(fbin)|flag)
    fs{1} =  getdaysfiles(day,mk,'*superfaun*_spkwav.mat');
    fs{2} =  getdaysfiles(day,mk,'*liquidsword*_spkwav.mat');
    if(isempty(fs{2}))
        fs{2} =  getdaysfiles(day,mk,'*Liquidsword*_spkwav.mat'); %HERE
    end
    if(isempty(fs{2}))
        fs{2} =  getdaysfiles(day,mk,'*LiquidSword*_spkwav.mat');
    end
%     fs{3} =  getdaysfiles(day,mk,'*pinky*_spkwav.mat');
%     fs{4} =  getdaysfiles(day,mk,'*pipe*_spkwav.mat');
%     
    cell_ct = 0;
    spikes = [];
    names = [];
    
    for i=1:numcomputers
        [spktmp, namestmp] = get_ts_2monkeycherry(fs{i});
        spktmp2 = [spktmp(:,1) spktmp(:,2)+cell_ct];
        spikes = [spikes; spktmp2];
        names = [names; namestmp];
        cell_ct = cell_ct + length(namestmp); clear spktmp spktmp2 namestmp
    end

    [binned10, times10] = bin(spikes,binsize);
%     binned = nobin(spikes);
    savestr = strcat(DATADIR,'\',mk,'\',daystr(1:4),'\',daystr(5:6),'\',daystr,'\binned10.mat');
%     savestr = strcat(DATADIR,'\',mk,'\',daystr(1:4),'\',daystr(5:6),'\',daystr,'\binned10b.mat');
    save(savestr,'binned10','times10','names','-v7.3');
    
%     savestr = strcat(DATADIR,mk,'/',daystr(1:4),'/',daystr(5:6),'/',daystr,'/times10.mat');
%     save(savestr,'times10','-v7.3');
end

