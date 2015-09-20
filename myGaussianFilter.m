function varargout = myGaussianFilter(sigma,size,varargin)

data_unfiltered = varargin{1};

x = linspace(-size / 2, size / 2, size);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

% since this is a symmetric filter, convolution followed by 'same' prevents
% filter lag
data_filtered = conv (data_unfiltered, gaussFilter, 'same');

varargout{1} = data_filtered;