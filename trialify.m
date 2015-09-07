% $Id$
%
% this is a convenience function
% 
% trialts - [nx1] vector of timestamps to use as trial markers
% eventts - [mx2] timestamps to associate with a trial
% mode	  - (optional) either 'nearest' [default], 'previous' or 'next'
% trials  - output, [nx1] the state of the event, per trial

function trials = trialify(trialts,eventts,varargin)

  if (~isempty(varargin))
    mode = varargin{1};
  else
    mode = 'nearest';
  end

  % this bullshit is to handle the case of nans properly
  tmp = nearestpoint(trialts,eventts(:,2),mode);
  notnan = ~isnan(tmp);
  if (sum(isnan(tmp)) > 0)
    trials(notnan) = eventts(tmp(notnan),1);
    trials(~notnan) = NaN;
  else
    trials = eventts(tmp,1);
  end

  trials = trials(:);
