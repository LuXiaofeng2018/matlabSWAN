% 2015-11-12 10:06:13    V1.0  
%      �����кܴ�ĸĽ��ռ䣬ComputeTide()������������Ż�
%      ���Ըĳ�������������Զ���ģ���������̼�������Ҫ��ʱ�䣬�Ż�predata�ļ��������õ����ļ�
%
% 2015-11-13 09:55:32    V1.1 ��computetide-->computetide2,����vargin
%      ׼������  ÿ��ִ����֮�����ʼ������ò�����ʱ��д��ʱ���ļ���
% 2015-11-16 09:02:07    V1.2 �Ѽ��뷢���ʼ���ÿ������֮�����õ�ʱ��
% ִ��̨����
% 1. ׼��geo �� fort.14 ���������ļ�
%    geo    : ���ɷ糡�����ĳ���֤���籩����֤��
%    fort.14: swan
% 2. ���ɷ糡 ��Ҫ���ļ� cal_wind.exe wind.dat���ṩ̨��·����Ϣ���磬��ѹ��
% 
% 3. ���ĳ���֤
%    ��Ҫ׼���� data�ļ����е�ϵ���ļ�
% 4. �籩����֤
%    ���õڶ������ɵ�wind_ycsw.dat �����ĳ��Ļ����ϼ���糡���м���
%    ����swaninput_uv.dat  swaninput_z.dat �ṩ��swan���м���
% 5. swan ������fort.14 ���õĵڶ������ɵ�wind_swan.dat �͵��Ĳ����ɵ�swan*.dat
%
% 6. �ӷ���Ӧ��

%%
close all;clear all;clc
%
%%
% ָ������Ŀ¼
% ÿ��ִ��ǰ��Ŀ¼���ϴεĲ�һ����������һ�εĽ�����ᱻɾ��
mainpath='d:\WaveTest1\';     % ָ�����ò��ֳ�������ĸ�Ŀ¼��ִ��
PrePath='Predata\';
ThisDir=pwd;
YCSW='YCSW20150908.exe';
Meshname='0.geo';
CoreNum=3;    %ʹ�ö��ٸ��߳�������
TimeOutFile='TimeElapse.txt';
disp(['��case���ڵ���Ŀ¼Ϊ:  ',mainpath]);
disp('   ��Ŀ¼Ϊ����Ҫ��Ŀ¼�� ')
disp('=====  Attention   =====')
disp('�����Ŀ¼�Ѵ��ڽ��ᱻɾ��:')
results='y'; %input(' y/n?  ','s');
if strcmp(results,'y')
else
    disp('Ŀ¼ָ����������������: ');
    mainpath=input('MainPath: ','s');
end

OtherPaths={PrePath;       % geo fort.14 data�ļ��д�Ŵ�������Ĳ�������Ҫ��ʱ�������ļ�������ȡ  
    [mainpath,'WindPre'];    %�糡�����ļ���
    [mainpath,'���ĳ���֤'];  %ˮ������data�ļ�
    [mainpath,'�籩��'];      %�籩������λ��
    [mainpath,'̨����'];      %̨���˼���λ��
    [mainpath,'�籩������Ӧ��'];
    [mainpath,'�籩������Ӧ��̨����'];
    };
%% Switch of each Process
%        wind Tide WindStorm SwanStorm  Rad Stress   SWAN+Rad stress
ProSwitch=[1,   1,   1,       1 ,        1          ,  1];
%%
%
% �½���Ŀ¼�µĸ���Ŀ¼
%
if max(ProSwitch)>0
    for ii=2:length(OtherPaths)
        if ProSwitch(ii-1) %Switch on then New Dir
            PreDir(OtherPaths{ii}); 
        end
    end
end

%%
% Step 1 : �糡����
%
fid=fopen(TimeOutFile,'w');
fprintf(fid,'%20s\n','�����������õ�ʱ��');
fprintf(fid,'%20s','�糡����');
if ProSwitch(1) 
    t1=clock;
    ComputeWind(OtherPaths{1},OtherPaths{2},Meshname);
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'����');
else
    fprintf(fid,'\n');
end
fclose(fid);
cd(ThisDir);
%%
% Step 2 : Tide
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','���ĳ�����');
if ProSwitch(2)
    t1=clock;
    ComputeTide2(OtherPaths{1},OtherPaths{3},CoreNum,Meshname,YCSW);
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'����');
    % send mail 
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['���ĳ��������,��ʱ ',sprintf('%15.5f',etime(clock,t1)./60),'����'];
    SendMailForSwan(subject,content);
else
     fprintf(fid,'\n'); 
     cd(ThisDir);
     subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
     content='���ĳ�����δ���У�������򿪹�δ�򿪣���ȷ�ϣ�';
     SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%%
% Step 3: WindStorm
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','�籩������');
if ProSwitch(3)
    t1=clock;
    ComputeTide2(OtherPaths{1},OtherPaths{4},CoreNum,Meshname,YCSW,OtherPaths{2});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'����');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['�籩���������,��ʱ ',sprintf('%15.5f',etime(clock,t1)./60),'����'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');  
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='�籩������δ���У�������򿪹�δ�򿪣���ȷ�ϣ�';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%%
%
%   Step 4 : SWAN+wind
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','̨���˼���');
if ProSwitch(4)
    t1=clock;
    ComputeSwan(OtherPaths{1},OtherPaths{5},OtherPaths{2},OtherPaths{4});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'����');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['̨���˼������,��ʱ ',sprintf('%15.5f',etime(clock,t1)./60),'����'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='̨���˼���δ���У�������򿪹�δ�򿪣���ȷ�ϣ�';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%%
%
%  Step 5: Storm + RadStress
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','����Ӧ������');
if ProSwitch(5)
    t1=clock;
    ComputeTide2(OtherPaths{1},OtherPaths{6},CoreNum,Meshname,YCSW,OtherPaths{2},OtherPaths{5});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'����');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['����Ӧ���������,��ʱ ',sprintf('%15.5f',etime(clock,t1)./60),'����'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='����Ӧ������δ���У�������򿪹�δ�򿪣���ȷ�ϣ�';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%
%  Step 6: Storm + RadStress +SWAN
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','����Ӧ��SWAN');
if ProSwitch(6)
    t1=clock;
    %
    % �����岽����ļӷ���Ӧ���ķ籩��������뵽SWAN�н��м���
    %
    ComputeSwan(OtherPaths{1},OtherPaths{7},OtherPaths{2},OtherPaths{6});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'����');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['����Ӧ��+Swan�������,��ʱ ',sprintf('%15.5f',etime(clock,t1)./60),'����'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='����Ӧ��+Swan����δ���У�������򿪹�δ�򿪣���ȷ�ϣ�';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);