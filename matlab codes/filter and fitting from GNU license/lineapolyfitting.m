function [fitresult,gof] = lineapolyfitting(x,y)
%linearfitting1 fitting linear

[xData, yData] = prepareCurveData(x,y);
% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( ft );
opts.Lower = [-Inf -Inf];
opts.Upper = [Inf Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end

