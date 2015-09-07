% $Id: getdaysfiles.m 801 2010-05-19 07:42:15Z joey $
%
% Input
% datepath - date in format yyyymmdd (integer, not string)
% monkey   - monkey's name, eg 'guava'
% ffilter  - (optional) string or wildcard eg '*.mat' or '*.plx' or '*' or a regexp
% isregexp - (optional) bool indicates if ffilter is a regexp expression

function f = getdaysfiles(datepath, monkey, varargin)

  error(nargchk(2,4,nargin,'struct'));

  global DATADIR;

  ffilter = '';
  isregexp = 0;

  for i=3:nargin;
    if (i==3)
      ffilter = varargin{i-2};
    elseif (i==4)
      isregexp = varargin{i-2};
    end
  end

  if (strcmp(ffilter,''));
    ffilter = '*';
  end

  strpath = num2str(datepath);
  year = strpath(1:4);
  mon = strpath(5:6);

  dirpath = fullfile(DATADIR,monkey,year,mon,strpath);
  f = get_recursive_filenames(dirpath,ffilter,isregexp);
