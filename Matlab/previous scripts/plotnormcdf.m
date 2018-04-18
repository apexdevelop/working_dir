mu = 0;
sd = 10;
ix = -3*sd:1e-3:3*sd; %covers more than 99% of the curve
iy = pdf('normal', ix, mu, sd);
lim=length(iy);
plot(ix,iy,'LineStyle','--');
hold on;
line([mu mu],[0 iy((lim+1)/2)],'LineStyle','--','LineWidth',2);
mu1=10;
ix1=-3*sd+mu1:1e-3:3*sd+mu1;
iy1 = pdf('normal', ix1, mu1, sd);
plot(ix1,iy1);
line([mu1 mu1],[0 iy1((lim+1)/2)],'LineWidth',2);
legend('Original Distribution','Original Mean','Improved Distribution','Improved Mean','Location','NW')
xlabel('Impact');
ylabel('Probability');