%% Mango's implant
% RHA1 - M1
% RHA2 - S1
% RHA3 - 1-16  - M1
% RHA3 - 17-32 - S1 

function varargout = mangoImplant(names)

numN = length(names);
nType = ones(numN,1).*nan;
for i=1:numN
site = names{i}(1:4);
ch = str2double(names{i}(7:8));
switch site
    case 'RHA1'
        nType(i) = 1;
    case 'RHA2'
        nType(i) = 2;
    case 'RHA3'
        if ch > 16
            nType(i) = 2; 
        else
            nType(i) = 1; 
        end
    end
end

varargout{1} = nType;
      
