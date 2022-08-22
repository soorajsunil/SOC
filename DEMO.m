clc; clear; close all; 

% select process model 
[process_model, Q] = process_selector('simple'); 

% select measurement model 
[measurement_model, R] = measurement_selector('Rint'); 

% simulate current 
dt = 0.1;                   % sampling period in secs 
I  = current_simulator(dt);
I  = I.pulse;                % {I.pulse, I.constant, I.alternate_pulse}

% simulate state of charge (using process model)  
SOC      = zeros(size(I.samples)); 
SOC(:,1) = soc_scaling(0.5, 'forward'); % intial soc
epsilon  =  0.175;                      % soc scaling paramter
eta      = 1; 
Cbatt    = 1.9*3600;                    % battery capacity in Ah

for k = 2:I.sample_length
    SOC(:,k) = process_model(SOC(:,k-1), epsilon, eta, Cbatt, dt, I.samples(:,k-1));
end 
clear k 

% simulate voltage (using measurement model) 
R0  = 0.2; 
OCV = cp3(SOC); 
V   = measurement_model(OCV, I.samples, R0);

% simulate noisy sensor measurements
current_noise = 1e-4; % process noise deviation
voltage_noise = 1e-2; % measurement noise deviation

zI  = I.samples + current_noise*randn(size(I.samples)); 
zV  = V         + voltage_noise*randn(size(V));







% % Simulate current pulse: 

% 
% % % Simulate state of charge based on coloumb counting: 

% soc        = soc_process_model(I.samples, Cbatt, dt, epsilon, intial_soc); 
%  
% % % simulate measurements using Rint model: 

% 

% % Apply EKF 
% [xhat, Phat] = EKF_SOC(zV, zI, noise, Params); 
% 
% % % Backward scaling: 
% soc  = soc_scaling(soc,'Backward'); 
% xhat = soc_scaling(xhat,'Backward'); 
% 
% % % Plotting parameters: 
% sqError = (soc-xhat).^2; % squared error 
% tk      = I.time/(60*60);   % time in hours
% 
% plot(tk, soc)
% hold on 
% plot(tk,xhat, '--')
% 
