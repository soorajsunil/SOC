function [eq] = Rint_equations()

% state space equations for simple internal resistance (Rint) model 
eq.process = @(soc_mk1, zi_mk1, C_batt, epsilon, eta, dt) ...
    soc_mk1 + (1-2*epsilon)*(eta)*(dt*zi_mk1)/C_batt;

eq.measurement = @(OCV, I, R0) OCV + I*R0;

eq.h = @(soc, ocv_params) ...
    ocv_params(1) + ocv_params(2)*(1/soc) + ocv_params(3)*(1/(soc^2)) + ...
    ocv_params(4)*(1/(soc^3)) + ocv_params(5)*(1/(soc^4)) + ...
    ocv_params(6)*soc + ocv_params(7)*(log(soc)) + ...
    ocv_params(8)*(log(1-soc));

eq.H = @(xpred, ocv_params) ...
    -ocv_params(2)*(xpred^(-2)) - 2*ocv_params(3)*(xpred^(-3)) - ...
    3*ocv_params(4)*(xpred^(-4)) - 4*ocv_params(5)*(xpred^(-5)) +  ...
    ocv_params(6)*ones(length(xpred),1) + ocv_params(7)/xpred - ...
    ocv_params(8)/(1-xpred);

eq.Q = @(C_batt, eta, epsilon, dt, current_noise) ...
    (1 - 2*epsilon)^2*(eta^2/C_batt^2)*(dt^2)*(current_noise^2);

eq.R = @(current_noise, voltage_noise, R0) ...
    R0*current_noise^2 + voltage_noise^2;

end
