
%Simulation and Forecasting

numSteps = 10;
 
% Preallocate:
YSim = zeros(numSteps,numDims);
eps = zeros(numSteps,numDims);
 
% Specify q+1 presample values:
YSim(1,:) = Y(end-2,:);
YSim(2,:) = Y(end-1,:);
YSim(3,:) = Y(end,:);
 
% Simulate numSteps postsample values:
for t = 4:numSteps+3
    
    eps(t,:) = mvnrnd([0 0 0],EstCov,1); % Normal innovations
 
    YSim(t,:) = YSim(t-1,:) ...
                + YSim(t-1,:)*[1;-b]*a'...
                + (YSim(t-1,:)-YSim(t-2,:))*B1'...
                + (YSim(t-2,:)-YSim(t-3,:))*B2'...
                + (a*c0 + c1)'...
                + eps(t,:);
 
end
 
% Plot sample and forecast path:
plot(dates,Y,'LineWidth',2)
xlabel('Year')
ylabel('Percent')
title('{\bf Forecast Path}')
hold on
D = dates(end);
plot(D:(D+numSteps),YSim(3:end,:),'-.','LineWidth',2)
Ym = min([Y(:);YSim(:)]);
YM = max([Y(:);YSim(:)]);
fill([D D D+numSteps D+numSteps],[Ym YM YM Ym],'b','FaceAlpha',0.1)
axis tight
grid on
hold off
