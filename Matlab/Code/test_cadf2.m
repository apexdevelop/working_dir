
 function [best_adf,best_P,best_ind]=test_cadf2(r1)
  
  [h,pValue,stat,cValue,reg]=adftest(r1,'model','ARD','Lags',0:10);
   %[h0,pValue0,stat0,cValue0,reg0] = egcitest(adjcls,'test','t1','creg','ct');
  [best_adf,best_ind]=min(stat);
  best_P=pValue(best_ind);
  best_ind=best_ind-1;
 end