% BIN   put neural data into equally sized bins
%
% $Id: bin.m 718 2009-11-04 04:42:20Z joey $
% expects spikes to be Nx2 (as from GET_TS)
% where the second column is the index
% bin_size is in [msec]
% 
% binned is the binned data
% bins is a time-vector

function [binned,bins] = bin(spikes,bin_size)

	bin_size = bin_size/1000; 	% [sec]
	nneurs	 = max(spikes(:,2));
	tsmax	 = max(spikes(:,1));
	
	nbins = ceil(tsmax/bin_size);
	bins = 0:bin_size:(nbins-1)*(bin_size);
	binned = zeros(length(bins),nneurs);
	
	for i=1:nneurs
		ii = spikes(:,2) == i;
		binned(:,i) = histc(spikes(ii,1),bins);
	end
