function  InfoModify(Tfile,CoreNum,Meshname,Options)
%
% �޸�USER_CONTROL.DAT �� 0.dat
% Tfile   : Ŀ���ļ�  
% CoreNum : �߳���
% Meshname: ������
% Options : 'c' �޸�control.dat�е��߳���
%           'm' �޸�0.dat����������
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