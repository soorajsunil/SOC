function [xk_hat, Pk] = EKF(x0_hat, zk_i, zk_v, sigma_i, sigma_v, eta, dt, C_batt, R0, epsilon, ocv_params)

min_scaled_soc = epsilon;
max_scaled_soc = 1-epsilon;

% EKF memory allocation:
xk_hat  = zeros(size(zk_i));          % state estimate
Pk      = zeros(1,1,numel(xk_hat));   % state variance
eq      = Rint_equations();           % EKF system equations
R       = eq.R(sigma_i, sigma_v, R0); % time invariant measurement variance

% extended Kalman filter:
xk_hat(:,1) = soc_scaling(x0_hat, epsilon, 'forward'); % intial state estimate

%Q    = eq.Q(C_batt, eta(:,1), epsilon, dt, sigma_i);
Pk(:,:,1) = 1e-4; % intial state covariance

for k = 2:numel(xk_hat)
    % state prediction
    xpred = eq.process(xk_hat(:,k-1), zk_i(:,k), C_batt, epsilon, eta(:,k), dt);
    % measurement prediction
    OCV_pred = eq.h(xpred, ocv_params);
    zpred    = eq.measurement(OCV_pred, zk_i(:,k), R0);
    % residual/innovation
    inov = zk_v(:,k) - zpred;
    % state covariance prediction
    Q     = eq.Q(C_batt, eta(:,k), epsilon, dt, sigma_i);
    Ppred = Pk(:,:,k-1) + Q;
    % innovation covariance
    H  = eq.H(xpred, ocv_params);
    S = R + H*Ppred*H';
    % Kalman gain
    G = (Ppred*H')/S;
    % state and covariance update
    xk_hat(:,k) = xpred + G*inov;
    Pk(:,:,k) = (eye(size(Q,1))-G*H)*Ppred*(eye(size(Q,1))-G*H)' + G*R*G';
    % force estimates to be within the range of scaled soc
    if xk_hat(:,k) < min_scaled_soc
        xk_hat(:,k) = min_scaled_soc;
    elseif xk_hat(:,k) > max_scaled_soc
        xk_hat(:,k) = max_scaled_soc;
    end
end

end

