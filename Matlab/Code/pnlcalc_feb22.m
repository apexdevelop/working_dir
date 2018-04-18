% i=1;
% j=2;
tog=0;
buys=0;
sells=0;
buydollar=0;
selldollar=0;
win=0;
daymkt=0;
pnl=0;

% tottrade=0;
% r=1;
cross=0;
% sl=5;
% sg=10;
% do=10;
band=1.5*std(zscr);

recs=size(adjcls(end-29:end,1),1); 


% when in long or short position, in terms of stock1
        for ctr=2:recs
            if (tog==1) || (tog==2)
                if tog==2 
                   pair1Position=1000/(adjcls(end-30+ctr,1));
                   pair2Position=hedgeRatio*pair1Position;
                   getPnL = pair1Position * (adjcls(end-30+ctr,1) - adjcls(end-30+enteridx,1)) + pair2Position * (adjcls(end-30+enteridx,2) - adjcls(end-30+ctr,2)); %Long pair1 and short pair2
                else
                   getPnL = pair1Position * (adjcls(end-30+enteridx,1)- adjcls(end-30+ctr,1)) + pair2Position * (adjcls(end-30+ctr,2) - adjcls(end-30+enteridx,2));
                end 
                if getPnL>0
                    win=win+1;
                end
                pnl=pnl+getPnL;
                if (zscr(ctr-1,1) > 0 && zscr(ctr,1) < 0)||(zscr(ctr-1,1)<0 && zscr(ctr,1) >0)
                   cross=cross+1; 
                   tog=0;
                   daymkt=daymkt+ctr-enteridx; %have to define enteridx
                end
            else
                if (zscr(ctr-1,1) >= band) && (zscr(ctr,1) < band) %if price go down cross shortthreshold, then short
                    tog = 1;         
                    entryidx = ctr;
                    sells=sells+1;
                elseif (zscr(ctr-1,1) <= rand) && (zscr(ctr,1) > -rand); %if price go up cross longthreshold, then long
                    buys=buys+1;
                    tog=2;
                    entryidx = ctr;
                else
                end 
            end
       
        end
        

    