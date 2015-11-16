function ComputeTide2(varargin)
% Predata,targetpath,CoreNum,Meshname,YCSW,...
%                      WindRes,SwanRes,windopt,RadStress)
%
% YCSW程序执行部分
% 包括： 天文潮、风暴潮、风暴潮+辐射应力
%  Predata 文件准备目录   Targetpath 目标路径
%  CoreNum 线程数         Meshname  网格名
%  YCSW  exe 文件名    
%  WindRes 风场计算目录    SwanRes 波浪计算目录
% 
% 天文潮部分
%  ComputeTide2(Predata,Targetpath,CoreNum,Meshname,YCSW)
% 风暴潮部分
%  ComputeTide2(Predata,Targetpath,CoreNum,Meshname,YCSW，WindRes)
% 辐射应力部分
%  ComputeTide2(Predata,Targetpath,CoreNum,Meshname,YCSW，WindRes，SwanRes)
%
% varargin  天文潮varargin==5  风暴潮 varargin==6 辐射应力 varargin==7
% ComputeTide(Predata,targetpath,CoreNum,Meshname,YCSW,...
%                     WindRes,SwanRes,windopt,RadStress)
% 2015-11-13 09:52:19 使用 varargin  V1.1 liuy 
%
if nargin<5 || nargin>7
    error('变量数目不正确, 详见 help ComputeTide2 ')   
elseif (nargin==5)
    disp('====== 天文潮   =====')
    Predata    = varargin{1};    targetpath = varargin{2};
    CoreNum    = varargin{3};    Meshname   = varargin{4};
    YCSW       = varargin{5}; 
elseif (nargin==6)
    disp('====== 风暴潮   =====')
    Predata    = varargin{1};    targetpath = varargin{2};
    CoreNum    = varargin{3};    Meshname   = varargin{4};
    YCSW       = varargin{5};    WindRes    = varargin{6};
elseif (nargin==7)   
    disp('====== 辐射应力 =====')
    Predata    = varargin{1};    targetpath = varargin{2};
    CoreNum    = varargin{3};    Meshname   = varargin{4};
    YCSW       = varargin{5};    WindRes    = varargin{6};
    SwanRes    = varargin{7};
end

TideData= [targetpath,'\data\'  ];
TideOut = [targetpath,'\output\'];
%
% 清空输出目录
%
if exist(TideOut,'dir');
    rmdir(TideOut,'s');
    mkdir(TideOut);
else
    mkdir(TideOut);
end

if (nargin==7)      %辐射应力
    copyfile([Predata,'data_RadStress\'],TideData);
elseif (nargin==6)  %风暴潮
    copyfile([Predata,'data_storm\'],TideData);
else                %天文潮
    copyfile([Predata,'data_tide\'],TideData);
end

copyfile([Predata,Meshname],TideData);

%
% YCSW.exe 及 相关文件
%
copyfile([Predata,'0.dat'],targetpath);
copyfile([Predata,YCSW],targetpath);
copyfile([Predata,'libiomp5md.dll'],targetpath);
%
% wind_ycsw.dat
%
if     (nargin==7) 
        copyfile([WindRes,'\WIND_YCSW.DAT',],TideData);
        copyfile([SwanRes,'\wave.dat'],TideData);
elseif (nargin==6) 
        copyfile([WindRes,'\WIND_YCSW.DAT',],TideData);
end
% 
% 修改线程数
% 
InfoModify([TideData,'USER_CONTRAL.DAT'],CoreNum,Meshname,'c');
%
% 修改网格名
%
InfoModify([targetpath,'\0.dat'],CoreNum,Meshname,'m');
%
cd(targetpath)
%
% 执行程序 
%
system(YCSW);
