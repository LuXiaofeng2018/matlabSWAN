function ComputeSwan(Predata,targetpath,WindRes,StormRes)
%
% ����̨����
% ComputeSwan(Predata,targetpath,WindRes,StormRes)
%
TideData=targetpath;
copyfile([Predata,'data_swan\'],TideData);
%
% WindRes
%
copyfile([WindRes,'\WIND_SWAN.DAT',],TideData);
%
% StormRes
%
copyfile([StormRes,'\output\SWAN_INPUTUV.DAT',],TideData);
copyfile([StormRes,'\output\SWAN_INPUTZ.DAT',],TideData);
%
% Execute
%
cd(targetpath)
system('swan.exe')
