function [TIME, DATA, Data_label]=importFEBio_logfile(import_name)
% 
% FORMAT:
%
%   *Title:
%   *Step  = 1
%   *Time  = 0.05
%   *Data  = x;y;z
%   1, -5.01378, 0, 0
%   2, -5.01378, 0, 1.24313
%   3, -5.01378, 0, 2.48626
%   *Step  = 2
%   *Time  = 0.1
%   *Data  = x;y;z
%   1, -5.01378, 0, 0
%   2, -5.01378, 0, 1.24313
%   3, -5.01378, 0, 2.48626

%% Loading .txt file into cell array
[T]=txtfile2cell(import_name);
T=T(2:end);

%% Getting time data and crop indices
target='*Time';
L=cellfun(@(x)~isempty(x),(strfind(T,target)));
no_steps=(sum(L));

T_time=T(L);
TIME=cell2mat(cellfun(@(x) (sscanf(x,'*Time = %f')'),T_time,'UniformOutput',0));

IND=find(L);
IND1=IND+2;
IND2=[IND(2:end)-2;size(T,1)];

no_data=IND2(1)-IND1(1)+1;
if no_data>1
    [IND]=linspacen(IND1,IND2,no_data); IND=round(IND(:));
else
    IND=IND+2;
end

L=false(size(L));
L(IND)=1;
T_data=T(L);

% x=repmat(rand(5,4),3,1)
% permute(reshape(permute(x,[2,3,1]),4,5,3),[2,1,3])
% permute(reshape(permute(DATA,[2,3,1]),size(DATA,1)./no_steps,size(DATA,2),no_steps),[2,1,3])

%% Getting data
DATA=cell2mat(cellfun(@(x) (sscanf(x,'%f,')'),T_data,'UniformOutput',0));

if no_data>1    
    DATA=permute(reshape(permute(DATA,[2,3,1]),size(DATA,2),size(DATA,1)./no_steps,no_steps),[2,1,3]);
end

Data_label=T{3,:}(9:end);

end
