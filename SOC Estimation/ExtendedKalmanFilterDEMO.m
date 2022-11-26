addpath("../", "../Functions/"); BatteryDEMO; 
% close all;

% EXPERIMENT PARAMETERS:
current_noise = [1e-3];
voltage_noise = [1e-3];
Nruns         = 100;

% ASSUMED KNOWN:
dt         = I.sampling_period;
xk0        = Battery.intial_soc;
epsilon    = Battery.scaling_factor;
Qc         = Battery.capacity;
eta        = Battery.efficiency;
R0         = ECM.R0;
ocv_params = ECM.ocv_params;

% MSE:
xk    = Battery.scaled_soc; % true state
mse   = zeros(size(xk));
pcrlb = zeros(1,1,numel(xk));

figure(Units=Ploty.Units, Position=Ploty.Position +[0,0,0,1]);
hold on; box on; grid on;
for i = 1:length(current_noise)
    for n = 1:Nruns
        fprintf('%d/%d \n', n,Nruns)
        % ADD GAUSSIAN NOISE TO MEASUREMENTS:
        zk_i = Battery.add_noise(I.current, current_noise(i));
        zk_v = ECM.add_noise(ECM.terminal_voltage, voltage_noise(i));
        % EXTENDED KALMAN FILTER:
        [xk_ekf, Pk] = EKF(xk0, zk_i, zk_v, current_noise(i), ...
            voltage_noise(i), eta, dt, Qc, R0, epsilon, ocv_params);
        mse = mse + (xk - xk_ekf).^2;
        % CRAMER RAO LOWER BOUND
        xk_cc = coulomb_counting(zk_i, I.time, intial_soc=xk0); % noise state
        Jk = FIM(xk_cc.scaled_soc, Qc, epsilon, eta, dt, R0, ocv_params, ...
            current_noise(i), voltage_noise(i));
        pcrlb = pcrlb + (1/Jk);
    end
    plot(I.time/(60*60), sqrt(squeeze(pcrlb)/Nruns), '-', Color=Ploty.color{i}, LineWidth=Ploty.LineWidth, DisplayName=['PCRLB (\sigma_i = ' num2str(current_noise(i)) ' A, \sigma_v = ' num2str(voltage_noise(i)) ' V)'])
    plot(I.time/(60*60), sqrt(squeeze(Pk)), '--',Color=Ploty.color{i},  LineWidth=Ploty.LineWidth, DisplayName=['EKF estimated (\sigma_i = ' num2str(current_noise(i))  ' A, \sigma_v = ' num2str(voltage_noise(i)) ' V)'])
    plot(I.time/(60*60), sqrt(mse/Nruns), '-.',Color=Ploty.color{i},  LineWidth=Ploty.LineWidth, DisplayName=['Simulation (\sigma_i = ' num2str(current_noise(i)) ' A, \sigma_v = ' num2str(voltage_noise(i)) ' V)'])
end
xlabel('Time (h)')
ylabel('Standard error')
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)
ylim([0 0.0018])

figure(Units=Ploty.Units, Position=Ploty.Position);
soc_hat = soc_scaling(xk_ekf, epsilon, 'backward');
hold on; box on; grid on;
plot(I.time/(60*60), Battery.soc, 'k-',  LineWidth=Ploty.LineWidth, DisplayName='True')
plot(I.time/(60*60), soc_hat, 'r--', LineWidth=Ploty.LineWidth, DisplayName='EKF')
ylabel('SOC'); xlabel('Time (h)');
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)