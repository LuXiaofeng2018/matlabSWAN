function  InfoModify(Tfile,CoreNum,Meshname,Options)
%
% 修改USER_CONTROL.DAT 和 0.dat
% Tfile   : 目标文件  
% CoreNum : 线程数
% Meshname: 网格名
% Options : 'c' 修改control.dat中的线程数
%           'm' 修改0.dat中网格名称
%
fid=fopen(Tfile,'r');
ii=1;
tline=cell(500,1);
while ~feof(fid)
    tline{ii}=fgetl(fid);
    ii=ii+1;
end
tline(cellfun(@isempty,tline))=[];
fclose(fid);
fid=fopen(Tfile,'w');
if strcmp(Options,'c')
    tline{2}=num2str(CoreNum);
elseif strcmp(Options,'m')
    tline{2}=['data\',Meshname];
end
for jj=1:ii-1
    fprintf(fid,'%s\n',tline{jj});
end
fclose(fid);