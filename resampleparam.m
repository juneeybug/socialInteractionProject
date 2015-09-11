% resample a bmi param at a constant rate for convenience
%
% [y t] = resampleparam(x, f, [dont_interpolate]) 
%
% assumes the input param (x) is in seconds!
%
% x is [n x 2] - first col is value second col is time
% f is the frequency to sample at [hz].
% dont_interpolate tells the function not to interpolate 
% y is the param sampled at a constant rate
% t is the timeseries y is sampled at
%
% $Id: resampleparam.m 840 2010-08-11 03:36:15Z joey $

function [y,t] = resampleparam(x,f,dont_interpolate)

  if (~exist('dont_interpolate','var') || isempty(dont_interpolate))
    interpolate=1;
  else
    if dont_interpolate
      interpolate = 0;
    else
      interpolate = 1;
    end
  end

  t0 = x(1,2);
  t1 = x(end,2);
  v = linspace(0,1-1/f,f);
  i = nearestpoint(double(t0),floor(t0)+v,'next');
  if (isnan(i)), i = f; end
  j = nearestpoint(double(t1),floor(t1)+v,'previous');
  if (isnan(j)), j = 1; end
  t = floor(t0)+v(i) : 1/f : floor(t1)+v(j);
  y = double(resample_discont(x(:,1),x(:,2),t,interpolate));
  y = y(:);
  t = t(:);