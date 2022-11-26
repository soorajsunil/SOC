addpath("../", "../Functions/"); BatteryDEMO; 
% close all;

% EXPERIMENT PARAMETERS:
current_noise = 1e-3;
voltage_noise = 1e-3;
Nruns         = 100;

% TRUE SYSTEM (FOR REFERENCE):
sk = Battery.soc;
xk = Battery.scaled_soc;
ik = I.current;
tk = I.time;
vk = ECM.terminal_voltage;

% ASSUMED KNOWN:
dt         = I.sampling_period;
xk0        = Battery.intial_soc;
epsilon    = Battery.scaling_factor;
Qc         = Battery.capacity;
eta        = Battery.efficiency;
R0         = ECM.R0;             % internal resistance
ocv_params = ECM.ocv_params;     % open circuit voltage curve parameters

% MSE:
mse_cc  = zeros(size(sk));
mse_ocv = zeros(size(xk));
mse_ekf = zeros(size(xk));

for n = 1:Nruns
    fprintf('%d/%d \n', n,Nruns)

    % ADD GAUSSIAN NOISE TO MEASUREMENTS:
    zk_i = coulomb_counting.add_noise(ik, current_noise);
    zk_v = ECM.add_noise(vk, voltage_noise);

    % COULOMB COUNTING:
    xk_cc  = coulomb_counting(zk_i, tk, intial_soc=xk0);
    mse_cc = mse_cc + (sk-xk_cc.soc).^2;

    % OPEN-CIRCUIT LOOKUP:
    zk_ocv = zk_v - (R0*zk_i); % ocv
    xk_ocv = ECM.soc_lookup(0.01, epsilon, ocv_params, zk_ocv);

    mse_ocv= mse_ocv + (xk - xk_ocv).^2;

    % EXTENDED KALMAN FILTER:
    [xk_ekf, Pk] = EKF(xk0, zk_i, zk_v, current_noise, voltage_noise, ...
        eta, dt, Qc, R0, epsilon, ocv_params);

    mse_ekf = mse_ekf + (xk - xk_ekf).^2;
end

% PLOT:

tk_h    = I.time/(60*60);                  
var_cc  = xk_cc.theoretical_variance(current_noise);
var_ocv = ECM.theoretical_variance(ECM.scaled_soc, R0, ocv_params, ...
    current_noise, voltage_noise);
figure(Units=Ploty.Units, Position=Ploty.Position + [0,0,1,1]);
hold on; box on; grid on;
plot(tk_h,sqrt(mse_cc/Nruns),'--', LineWidth=Ploty.LineWidth, DisplayName='Simulation (coulomb counting)')
plot(tk_h,sqrt(var_cc), '-',  LineWidth=Ploty.LineWidth, DisplayName='Theory (coulomb counting)')
plot(tk_h,sqrt(mse_ocv/Nruns), '--', LineWidth=Ploty.LineWidth, DisplayName='Simulation (OCV lookup)')
plot(tk_h,sqrt(var_ocv), '-',  LineWidth=Ploty.LineWidth, DisplayName='Theory (OCV lookup)')
plot(tk_h,sqrt(mse_ekf/Nruns),'--', LineWidth=Ploty.LineWidth, DisplayName='Simulation (EKF)')
plot(tk_h,sqrt(squeeze(Pk)), '-', LineWidth=Ploty.LineWidth, DisplayName='Estimated (EKF)')
ylabel('Error deviation'); xlabel('Time (h)');
legend(Visible="on",NumColumns=2)
ylim([-0.00001, 0.0032]);
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)

xk_ocv = soc_scaling(xk_ocv,epsilon,'backward');
xk_ekf  = soc_scaling(xk_ekf,epsilon,'backward');
figure(Units=Ploty.Units, Position=Ploty.Position);
hold on; box on; grid on;
plot(tk_h, sk, '-',  LineWidth=Ploty.LineWidth, DisplayName='True')
plot(tk_h, xk_cc.soc, '-', LineWidth=Ploty.LineWidth, DisplayName='Coulomb counting')
plot(tk_h, xk_ocv, '-', LineWidth=Ploty.LineWidth, DisplayName='OCV lookup')
plot(tk_h, xk_ekf, '-', LineWidth=Ploty.LineWidth, DisplayName='EKF')
ylabel('SOC'); xlabel('Time (h)');
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)
