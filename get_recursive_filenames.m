% GET_RECURSIVE_FILENAMES   get filenames matching the filefilter
%                           in a directory and in all subdirectories
%
% $Id: get_recursive_filenames.m 841 2010-08-11 03:38:32Z joey $
%
% basedir   - base directory to search
% ffilter   - (optional) string or wildcard eg 'foo.mat' or '*.plx' or a regexp
% is_regexp - (optioinal) indicates if ffilter is a regexp (default: false)

function [paths] = get_recursive_filenames(basedir, varargin)

error(nargchk(1,3,nargin,'struct'));

ffilter = '';
is_regexp = 0;

for i=2:nargin
    if (i==2)
        ffilter = varargin{i-1};
    elseif (i==3)
        is_regexp = varargin{i-1};
    end
end

if strcmp(ffilter,'')
    if is_regexp
        ffilter = '.';
    else
        ffilter = '*';
    end
end

% start at the top
d = dir(basedir);

% make the ffilter regexp safe
if ~is_regexp
    tmp_filter = regexptranslate('wildcard',ffilter);
else
    tmp_filter = ffilter;
end

% match whole word that contains the pattern
tmp_filter = strcat('\S*',tmp_filter);

% apply regexp
f = regexp({d.name},tmp_filter,'match','once');

% remove empty cells
f = f(~cellfun(@isempty,f));

if ~isempty(f)
    f = f(:);
    % pad with basedir
    tmpdir = cellstr(repmat(basedir,length(f),1));
    f = cellfun(@fullfile,tmpdir,f,'UniformOutput',false);
else
    f = {};
end

% get all directories in basedir
dirs = {d([d.isdir]).name};
dirs = dirs(3:end)'; % excluding '.' and '..'

% recurse!
for j=1:length(dirs)
    f_tmp = get_recursive_filenames(fullfile(basedir,dirs{j}),ffilter,is_regexp);
    f = [f ; f_tmp];
end

paths = f;
