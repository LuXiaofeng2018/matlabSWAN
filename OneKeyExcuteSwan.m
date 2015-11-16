% 2015-11-12 10:06:13    V1.0  
%      程序还有很大的改进空间，ComputeTide()这个函数可以优化
%      可以改成输入变量个数自定义的，输出各过程计算所需要的时间，优化predata文件夹中所用到的文件
%
% 2015-11-13 09:55:32    V1.1 将computetide-->computetide2,加入vargin
%      准备加入  每步执行完之后发送邮件，将该步所用时间写入时间文件中
% 2015-11-16 09:02:07    V1.2 已加入发送邮件和每步算完之后所用的时间
% 执行台风浪
% 1. 准备geo 和 fort.14 两个网格文件
%    geo    : 生成风场；天文潮验证；风暴潮验证；
%    fort.14: swan
% 2. 生成风场 需要的文件 cal_wind.exe wind.dat（提供台风路径信息，风，气压）
% 
% 3. 天文潮验证
%    需要准备好 data文件夹中的系列文件
% 4. 风暴潮验证
%    利用第二步生成的wind_ycsw.dat 在天文潮的基础上加入风场进行计算
%    生成swaninput_uv.dat  swaninput_z.dat 提供给swan进行计算
% 5. swan 网格是fort.14 利用的第二步生成的wind_swan.dat 和第四步生成的swan*.dat
%
% 6. 加辐射应力

%%
close all;clear all;clc
%
%%
% 指定各种目录
% 每次执行前主目录与上次的不一样，否则上一次的结果将会被删除
mainpath='d:\WaveTest1\';     % 指定将该部分程序放在哪个目录中执行
PrePath='Predata\';
ThisDir=pwd;
YCSW='YCSW20150908.exe';
Meshname='0.geo';
CoreNum=3;    %使用多少个线程来计算
TimeOutFile='TimeElapse.txt';
disp(['该case所在的主目录为:  ',mainpath]);
disp('   该目录为你需要的目录？ ')
disp('=====  Attention   =====')
disp('如果该目录已存在将会被删除:')
results='y'; %input(' y/n?  ','s');
if strcmp(results,'y')
else
    disp('目录指定有误，请重新输入: ');
    mainpath=input('MainPath: ','s');
end

OtherPaths={PrePath;       % geo fort.14 data文件夹存放处，后面的步骤中需要的时候从这个文件夹中提取  
    [mainpath,'WindPre'];    %风场计算文件夹
    [mainpath,'天文潮验证'];  %水动力的data文件
    [mainpath,'风暴潮'];      %风暴潮计算位置
    [mainpath,'台风浪'];      %台风浪计算位置
    [mainpath,'风暴潮辐射应力'];
    [mainpath,'风暴潮辐射应力台风浪'];
    };
%% Switch of each Process
%        wind Tide WindStorm SwanStorm  Rad Stress   SWAN+Rad stress
ProSwitch=[1,   1,   1,       1 ,        1          ,  1];
%%
%
% 新建主目录下的各种目录
%
if max(ProSwitch)>0
    for ii=2:length(OtherPaths)
        if ProSwitch(ii-1) %Switch on then New Dir
            PreDir(OtherPaths{ii}); 
        end
    end
end

%%
% Step 1 : 风场计算
%
fid=fopen(TimeOutFile,'w');
fprintf(fid,'%20s\n','各个过程所用的时间');
fprintf(fid,'%20s','风场计算');
if ProSwitch(1) 
    t1=clock;
    ComputeWind(OtherPaths{1},OtherPaths{2},Meshname);
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'分钟');
else
    fprintf(fid,'\n');
end
fclose(fid);
cd(ThisDir);
%%
% Step 2 : Tide
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','天文潮计算');
if ProSwitch(2)
    t1=clock;
    ComputeTide2(OtherPaths{1},OtherPaths{3},CoreNum,Meshname,YCSW);
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'分钟');
    % send mail 
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['天文潮计算完毕,历时 ',sprintf('%15.5f',etime(clock,t1)./60),'分钟'];
    SendMailForSwan(subject,content);
else
     fprintf(fid,'\n'); 
     cd(ThisDir);
     subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
     content='天文潮计算未进行，已算完或开关未打开，请确认！';
     SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%%
% Step 3: WindStorm
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','风暴潮计算');
if ProSwitch(3)
    t1=clock;
    ComputeTide2(OtherPaths{1},OtherPaths{4},CoreNum,Meshname,YCSW,OtherPaths{2});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'分钟');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['风暴潮计算完毕,历时 ',sprintf('%15.5f',etime(clock,t1)./60),'分钟'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');  
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='风暴潮计算未进行，已算完或开关未打开，请确认！';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%%
%
%   Step 4 : SWAN+wind
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','台风浪计算');
if ProSwitch(4)
    t1=clock;
    ComputeSwan(OtherPaths{1},OtherPaths{5},OtherPaths{2},OtherPaths{4});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'分钟');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['台风浪计算完毕,历时 ',sprintf('%15.5f',etime(clock,t1)./60),'分钟'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='台风浪计算未进行，已算完或开关未打开，请确认！';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%%
%
%  Step 5: Storm + RadStress
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','辐射应力计算');
if ProSwitch(5)
    t1=clock;
    ComputeTide2(OtherPaths{1},OtherPaths{6},CoreNum,Meshname,YCSW,OtherPaths{2},OtherPaths{5});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'分钟');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['辐射应力计算完毕,历时 ',sprintf('%15.5f',etime(clock,t1)./60),'分钟'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='辐射应力计算未进行，已算完或开关未打开，请确认！';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);
%
%  Step 6: Storm + RadStress +SWAN
%
fid=fopen(TimeOutFile,'a');
fprintf(fid,'%20s','辐射应力SWAN');
if ProSwitch(6)
    t1=clock;
    %
    % 将第五步算出的加辐射应力的风暴潮结果加入到SWAN中进行计算
    %
    ComputeSwan(OtherPaths{1},OtherPaths{7},OtherPaths{2},OtherPaths{6});
    fprintf(fid,'%s  %20s \n',sprintf('%15.5f',etime(clock,t1)./60),'分钟');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content=['辐射应力+Swan计算完毕,历时 ',sprintf('%15.5f',etime(clock,t1)./60),'分钟'];
    SendMailForSwan(subject,content);
else
    fprintf(fid,'\n');
    cd(ThisDir);
    subject=['SWAN Process -- ',datestr(now,'yyyy-mm-dd HH:MM:SS')];
    content='辐射应力+Swan计算未进行，已算完或开关未打开，请确认！';
    SendMailForSwan(subject,content);
end
% cd(ThisDir);
fclose(fid);