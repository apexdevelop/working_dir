cd('C:\Documents and Settings\YChen\My Documents');
[res,~]=xlsread('input_ticker','res','a1:a70');
[h,pValue,stat,cValue] = lbqtest(res);