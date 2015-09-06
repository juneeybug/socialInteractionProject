% GET_TS    get spike timestamps
%
% $Id: get_ts.m 779 2010-03-10 00:18:25Z joey $
%
% input:
%
% fname     - string identifying a mat file to load (from plx2mat)
% usortflag - flag indicates inclusion of unsorted units (defaults to false)
%
% output:
%
% spikes    - matrix of spikes [total number of spikes x 2] first col is time, second col is neuron identity
% names     - cell array of spike channel names (maps with identity)

function [spikes,names] = get_ts(fname,varargin)
global DATADIR
global mk   


    error(nargchk(1,2,nargin,'struct'));

    usortflag = 0;
    
    for i=2:nargin
      if (i==2)
        usortflag = varargin{i-1};
      end
    end
    try
    if(strmatch(mk,'mango'))
        ismango = true;
    else
        ismango = false;
    end        
    catch
        i
    end
%     ismango = false;
    % put timestamp data in a sensible format
    if(ismango)
      rgxp = '^(LHA|LHL|RHA|RHL|sig)\d?_?\d{3}[abcd]$';
      load(fname{1},'-regexp',rgxp);
      sigs = who('-regexp',rgxp);
    else       
              
%       rgxp = '^(L|R|sig)\d\(A|B|C)?_?d{3}';
      rgxp = '^(L|R|sig)\d\(A|B|C)?';
%       rgxp = '^(L|R)?';
      load(fname{1},'-regexp',rgxp);
%       clear *_wf *_fit *_thr *_tem *_wf_ts
      sigs = who('-regexp',rgxp);
      
      if length(sigs)< 2
          rgxp = '^(sig)\d?_?\d{3}[abcd]$';
          load(fname{1},'-regexp',rgxp);
          sigs = who('-regexp',rgxp);
      end
    end

    ts = []; ident = [];
    for i=1:size(sigs,1);
      ts      = [ ts ; eval(sigs{i}) ];
      ident   = [ ident ; i*ones(size(eval(sigs{i}))) ];
    end

    spikes = [ ts ident ];
    names = sigs;
