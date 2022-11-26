function [Jk] = FIM(xk, C_batt, epsilon, eta, dt, R0, ocv_params, sigma_i, sigma_v)

eq = Rint_equations(); 
R  = eq.R(sigma_i, sigma_v, R0);

Jk        = zeros(1,1,numel(xk)); % info matrix
Jk(:,:,1) = 1/(1e-4); % intial 

% pcrlb recursion
for k = 2:numel(xk)
    Hk = eq.H(xk(:,k), ocv_params);
    Qk = eq.Q(C_batt, eta(:,k-1), epsilon, dt, sigma_i);
  
    D11 = 1/Qk;
    D12 = -(1/Qk);
    D21 = D12'; 
    D22 = (1/Qk) + Hk'*(1/R)*Hk; 

    Jk(:,:,k) = D22 - D21*(inv(Jk(:,:,k-1)+D11))*D12; 
end

end



