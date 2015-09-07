% BMI_PARSE     parse bmi event/strobe files
%
% $Id: bmi_parse.m 1021 2011-01-13 21:17:07Z joey $
%
% some strong magick is in here.
%
% function bmi_parse(force_parse,fname,plxmat,strobevar)
%
% force_parse - (bool) parse the outfile even it appears to have already been done
% fname       - the *.out (or out.gz) file to parse
% plxmat      - (HIGHLY recommended) a matfile converted plx file with strobes 
%               This is typically the *_events.mat file. Without this, the
%               time will not be synchronized between the Plexon data and the
%               parsed BMI3 output.
% strobevar   - (optional) string representing a particular strobe to parse

% XXXX
% THIS IS THE STANDARD BMI FILE PARSER
%   -- IT DOES NOT DO TASK LOGIC --
% XXXX

function bmi_parse(force_parse, fname, varargin)

if (nargin==0)
    help bmi_parse
    return
end
	error(nargchk(2,4,nargin,'struct'));

	MIN_STROBE = 0;
	MAX_STROBE = 15;

	for i=3:nargin,
		if (i==3)
			plxmat = varargin{i-2};
		end
		if (i==4)
			strobevar = varargin{i-2};
		end
	end
	clear vararign;

    [pathstr,filestr,ext] = fileparts(fname);
    if (exist(fname,'file') ~= 2)
        disp([filestr ext ' does not exist! ABORTING!']);
        return;
    end

    fn = fname;
    
    if (strcmp(ext,'.out') ~= 1)    % compressed file
        % check to see if matfile already exists
        [pstr,fstr,estr] = fileparts(fullfile(pathstr,filestr));

        [fn,status] = decompress_file(fn);
        if (status ~= 0)
            disp([' => bmi_parse: file decompression problem!']);
            return;
        end
    end
    
    % check to see if matfile already exists
    [pstr,fstr,estr] = fileparts(fn);
    if ( (exist(fullfile(pstr,[fstr '.mat']),'file') == 2) && ~force_parse )
        disp(' => bmi_parse: processed matfile exists! ABORTING!');
        return;
    end
    if ( (exist(fullfile(pstr,[fstr '.mat']),'file') == 2) && force_parse  )
        disp('Forced parse will overwrite existing file as requested.');
    end;
    
    disp(['Processing ' filestr]);

    flog = fopen([fn '.errors'],'wt');
    if(flog == -1)
        disp('Cannot write errors to file...probably permissions error or full disk, ABORTING!')
        return;
    end
    flogger = makeLogger(flog);
    flog_count = 0;
    
    if  ( exist('plxmat','var') && ~strcmp(plxmat,''))
        load(plxmat,'Strobed');   % load plexon strobes
        if ( ~exist('Strobed','var') )
            disp('****************************************');
            disp('No Strobed variable in plx file');
            disp('RESULTS WILL BE OUT OF SYNCH WITH PLEXON');
            disp('****************************************');
            beep;
        end         
    else 
        disp('****************************************');
        disp('No plx file specified');
        disp('RESULTS WILL BE OUT OF SYNCH WITH PLEXON');
        disp('****************************************');
        beep;
    end
    
    % read BMI OUT file. Format is:
    % 1. parameter name
    % 2. parameter write count
    % 3. global strobe count
    % 4. bmi time ("g_time")
    % 5. parameter value
    fid = fopen(fn);
	% we need some logic to switch between human h& joey style code.
	firstline = fgetl(fid); 
	if(regexp(firstline, '\)=\['))
		disp('This is matlab-encoded (e.g. from human surgeries)'); 
		delimiters = '(),=:[];'; 
		ismatenc = 1; 
	else
		disp('This is a tab delimited file (e.g from monkey experiments)'); 
		delimiters = '\t'; 
	end
	disp('Reading the .out file...'); 
	fseek(fid,0,-1); %% rewind the file.
    C = textscan(fid,'%s%u%u%f%s','delimiter',delimiters,'multipleDelimsAsOne', 1);
    fclose(fid);
    
    clear firstline fname pathstr filestr ext;
    clear pstr fstr estr status fid force_parse delimiters;
    % add more stuff here

    % get each individual variable
    strobes = char(C{1});
    strobe_count = C{3};
    g_time	= C{4};
    %values	= str2num(char(C{5}));
    values	= C{5};
    strobevars = unique(C{1});	% cell array
    if ( exist('ismatenc','var') )
        plexts = double(C{3}); %the plexon timestamps. (or rather, most recent ts)
    end
    
    clear C; % save memory
   


    if ( exist('Strobed','var') )

        diffd = diff(Strobed(2,:));

	% find repeated strobes (due to cosmic rayz?)
	if sum(diffd==0)
	    flog_count = flogger('Repeated strobe(s)...removing');
        beep;
	    Strobed(:,find(diffd==0)+1) = []; % omit 2nd instance by convention
	    diffd = diff(Strobed(2,:)); % calculate diff anew ;)
	end

	% make sure that no strobes were dropped.
	if (~isempty(find(diffd ~= MIN_STROBE-MAX_STROBE & diffd ~= 1 )))
	    if max(Strobed(2,:))>MAX_STROBE || min(Strobed(2,:))<MIN_STROBE
	        flog_count = flogger('Removing out of range strobes');
		tmp = Strobed(2,:) > MAX_STROBE | Strobed(2,:) < MIN_STROBE;
		Strobed(:,tmp) = [];
		clear tmp
	    else
		flog_count = flogger('Strobe Problems!');
        beep;
		Strobed_bak = Strobed;
		prob_strobes = find(diffd~=MIN_STROBE-MAX_STROBE & diffd~=1);	
		if length(prob_strobes) == 1 || min(diff(prob_strobes)) > 1
		    flog_count = flogger('Ok. At least the problems arent contiguous!');
		    for ixxx = 1:length(prob_strobes)
		        tmpstrobevec1 = [Strobed(1,prob_strobes(ixxx)) Strobed(1,prob_strobes(ixxx)+1)];
			tmpstrobevec2 = [Strobed(2,prob_strobes(ixxx)) Strobed(2,prob_strobes(ixxx)+1)];
			if diff(tmpstrobevec2) == 2 | diff(tmpstrobevec2) == MIN_STROBE-MAX_STROBE+1
		            flog_count = flogger('Ok. A single strobe was dropped. Interpolating.');
			    tmp_strobe{ixxx} = ...
		[ mean(tmpstrobevec1) ; mod(tmpstrobevec2(1)+1,MAX_STROBE+1) ];
			
			else
			    num_lost_strobes = mod(diff(tmpstrobevec2),MAX_STROBE+1)-1;
			    flog_count = ...
flogger(strcat('Ok. ',num2str(num_lost_strobes),' strobes in a row lost. Fixing and hoping for the best!'));
			    tmp_strobe{ixxx} = ...
[ linspace(tmpstrobevec1(1),tmpstrobevec1(2),num_lost_strobes+2) ; ...
  mod(linspace(tmpstrobevec2(1),tmpstrobevec2(1)+num_lost_strobes+1,num_lost_strobes+2),MAX_STROBE+1) ];
beep;
			end
		    end
		    for ixxx = 1:length(prob_strobes)
		        range_before_insert = 1:prob_strobes(ixxx)+ixxx-1;
			range_after_insert = prob_strobes(ixxx)+ixxx:size(Strobed,2);
			Strobed = [Strobed(:,range_before_insert) tmp_strobe{ixxx} Strobed(:,range_after_insert)];
		    end
	        else
		    flog_count = flogger('Ut ohs. Multiple strobes IN A ROW were affected! Aborting');
		    beep;
            return
		end
	    end
	end

	clear diffd;

        % unwrap and reconcile with plexon file
        % get sub-strobe accuracy
        asdf = strmatch('strobe_count',strobes,'exact');
        temptime = g_time(asdf);
        if (length(temptime) ~= length(Strobed))
            disp('wtf!');
	    if (length(temptime) < length(Strobed))
	        s = sprintf('out file has %d fewer strobes than plxmat file. truncating...', length(Strobed)-length(temptime));
            flog_count = flogger(s);
            Strobed = Strobed(:,1:length(temptime));
	    else
	    	flog_count = flogger('plxmat file has fewer strobes than outfile. was plexon file closed first by mistake? truncating...');
            beep;
            temptime = temptime(1:length(Strobed));
            asdf = asdf(1:length(Strobed));
            
	    end
        end

        g_temptime = ((g_time - temptime(1))/(temptime(end)-temptime(1))) * ...
                   (Strobed(1,end)-Strobed(1,1)) + Strobed(1,1); 
    
        temptime2 = g_temptime(asdf);
        difftimecrap = Strobed(1,:) - temptime2';

        diffmat = diff(asdf);
    
	bigdiffmat = zeros(1,  asdf(1)-1  +  sum(diffmat)  +  length(g_time)-asdf(end)+1  );
        bigdiffmat(1:asdf(1)-1) = difftimecrap(1);
	depth = asdf(1)-1;
        for i = 1:length(diffmat)
            changes=ones(1,diffmat(i))'.*((    ((g_temptime(depth+1:depth+diffmat(i))-g_temptime(depth+1)) / (g_temptime(depth+1+diffmat(i))-g_temptime(depth+1))) ...
			* (difftimecrap(i+1)-difftimecrap(i)))+difftimecrap(i));
            bigdiffmat(1,depth+1:depth+length(changes)) = changes';
            depth = depth + length(changes);
        end
        bigdiffmat(1,depth+1:end) = ones(1,length(g_time)-asdf(end)+1)*difftimecrap(end);
    
        g_temptime2 = g_temptime + bigdiffmat';
    
        g_time = g_temptime2;
    else
        disp('Converting msec -> seconds for consistency.');
        g_time = g_time .* 1e-3;
    end

    clear asdf bigdiffmat depth temptime temptime2 g_temptime g_temptime2;

    if (exist('strobevar','var'))
        strobevars = [];
        strobevars{1} = strobevar;
    end

    tic;
    disp('Working on the variables...');
    for i=1:length(strobevars)
        if (toc>2)
            fprintf('%d%%  ',floor(i*100/length(strobevars)));
            tic;
        end

	    if strcmp(strobevars{i},'#IND00')
            	continue;
	    end
		% fix b0rked variable names.
		outvars{i} = regexprep(strobevars{i}, '/', '_'); 
		outvars{i} = regexprep(outvars{i}, '-', '_');
		outvars{i} = regexprep(outvars{i}, ' ', '_'); 
		outvars{i} = regexprep(outvars{i}, '\.', ''); 
		worked = 1; 
		try 
			eval([outvars{i} '= [];']);	% empty array
		catch
			worked = 0; 
		end
		if worked
			
			foo = strmatch(strobevars{i},strobes,'exact');	% find eg 'state'
			%remove entries that don't index the strobes. 
			% this occurs when the BMI is closed via the task window and
			% the logger doesn't get a chance to flush. 
			oldsizefoo = size(foo, 1); 
			foo = foo(foo > 0); 
			foo = foo(foo <= length(values)); 
			foo = foo(foo <= length(g_time)); 
			if(size(foo, 1) ~= oldsizefoo)
                disp([' on variable: ', outvars{i}]); 
				flog_count = flogger('the number of variables and values do not match. was file closed correctly?');
                beep;
			end
			% special logiq to handle notes
			if (strcmp(strobevars{i},'note'))
				eval([outvars{i} '{1} = values(foo);']); % fill with values
				eval([outvars{i} '{2} = g_time(foo,:);']); % get timestamps
			elseif (strcmp(strobevars{i},'console'))
				eval([outvars{i} '{1} = values(foo);']); % fill with values
				eval([outvars{i} '{2} = g_time(foo,:);']); % get timestamps
			elseif (strcmp(strobevars{i},'Monkey_Profile_Name'))
                eval([outvars{i} '{1} = values(foo);']); % fill with values
                eval([outvars{i} '{2} = g_time(foo,:);']); % get timestamps
			else
				eval([outvars{i} '(:,1) = str2double(values(foo));']);
				eval([outvars{i} '(:,2) = g_time(foo,:);']); 
				if ( exist('ismatenc','var') )
					eval([outvars{i} '(:,3) = plexts(foo,:);']);
				end
			end
		else
			s = sprintf('skipping variable: %s', strobevars{i});
			flog_count = flogger(s);
		end
    end

    fclose(flog);
    if (flog_count == 0)
        system(['rm ' fn '.errors']);
    end
    clear flog flog_count;

    % XXXX

    [pathstr,filestr,ext] = fileparts(fn);
    disp('Saving...');
    clear ans ext foo i oldsizefoo worked values g_time strobe_count strobes flogger;

    if (exist('strobevar','var'))
        filestr = strcat(filestr,'_',strobevar);
    end

    % save parsed file
    save(fullfile(pathstr,filestr));

    [compfn,status] = compress_file(fn);

end

function f = makeLogger(fh)
	count = 0;
	function x = g(msg)
		count = count + 1;
		disp([' WARNING: ', msg]);
		fprintf(fh,'WARNING: %s\n', msg);
		x = count;
	end
	f = @g;
end

