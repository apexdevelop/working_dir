load Data_MarkPound
Y = Data;
r = price2ret(Y);
N = length(r);

% figure
% plot(r)
% xlim([0,N])
% title('Mark-Pound Exchange Rate Returns')

autocorr(r);
parcorr(r);