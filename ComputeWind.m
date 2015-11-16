function ComputeWind(Predata,targetpath,Meshname)
%
% 计算风场
%
% ComputeWind(Predata,targetpath,Meshname)
%

copyfile([Predata,Meshname],targetpath); %copy mesh file
copyfile([Predata,'data_wind\cal_wind.exe'],targetpath); %copy wind exe
copyfile([Predata,'data_wind\wind.dat'],targetpath); %copy wind.dat
cd(targetpath);
%!cal_wind.exe
disp('风场计算完毕');