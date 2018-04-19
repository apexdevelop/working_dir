%-------------------------------------------------------------------------
% Compute the statistic:
function [testStat,testPValue] = getStat(i,testT,testLags,testModel,testType,testReg,sigLevels,sampSizes,CVTable,needPValue)

beta = testReg.coeff;
Cov = testReg.Cov;
aId = strncmp('a',testReg.names,1);
a = beta(aId);
bId = strncmp('b',testReg.names,1);
b = beta(bId);
se = sqrt(diag(Cov));
se_a = se(aId);
        
switch upper(testType)
    
    case 'T1'

        testStat = (a-1)/se_a;
         
    case 'T2'

        testStat = testT*(a-1)/(1-sum(b));
        
    case 'F'
        
        % Follows Hamilton [5] pp.521-527.
        %        
        % Restrictions of the form:
        % R*(beta-beta0) = R*beta - R*beta0
        %                = R*beta - r
        %                = 0
        switch upper(testModel)
                       
            case 'ARD'
                
                R = [eye(2),zeros(2,testLags)];
                beta0 = [0;1;zeros(testLags,1)];
                
            case 'TS'
                
                R = [zeros(2,1),eye(2),zeros(2,testLags)];
                beta0 = [0;0;1;zeros(testLags,1)];
                
        end
        
        % The inverse in the Wald form of the test statistic is replaced
        % with a more efficient computation using Cholesky factorization
        % and triangular backsolve:
        %
        % U = chol(R*Cov*R')
        % u = R*(beta-beta0)
        % testStat = (u'*inv(R*Cov*R')*u)/2
        %          = (u'*inv(U'*U)*u)/2
        %          = (u'*inv(U)*inv(U')*u)/2
        %          = ((u'/U)*(U'\u))/2
        %          = (v'*v)/2
        % where v = U'\u.
        
        U = chol(R*Cov*R');
        u = R*(beta-beta0);
        v = U'\u;
        testStat = (v'*v)/2;
        
end