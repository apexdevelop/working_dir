cd('C:\Documents and Settings\nthakkar.AC\My Documents');
clear H;
clear P;
clear S;
clear Y;
clear tday;
clear tday_str;
clear tday_final;

[names btxt bbpx]=blp_simple('input_ticker','proxy','b1:b2',200);

n_stock=size(bbpx,2)-1;
n_t=size(bbpx,1);

jci_ccn;

%vec;
