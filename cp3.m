function [ocv, kocv] = cp3(soc)

% OCV characterization using "combined +3" model
% [1]. Pattipati, B., Balasingam, B., Avvari, G. V., Pattipati,
% K. R., & Bar-Shalom, Y. (2014). Open circuit voltage characterization
% of lithium-ion batteries. Journal of Power Sources, 269, 317-333.

% curve parameters (offline)
k0    = -9.082;
k1    = 103.087;
k2    = -18.185;   
k3    = 2.062;
k4    = -0.102;
k5    = -76.604;
k6    = 141.199; 
k7    = -1.117;
kocv  = [k0; k1; k2; k3; k4; k5; k6; k7]; % return parameters 

ocv = k0 + k1.*(1./soc) + k2.*(1./(soc.^2)) ...
    + k3.*(1./(soc.^3)) + k4.*(1./(soc.^4)) ...
    + k5.*soc + k6.*(log(soc)) + k7.*(log(1-soc));






