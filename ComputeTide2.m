function ComputeTide2(varargin)
% Predata,targetpath,CoreNum,Meshname,YCSW,...
%                      WindRes,SwanRes,windopt,RadStress)
%
% YCSW����ִ�в���
% ������ ���ĳ����籩�����籩��+����Ӧ��
%  Predata �ļ�׼��Ŀ¼   Targetpath Ŀ��·��
%  CoreNum �߳���         Meshname  ������
%  YCSW  exe �ļ���    
%  WindRes �糡����Ŀ¼    SwanRes ���˼���Ŀ¼
% 
% ���ĳ�����
%  ComputeTide2(Predata,Targetpath,CoreNum,Meshname,YCSW)
% �籩������
%  ComputeTide2(Predata,Targetpath,CoreNum,Meshname,YCSW��WindRes)
% ����Ӧ������
%  ComputeTide2(Predata,Targetpath,CoreNum,Meshname,YCSW��WindRes��SwanRes)
%
% varargin  ���ĳ�varargin==5  �籩�� varargin==6 ����Ӧ�� varargin==7
% ComputeTide(Predata,targetpath,CoreNum,Meshname,YCSW,...
%                     WindRes,SwanRes,windopt,RadStress)
% 2015-11-13 09:52:19 ʹ�� varargin  V1.1 liuy 
%
if nargin<5 || nargin>7
    error('������Ŀ����ȷ, ��� help ComputeTide2 ')   
elseif (nargin==5)
    disp('====== ���ĳ�   =====')
    Predata    = varargin{1};    targetpath = varargin{2};
    CoreNum    = varargin{3};    Meshname   = varargin{4};
    YCSW       = varargin{5}; 
elseif (nargin==6)
    disp('====== �籩��   =====')
    Predata    = varargin{1};    targetpath = varargin{2};
    CoreNum    = varargin{3};    Meshname   = varargin{4};
    YCSW       = varargin{5};    WindRes    = varargin{6};
elseif (nargin==7)   
    disp('====== ����Ӧ�� =====')
    Predata    = varargin{1};    targetpath = varargin{2};
    CoreNum    = varargin{3};    Meshname   = varargin{4};
    YCSW       = varargin{5};    WindRes    = varargin{6};
    SwanRes    = varargin{7};
end

TideData= [targetpath,'\data\'  ];
TideOut = [targetpath,'\output\'];
%
% ������Ŀ¼
%
if exist(TideOut,'dir');
    rmdir(TideOut,'s');
    mkdir(TideOut);
else
    mkdir(TideOut);
end

if (nargin==7)      %����Ӧ��
    copyfile([Predata,'data_RadStress\'],TideData);
elseif (nargin==6)  %�籩��
    copyfile([Predata,'data_storm\'],TideData);
else                %���ĳ�
    copyfile([Predata,'data_tide\'],TideData);
end

copyfile([Predata,Meshname],TideData);

%
% YCSW.exe �� ����ļ�
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
% �޸��߳���
% 
InfoModify([TideData,'USER_CONTRAL.DAT'],CoreNum,Meshname,'c');
%
% �޸�������
%
InfoModify([targetpath,'\0.dat'],CoreNum,Meshname,'m');
%
cd(targetpath)
%
% ִ�г��� 
%
system(YCSW);
