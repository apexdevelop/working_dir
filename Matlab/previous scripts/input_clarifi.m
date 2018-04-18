cd('C:\Documents and Settings\nthakkar.AC\My Documents');

enddate=today()-1;
startdate=enddate-1600;
[num,txt]=xlsread('input_ticker','proxy','c1');


% GET DATA
c=blp;

for loop=1:size(txt,1)
    new=char(txt(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate);
    btxt(1:size(d,1),loop+1)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop+1)=d(1:size(d,1),2);
    
end;
close(c);
bbctrstk=0;
for bbctrstk=1:size(btxt,1)
    btxt(bbctrstk,1)=bbctrstk;
end
bbctrstk2=0;
for bbctrstk2=1:size(bbpx,1)
    bbpx(bbctrstk2,1)=bbctrstk2;
end

dtxt=sortrows(btxt,-1);
px=sortrows(bbpx,-1);


clear Y;
clear tday;

tday1=btxt(:,2);
adjcls1=bbpx(:, 2);

tday2=btxt(:,3);
adjcls2=bbpx(:, 3); 
tday=union(tday1, tday2); 
baddata1=find(any(tday));
tday(baddata1)=[];
[foo idx idx1]=intersect(tday, tday1);
Y=NaN(length(tday), 2); 
Y(idx, 1)=adjcls1(idx1);
[foo idx idx2]=intersect(tday, tday2);
Y(idx, 2)=adjcls2(idx2);
baddata=find(any(~isfinite(Y), 2)); % days where any one price is missing
tday(baddata)=[];
Y(baddata, :)=[];

tday_str=datestr(tday);
Y_str=num2str(Y(:,1));
Y_final=[];
for t=1:size(Y,1)
ynew=[tday_str(t,:) blanks(1) Y_str(t,:)];
Y_final=[Y_final;ynew];
end


%if exist('rmb','var')~= 0
   
    fid = fopen('jpy.txt', 'w');
    fprintf(fid, 'Date        Price\n');
for t=1:size(Y,1)
    fprintf(fid,'%s\n', Y_final(t,:));  
end
  fclose(fid);
  
%   Y_str2=num2str(Y(:,2));
%   Y_final2=[];
% for t=1:size(Y,1)
% ynew2=[tday_str(t,:) blanks(1) Y_str2(t,:)];
% Y_final2=[Y_final2;ynew2];
% end
% 
% fid2 = fopen('hscci.txt', 'w');
%     fprintf(fid, 'Date        Price\n');
% for t=1:size(Y,1)
%     fprintf(fid2,'%s\n', Y_final2(t,:));  
% end
%   fclose(fid2);