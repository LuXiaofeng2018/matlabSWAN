function SendMail(subject,content)
%
%  To sendmail from Matlab 
%  SendMail(subject,content)

%
%Send mail
%
TargetAddress='253588604@qq.com';
SourceAddress='liu08_13@126.com';
password='813428liu';
Attachments=[];
MatlabSendMailGeneral(subject,content,TargetAddress, Attachments,SourceAddress,password)
