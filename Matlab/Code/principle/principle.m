% http://www.mathworks.com/help/stats/quality-of-life-in-u-s-cities.html
load cities
categories
figure()
boxplot(ratings,'orientation','horizontal','labels',categories)
C = corr(ratings,ratings);
w = 1./var(ratings);
[wcoeff,score,latent,tsquared,explained] = pca(ratings,...
'VariableWeights',w);

% Or equivalently:
% 
% [wcoeff,score,latent,tsquared,explained] = pca(ratings,...
% 'VariableWeights','variance');

c3 = wcoeff(:,1:3);

coefforth = diag(sqrt(w))*wcoeff;
% coefforth = inv(diag(std(ratings)))*wcoeff;
cscores = zscore(ratings)*coefforth;

figure()
plot(score(:,1),score(:,2),'+')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

% gname
metro = [43 65 179 213 234 270 314];
names(metro,:)

figure()
pareto(explained)
xlabel('Principal Component')
ylabel('Variance Explained (%)')

[st2,index] = sort(tsquared,'descend'); % sort in descending order
extreme = index(1);
names(extreme,:)

biplot(coefforth(:,1:2),'scores',score(:,1:2),'varlabels',categories);
axis([-.26 0.6 -.51 .51]);