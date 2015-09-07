function preProcess(sessiondate)


getBehavioralFileIndicies;
day = sessiondate;
daystr = num2str(day);

%parse behavior into mat file (if it doesn't already exist)
if(isempty(fm))
    bmi_parse(1,fo{1},fe{1});
end

if(isempty(fp))
    fm = getdaysfiles(day,mk,[mk,'*behavior*','*mat']);
    parseDatafile(fm{1})    
end