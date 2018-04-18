% clear all;
% cd('C:\Users\ychen\Documents\MATLAB');
% txt1={'HSCEI Index';'TPX Index';'MXEU Index';'TWSE Index';'KOSPI Index';'SPX Index';'SX5E Index';'DAX Index';'IBEX Index';'NIFTY Index';'SET Index';'FBMKLCI Index';'JCI Index';'PCOMP Index';'MXEF Index';'IBOV Index';'MXZA Index';'MXRU Index';'MEXBOL Index';'MXTR Index'};
% javaaddpath('C:\blp\API\APIv3\JavaAPI\v3.6.1.0\lib\blpapi3.jar')
% startdate='05/30/2014';
% per='daily';
function [v_up,v_down,v_chg]=find_momentum(txt1,txt2)

startdate=char(txt2(1));
per=char(txt2(2));
[~, ~, bbpx]=blp_test(txt1,startdate,per);
v_up=zeros(size(bbpx,2)-1,1);
v_down=zeros(size(bbpx,2)-1,1);
v_chg=zeros(size(bbpx,2)-1,1);
for i=1:size(bbpx,2)-1
    v_px=bbpx(:,i+1);
    baddata=find(~v_px);
    v_px(baddata)=[];
    v_up(i)=(v_px(end)/min(v_px)-1)*100;
    v_down(i)=(v_px(end)/max(v_px)-1)*100;
    v_chg(i)=(v_px(end)/v_px(1)-1)*100;
end