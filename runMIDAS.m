 function mcScriptRun()  

clear functions
clear classes


%Uncomment Paths if running directly from laptop
%addpath('./Core_MIDAS_Code');
%addpath('./Application_Specific_MIDAS_Code');
%addpath('./Data');
%addpath('./Outputs');

rng('shuffle');

runName = 'FarmSeasonality';
series = ['SenegalBaseCase_MedianRun'];
saveDirectory = 'MIDAS-Senegal/Outputs/';

%Uncomment saveDirectory below if saving on local computer
%saveDirectory = 'Outputs/';

input = [];

%this next line runs the MIDAS model
output = midasMainLoop(input, runName);


functionVersions = inmem('-completenames');
functionVersions = functionVersions(strmatch(pwd,functionVersions));
output.codeUsed = functionVersions;
currentFile = [series num2str(length(dir([series '*']))) '_' datestr(now) '.mat'];
currentFile = [saveDirectory currentFile];

%make the filename compatible across Mac/PC
currentFile = strrep(currentFile,':','-');
currentFile = strrep(currentFile,' ','_');

saveToFile(input, output, currentFile);



end

function saveToFile(input, output, filename);
    save(filename,'input', 'output');
end