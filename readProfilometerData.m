
% consts
PATH='C:\Profilometer_Data\2022-04-17_18-07-46';
PLOT_POINTS = 500000;
SMOOTHING = 21;
MAX_RATIO = 1.03;
MIN_RATIO = 1 / MAX_RATIO;
RANGE_ROW = [];
RANGE_COLUMN = [];

% read data
opts = delimitedTextImportOptions('NumVariables', 5);
opts.DataLines = [2, Inf];
opts.Delimiter = '\t';
opts.VariableNames = {'Counter', 'Altitudem', 'Encoder1m', 'Encoder2m', 'RowNumber'};
opts.VariableTypes = {'double', 'double', 'double', 'double', 'double'};
opts.ExtraColumnsRule = 'ignore';
opts.EmptyLineRule = 'read';
tableData = readtable([PATH '.txt'], opts);
data = table2array(tableData);

% read parameters file
paramOpts = delimitedTextImportOptions('NumVariables', 2);
paramOpts.DataLines = [3, Inf];
paramOpts.Delimiter = '=';
paramOpts.VariableNames = {'Frequency', 'Hz'};
paramOpts.VariableTypes = {'double', 'double'};
paramOpts.ExtraColumnsRule = 'ignore';
paramOpts.EmptyLineRule = 'read';
paramOpts = setvaropts(paramOpts, {'Frequency', 'Hz'}, 'TrimNonNumeric', true);
paramOpts = setvaropts(paramOpts, {'Frequency', 'Hz'}, 'ThousandsSeparator', ',');
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
        readColumn = j;
        if rem(i,2) == 0
            readColumn = columnCount - j + 1;
        end
        
        read(i,readColumn) = data(currentRead,2);
        currentRead = currentRead+1;
    end
end

if size(RANGE_ROW,2) > 1
    read = read(RANGE_ROW,:);
    rowCount = size(RANGE_ROW,2);
end

if size(RANGE_COLUMN,2) > 1
    read = read(:,RANGE_COLUMN);
    columnCount = size(RANGE_COLUMN,2);
end

smoothed = zeros(size(read));
for i=1:rowCount
    smoothed(i,:) = smooth(read(i,:),SMOOTHING);
end

for i=1:rowCount
    for j=1:columnCount
        currentRead = read(i,j);
        currentRatio = currentRead / smoothed(i,j);
        if currentRatio > MAX_RATIO
            read(i,j) = currentRead * MAX_RATIO;
        end
        
        if currentRatio < MIN_RATIO
            read(i,j) = currentRead * MIN_RATIO;
        end
    end
end

roughness = abs(read - smoothed);

currentPoints = rowCount * columnCount;
if currentPoints > PLOT_POINTS
    resizeRatio = round(PLOT_POINTS/ rowCount);
    height = imresize(height, [rowCount resizeRatio]);
    roughness = imresize(roughness, [rowCount resizeRatio]);
end

totalHeight = num2str(yScale * (rowCount - 1));
totalWidth = num2str(xScale * (columnCount - 1));

% plot height
tiledlayout(2,1);
nexttile
imagesc(read);
colorbar
xlabel([totalWidth ' cm']);
ylabel([totalHeight ' mm']);
title('Profile');
nexttile
imagesc(roughness);
colorbar
xlabel([totalWidth ' cm']);
ylabel([totalHeight ' mm']);
title('Average Roughness');

% print roughness
disp(['Average Roughness: ', num2str(2 * mean(max(roughness))), ' microns']);