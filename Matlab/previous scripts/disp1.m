function dispout = disp1(s, volterm)
clear;
load codata
%% Check if the weights add up to 1
cvar2=0;
for cvar1=1:size(weight,1)
    cvar2=cvar2+weight(cvar1,1);
end
    if(cvar2~=1)
      str1='problem'
    end
 
%% Calculate return the price data needs to be transpose
%%for var1=1:size(num,2)
  %%  for var2=0:s-1
 %%   num2(s-var2,var1)=num(var2+1,var1);
 %%   end
%% end


for var3=1:size(num,2)
    for var4=0:s-1
      rtnum(s-var4,var3)=log(num(var4+1,var3))-log(num(var4+2,var3));
      check1=isnan(rtnum(s-var4,var3));
      check2=isinf(rtnum(s-var4,var3));  
      if(check1==1 || check2==1)
            rtnum(s-var4,var3)= 0 ; 
        end
    end
end


%% Calculate Volatility
for var5=1:size(rtnum,2)
    for var6=0:s-volterm
    vol(volterm+var6,var5)=std(rtnum(var6+1:var6+volterm,var5))*sqrt(260);
    end
end
%% calculate index rtn and vol

irtnum=rtnum*weight; 


for var11=0:s-volterm
    ivol(volterm+var11,1)=std(irtnum(var11+1:var11+volterm,1))*sqrt(260);
end

%% Calculate Implied Correlation
for var12=volterm:s
    
    running1=0;
    for var13=1:size(rtnum,2)
        running1=running1+weight(var13,1)^2*vol(var12,var13)^2;
    end

    running3=0;
    for var14=1:size(rtnum,2)-1
        running2=0;
        for var15=var14+1:size(rtnum,2)
            running2=running2+weight(var14,1)*weight(var15,1)*vol(var12, var14)*vol(var12,var15);
        end
        running3=running3+running2;
    end

    hc(var12,1)= (ivol(var12,1)^2-running1)/(2*running3);
        
end

%% calculate percenitle,qunitle,max-min, absrtn based
hc(:,2)=prctile(rtnum',75)'-prctile(rtnum',25)';
hc(:,3)=prctile(rtnum',90)'-prctile(rtnum',10)';
hc(:,4)=max(rtnum')'-min(rtnum')';
hc(:,5)=mean(rtnum')';
plot(hc(volterm:end,1), 'DisplayName', 'hc(volterm:end,1)', 'YDataSource', 'hc(volterm:end,1)'); figure(gcf)
dispout=hc;