cd('C:\Documents and Settings\nthakkar.AC\My Documents');

enddate=today()-1;
startdate=enddate-1600;
[num,txt]=xlsread('input_ticker','proxy','c1');


% GET DATA
c=blp;


    new=char(txt);
    [d sec] = history(c, new,'Last_Price',startdate,enddate);
    btxt(1:size(d,1))=d(1:size(d,1),1);
    bbpx(1:size(d,1))=d(1:size(d,1),2);
    
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


Y=NaN(length(tday1), 1); 
Y=adjcls1;

baddata=find(any(~isfinite(Y), 1)); % days where any one price is missing
tday1(baddata)=[];
Y(baddata, :)=[];

tday_str=datestr(tday1);
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
  
