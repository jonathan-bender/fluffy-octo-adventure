
opts = delimitedTextImportOptions('NumVariables', 5);
opts.DataLines = [2, Inf];
opts.Delimiter = '\t';
opts.VariableNames = ['Counter', 'Altitudem', 'Encoder1m', 'Encoder2m', 'RowNumber'];
opts.VariableTypes = ['double', 'double', 'double', 'double', 'double'];
opts.ExtraColumnsRule = 'ignore';
opts.EmptyLineRule = 'read';

%% read data
name='C:\Users\Owner\Desktop\Profile\202209-PVC\LowerBlock\2022-09-25_19-02-35'; % lower blovk with sg

% name='C:\Users\Owner\Desktop\Profile\202209-PVC\2022-09-14_18-11-08';
% name='C:\Users\Owner\Desktop\Profile\CO2_lasercutting\PMMA\2022-04-17\2022-04-17_16-17-53';
% name='C:\Users\Owner\Desktop\Profile\CO2_lasercutting\PMMA\2022-04-17-1\2022-04-17_18-07-46';
Untitled = readtable([name '.txt'], opts);
data = table2array(Untitled);

%% set the parameters
opts = delimitedTextImportOptions('NumVariables', 2);
% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = '=';
% Specify column names and types
opts.VariableNames = ['Frequency', 'Hz'];
opts.VariableTypes = ['double', 'double'];
% Specify file level properties
opts.ExtraColumnsRule = 'ignore';
opts.EmptyLineRule = 'read';
% Specify variable properties
opts = setvaropts(opts, ['Frequency', 'Hz'], 'TrimNonNumeric', true);
opts = setvaropts(opts, ['Frequency', 'Hz'], 'ThousandsSeparator', ',');
% Import the data
parameters = readtable([name '_parameters.txt'], opts);
% Convert to output type
parameters = table2array(parameters);

clear opts
%%
Num_row=parameters(4,2);

for i=1:Num_row
    r_begin(i)=find(data(:,5)==i,1,'first');
    r_end(i)=find(data(:,5)==i,1,'last');
    length(i)=r_end(i)-r_begin(i)+1;
end
Num_point=max(length);

x1=zeros(Num_row,Num_point); x2=zeros(Num_row,Num_point);
y1=zeros(Num_row,Num_point); y2=zeros(Num_row,Num_point);
z1=zeros(Num_row,Num_point); z2=zeros(Num_row,Num_point);

% t=0;
for i=1:2:Num_row
%     t=t+1;
    z(i,1:length(i))=data(r_begin(i):r_end(i),2);
    x(i,1:length(i))=data(r_begin(i):r_end(i),3);
    y(i,1:length(i))=i;
%     y(i,1:length(i))=t;
end

% t=0;
for i=2:2:Num_row
%     t=t+1;
    z(i,length(i):-1:1)=data(r_begin(i):r_end(i),2);
    x(i,length(i):-1:1)=data(r_begin(i):r_end(i),3);
    y(i,length(i):-1:1)=i;
end


x=x*1; % x direction is the real scale, no need multipile step scale.[need for mesh]
y=y*parameters(5,2)*1000; % scale one step in y [um]

z_Err1=z(:,1:end-1);
z_Err2=z(:,2:end);
z_Err=z_Err1-z_Err2;
Err1=double(z_Err>100);
Err2=double(z_Err<-100);
Err=zeros(Num_row,Num_point);
Err(:,2:end)=Err(:,2:end) + Err1;
Err(:,1:end-1)=Err(:,1:end-1) + Err2;
z(Err==1)=NaN;
z(z==0)=NaN;

figure
surf(x,y,z,'LineStyle','none','EdgeColor','interp')
% xlim([200 3700])
view([0 -90]) % 2D view 
save('surf0.mat', 'x','y','z')
%%
gapy=parameters(5,2)*1000; 
gapx=parameters(2,2)*1000; % but need here for mesh
[xq,yq] = meshgrid(0:gapx:max(max(x)), gapy:gapy:max(max(y)));
zq = griddata(x,y,z,xq,yq,'nearest');

%%
zq=fliplr(zq);


figure
surf(xq,yq,-zq,'LineStyle','none')
view([0 -90])
save('surf.mat', 'xq','yq','zq')


x0=reshape(xq,[],1);
y0=reshape(yq,[],1);
z0=reshape(zq,[],1);

prof_map=[x0 y0 z0];
writematrix(prof_map, 'fracture_surface0.txt','Delimiter','tab')

z0(isnan(z0))=0;
prof_map2=[x0 y0 z0];
writematrix(prof_map2, 'fracture_surface.txt','Delimiter','tab')

%% 2021-11-22 add
% figure(2),
% axis equal
% axis([0 5000 0 7000])
%% 3D
figure(3)
surf(xq,yq,zq,'LineStyle','none')
%% local xz 
figure(4)
j=20;
plot(xq(j:j+5,:),zq(j:j+5,:),'.')
%%
figure(5)
surf(x,y,-z,'LineStyle','none','EdgeColor','interp')
% xlim([200 3700])
%view([0 -90]





