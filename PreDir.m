function PreDir(targetpath);
%
% ��ʼ���ļ��У�������ļ��д�����ɾ�������½�
%                        �����ڣ�ֱ���½�
%
if exist(targetpath,'dir');
%     rmdir(targetpath,'s');
%     mkdir(targetpath);
else
    mkdir(targetpath);
end