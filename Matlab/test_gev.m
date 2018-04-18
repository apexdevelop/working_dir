% blocksize = 1000;
% nblocks = 250;
% rng default  % For reproducibility
% t = trnd(5,blocksize,nblocks);
% x = max(t); % 250 column maxima
% paramEsts = gevfit(x);
% histogram(x,2:20,'FaceColor',[.8 .8 1]);
% xgrid = linspace(2,20,1000);
% line(xgrid,nblocks*...
%      gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)));
clearvars;
cd('Y:/working_directory/Matlab/Data/dispersion');
% addpath(genpath('Y:/working_directory/Matlab'))
javaaddpath('C:\blp\DAPI\APIv3\JavaAPI\v3.10.1.1\lib\blpapi3.jar');
[num,txt]=xlsread('dispersion_gina','universe','c1:c1000');

%% generate Data
startdate='2014/6/1';
enddate=today();
per={'daily','non_trading_weekdays','previous_value'};

z_window=60;
corr_window=20;
mov_window=10;

% processing time started
tic
Metrics=[];

for i=1:size(txt,2)
    temp_txt=txt(:,i);
    temp_txt=temp_txt(~cellfun('isempty',temp_txt));
    %Bloomberg Part starts
    c=blp;
    for loop=1:size(temp_txt,1)
        new=char(temp_txt(loop));
        [d1, sec] = history(c, new,'CHG_PCT_1D',startdate,enddate,per);
        [d2, sec] = history(c, new,'Last_Price',startdate,enddate,per);
        [d3, sec] = history(c, new,'CHG_PCT_5D',startdate,enddate,per);
        dates(1:size(d1,1),loop)=d1(1:size(d1,1),1);
        rtns(1:size(d1,1),loop)=d1(1:size(d1,1),2);
        prices(1:size(d2,1),loop)=d2(1:size(d2,1),2);
        rtns_5d(1:size(d3,1),loop)=d3(1:size(d3,1),2);
    end;
    close(c);
    % end of Bloomberg Part
    
    n_dim=size(rtns,2);

    tday1=dates(:, 1);
    rtn1=rtns(:, 1);
    px1=prices(:, 1);
    rtn1_5d=rtns_5d(:,1);
    
    rtn1(find(~tday1))=[];
    px1(find(~tday1))=[];
    rtn1_5d(find(~tday1))=[];
    tday1(find(~tday1))=[];
    
    for k=2:n_dim
        tday2=dates(:, k); 
        rtn2=rtns(:, k);
        px2=prices(:, k);
        rtn2_5d=rtns_5d(:, k);
        
        rtn2(find(~tday2))=[];
        px2(find(~tday2))=[];
        rtn2_5d(find(~tday2))=[];
        tday2(find(~tday2))=[];
        
        [n1n2, idx1, idx2]=intersect(tday1, tday2);
        tday1=tday1(idx1);
        
        rtn1=[rtn1(idx1,:) rtn2(idx2)];
        px1=[px1(idx1,:) px2(idx2)];
        rtn1_5d=[rtn1_5d(idx1,:) rtn2_5d(idx2)];
        
    end
    
    rtn_Y=rtn1;
    px_Y=px1;
    rtn_5dY=rtn1_5d;
    
    excel_date=m2xdate(tday1,0);
end

%% distribution of maxima of each component
x = max(rtn_Y(:,2:end));
paramEsts = gevfit(x);
histogram(x,2:20,'FaceColor',[.8 .8 1]);
xgrid = linspace(2,20,1000);
line(xgrid,size(x,2)*...
     gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)));