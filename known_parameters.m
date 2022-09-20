simulate_battery

current_noise = 1e-2;
voltage_noise = 1e-2;
Nruns         = 1;
xk            = Current.scaled_soc; % true state

% EKF priors:
x0_hat     = Current.intial_soc;           % initial state estimate
dt         = I.sampling_period;           % sampling period
epsilon    = Current.scaling_factor;       % soc scaling parameter
C_batt     = Current.capacity;             % battery total capacity
eta        = Current.coulombic_efficiency; % coulombic effciency
R0         = Voltage.R0;                   % internal resistance
ocv_params = Voltage.ocv_params;           % open circuit voltage curve parameters

% mean squared error memory allocation:
MSE.EKF     = zeros(size(xk));
MSE.current = zeros(size(xk));
MSE.voltage = zeros(size(xk));

for n = 1:Nruns
    fprintf('%d/%d \n', n,Nruns)

    % simulate current and voltage measurements:
    zk_i = current_based_soc.add_noise(I.current, current_noise);
    zk_v = voltage_based_soc.add_noise(Voltage.terminal, voltage_noise);

    % ekf-based soc estimation error: 
    [soc_est.EKF, Pk] = EKF_based_soc(x0_hat, zk_i, zk_v, current_noise, ...
        voltage_noise, eta, dt, C_batt, R0, epsilon, ocv_params); 
    MSE.EKF =  MSE.EKF + (xk-soc_est.EKF).^2;

    % current-based soc estimation error:
    CC = current_based_soc(zk_i, I.time, intial_soc=x0_hat);
    soc_est.current = CC.scaled_soc; 
    MSE.current = MSE.current + (xk-soc_est.current).^2;

    % voltage-based soc estimation error:
    zk_ocv = zk_v - (R0*zk_i); 
    soc_est.voltage = voltage_based_soc.SOC_lookup(0.01, epsilon, ...
        ocv_params, zk_ocv); 
    MSE.voltage = MSE.voltage + (xk - soc_est.voltage).^2;
   
end
clear n 
%%


% figure
% hold on
% plot(I.time,  Current.scaled_soc, DisplayName='True')
% plot(I.time,  soc_current, DisplayName='current-based')
% plot(I.time,  soc_voltage, DisplayName='voltage-based')
% plot(I.time,  xk_hat, DisplayName='EKF')
% legend show
% axis("padded")
% ylabel('Error')
% xlabel('Time (s)')

figure
plot(I.time,  sqrt(MSE.current/Nruns), DisplayName='current-based')
hold on
plot(I.time,  sqrt(MSE.voltage /Nruns), DisplayName='voltage-based')
plot(I.time,  sqrt(MSE.EKF/Nruns), DisplayName='EKF')
legend show
ylabel('Error deviation')
xlabel('Time (s)')



