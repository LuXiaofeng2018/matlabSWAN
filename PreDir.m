function PreDir(targetpath);
%
% 初始化文件夹，如果该文件夹存在则删除，再新建
%                        不存在，直接新建
%
if exist(targetpath,'dir');
%     rmdir(targetpath,'s');
%     mkdir(targetpath);
else
    mkdir(targetpath);
end