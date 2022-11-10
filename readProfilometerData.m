
% consts
PATH='C:\Users\Owner\Desktop\Profile\202209-PVC\LowerBlock\2022-09-25_19-02-35';
PLOT_POINTS = 5000;

% read data
opts = delimitedTextImportOptions('NumVariables', 5);
opts.DataLines = [2, Inf];
opts.Delimiter = '\t';
opts.VariableNames = ['Counter', 'Altitudem', 'Encoder1m', 'Encoder2m', 'RowNumber'];
opts.VariableTypes = ['double', 'double', 'double', 'double', 'double'];
opts.ExtraColumnsRule = 'ignore';
opts.EmptyLineRule = 'read';
tableData = readtable([PATH '.txt'], opts);
data = table2array(tableData);

% read parameters file
paramOpts = delimitedTextImportOptions('NumVariables', 2);
paramOpts.DataLines = [3, Inf];
paramOpts.Delimiter = '=';
paramOpts.VariableNames = ['Frequency', 'Hz'];
paramOpts.VariableTypes = ['double', 'double'];
paramOpts.ExtraColumnsRule = 'ignore';
paramOpts.EmptyLineRule = 'read';
paramOpts = setvaropts(paramOpts, ['Frequency', 'Hz'], 'TrimNonNumeric', true);
paramOpts = setvaropts(paramOpts, ['Frequency', 'Hz'], 'ThousandsSeparator', ',');
tableParameters = readtable([PATH '_parameters.txt'], paramOpts);
parameters = table2array(tableParameters);

% read parametesr
rowCount = parameters(4,2);
yScale = parameters(5,2);
xScale = parameters(2,2);


% read data
columnCount = size(data,1)/rowCount;
read = zeros(rowCount, columnCount);

currentRead = 1;
for i=1:rowCount
    for j=1:columnCount
        read(i,j) = data(currentRead,2);
        currentRead = currentRead+1;
    end
end


% plot height
currentPoints = size(read,1) * size(read,2);
if currentPoints > PLOT_POINTS
    resizeRatio = round(sqrt(currentPoints / PLOT_POINTS));
    read = resize(read, resizeRatio);
end

image(read);
