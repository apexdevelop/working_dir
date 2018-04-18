javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
cd('C:\Users\ychen\Documents\MATLAB');
clear all;
%% GET Bloomberg DATA
enddate=today();
startdate=char(txt(1));
c=blp;

for loop=2:size(txt,1)
    new=char(txt(loop));
    [d sec] = history(c, new,'Last_Price',startdate,enddate);
    btxt(1:size(d,1),loop)=d(1:size(d,1),1);
    bbpx(1:size(d,1),loop)=d(1:size(d,1),2);
    
end;

close(c);

for n_time=1:size(btxt,1)
    btxt(n_time,1)=n_time;
end

for n_stk=1:size(bbpx,1)
    bbpx(n_stk,1)=n_stk;
end
s=size(btxt,1);

%% Resample
tday1=dtxt(1:s, 2); 
adjcls1=px(1:s, 2); 
tday1(find(~tday1))=[];
adjcls1(find(~adjcls1))=[];

tday2=dtxt(1:s, 3);
adjcls2=px(1:s, 3);

[foo idx1 idx2]=intersect(tday1, tday2);

tday=tday2(idx2);
baddata=find(~tday);
tday(baddata)=[];
Y=zeros(size(foo,1),2);
Y(:,1)=adjcls1(idx1);
Y(:,2)=adjcls2(idx2);

s1=size(Y,1);

%% empirical marginal transformation
zscore_window=126;
N=22;
pre=7;
post=7;
TH=1.2;
      
        
z_adjcls=adjcls(zscore_window:end,:);
x=zscore_window;
while x<=s1
      new_adjcls=adjcls(x-zscore_window+1:x,:);
      mu=mean(new_adjcls);
      sigma=std(new_adjcls);
      z_adjcls(x-zscore_window+1:x,1)=(new_adjcls(:,1)-mu(1))/sigma(1);
      z_adjcls(x-zscore_window+1:x,2)=(new_adjcls(:,2)-mu(2))/sigma(2);
      x=x+N;
end
s2=size(z_adjcls,1);
        
adjcls1_row=reshape(z_adjcls(:,1),1,s2);     
adjcls2_row=reshape(z_adjcls(:,2),1,s2);
        
adjcls1_filter=zeros(1,s2);
adjcls2_filter=zeros(1,s2);
for x=1:s2
    if adjcls1_row(x)>=TH || adjcls1_row(x)<=-TH
                adjcls1_filter(x)=adjcls1_row(x);
    else
                adjcls1_filter(x)=0;
    end
            
    if adjcls2_row(x)>=TH || adjcls2_row(x)<=-TH
                adjcls2_filter(x)=adjcls2_row(x);
    else
                adjcls2_filter(x)=0;
    end
end
        
v_area1=zeros(1,s2);
v_area2=zeros(1,s2);
for x=1:s2
    if x>=1+pre && x<=s2-post
       v_adjcls1_row=adjcls1_filter(:,x-pre:x+post); %pick a small window
       v_area1(1,x)=trapz(v_adjcls1_row);
       v_adjcls2_row=adjcls2_filter(:,x-pre:x+post);
       v_area2(1,x)=trapz(v_adjcls2_row);
    else
       v_area1(1,x)=0;
       v_area2(1,x)=0; 
    end
end
        
subplot(2,2,1); plot(adjcls1_row);
subplot(2,2,2); plot(v_area1);
        
subplot(2,2,3); plot(adjcls2_row);
subplot(2,2,4); plot(v_area2);


