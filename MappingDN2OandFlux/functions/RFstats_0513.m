function stats = RFstats(Mdl, train, target, varargin)

A.oob = 1;

varargin=parse_pv_pairs(A,varargin);

% predict
Yhat = predict(Mdl,train)';
% R2
R = corrcoef(Yhat,target); stats.R2 = R(2,1).^2;
%RMSE
stats.RMSE = immse(Yhat,target)^0.5;
if A.oob
    % predict
    stats.oobYhat = oobPredict(Mdl)';
    % R2
    oobR = corrcoef(stats.oobYhat,target); stats.oobR2 = oobR(2,1).^2;
    %RMSE
    stats.oobRMSE = immse(stats.oobYhat,target)^0.5;
end
