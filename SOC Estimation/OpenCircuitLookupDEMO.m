addpath("../", "../Functions/"); 
BatteryDEMO;

% EXPERIMENT PARAMETERS:
Nruns          = 100; 
voltage_noise  = 1e-3; % voltage sensor noise
current_noise  = 1e-3; % current sensor noise

% KNOWN VALUES:
R0         = ECM.R0;                 % internal resistance
epsilon    = Battery.scaling_factor; % soc scaling parameter
ocv_params = ECM.ocv_params;         % open circuit voltage curve parameters

% SIMULATED VARIANCE:
variance_sim = zeros(size(ECM.scaled_soc));
for n = 1:Nruns
    fprintf('%d/%d \n', n,Nruns)
    % simulate noisy current and voltage measurements:
    zk_i = coulomb_counting.add_noise(I.current, current_noise);
    zk_v = ECM.add_noise(ECM.terminal_voltage, voltage_noise);
    % voltage-based soc estimation:
    zk_ocv = zk_v - (R0*zk_i); % open-circuit voltage
    xk_ocv = ECM.soc_lookup(0.01, epsilon, ocv_params, zk_ocv);
    variance_sim = variance_sim + (ECM.scaled_soc - xk_ocv).^2;
end
xk_ocv = soc_scaling(xk_ocv, epsilon, 'backward'); 

% THEORETICAL VARIANCE:
variance_theory =  ECM.theoretical_variance(ECM.scaled_soc, R0, ocv_params, ...
                current_noise, voltage_noise);

%% PLOT: 
figure(Units=Ploty.Units, Position=Ploty.Position); 
hold on; box on; grid on;
plot(I.time/(60*60), sqrt(variance_sim/Nruns), 'k--',  LineWidth=Ploty.LineWidth, DisplayName='Simulation')
plot(I.time/(60*60), sqrt(variance_theory), 'r-', LineWidth=Ploty.LineWidth, DisplayName='Theory')
ylabel('Standard error'); xlabel('Time (h)'); ylim([-1e-3 5e-3])
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)

figure(Units=Ploty.Units, Position=Ploty.Position); 
hold on; box on; grid on;
plot(I.time/(60*60), Battery.soc, 'k-',  LineWidth=Ploty.LineWidth, DisplayName='True')
plot(I.time/(60*60), xk_ocv, 'r--', LineWidth=Ploty.LineWidth, DisplayName='OCV-SOC lookup')
ylabel('SOC'); xlabel('Time (h)'); 
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)