function integrateAndBinAllNeuralData(sessiondate,varargin)
global DATADIR
global mk



%% override flag
flag=0;
if nargin>2
    flag=varargin{2};
end

%% bin-size
if nargin>1
    binsize = varargin{1};
else
    binsize = 50; %msec.
end



%% BEHAVIORAL FILE PARSE
day = sessiondate;
daystr = num2str(day);
% get id of all relevant behavior files
fo = getdaysfiles(day,mk,'*.out');
fe = getdaysfiles(day,mk,'*events');
fm = getdaysfiles(day,mk,[mk,'*mat']);
fp = getdaysfiles(day,mk,[mk,'*_parsed']);

%% LOADING, SAVING NEURAL DATA
fbin = getdaysfiles(day,mk,'*binned50.mat');
ftim = getdaysfiles(day,mk,'*times50.mat');
% fbin=[];
if(isempty(fbin)|flag)
    fs{1} =  getdaysfiles(day,mk,'*superfaun*_spkwav.mat');
    fs{2} =  getdaysfiles(day,mk,'*liquidsword*_spkwav.mat');
    if(isempty(fs{2}))
        fs{2} =  getdaysfiles(day,mk,'*Liquidsword*_spkwav.mat');
    end
    if(isempty(fs{2}))
        fs{2} =  getdaysfiles(day,mk,'*LiquidSword*_spkwav.mat');
    end
    fs{3} =  getdaysfiles(day,mk,'*pinky*_spkwav.mat');
    if(isempty(fs{3}))
        fs{3} =  getdaysfiles(day,mk,'*Pinky*_spkwav.mat');
    end
    
    
    % determining the number of plexon computers
    if ~isempty(fs{3})
        numcomputers = 3;
    elseif isempty(fs{3})
        numcomputers = 2;
    elseif isempty(fs{2})
        numcomputers = 1;
    else
        numcomputers = 0;
        warning('spkwav file may not have been picked up!')
    end
    
    
    
    cell_ct = 0;
    spikes = [];
    names = [];
    
    for i=1:numcomputers
        [spktmp, namestmp] = get_ts(fs{i});
        spktmp2 = [spktmp(:,1) spktmp(:,2)+cell_ct];
        spikes = [spikes; spktmp2];
        names = [names; namestmp];
        cell_ct = cell_ct + length(namestmp);
        clear spktmp spktmp2 namestmp
    end
    
    [binned, times] = bin(spikes,binsize);
    savestr = strcat(DATADIR,mk,'/',daystr(1:4),'/',daystr(5:6),'/',daystr,'/binned',num2str(binsize),'.mat');
    save(savestr,'binned','times','names','-v7.3');
    
end

