addpath("../", "../Functions/"); BatteryDEMO; 
% close all;

% EXPERIMENT PARAMETERS:
Nruns         = 100;   % total runs
current_noise = 1e-3; % current sensor noise
 
% KNOWN VALUES:
xk0 = Battery.intial_soc; 
Qc  = Battery.capacity;  % true battery capacity 

% SIMULATED VARIANCE:
variance_sim = zeros(size(Battery.soc));
for n =1:Nruns
    fprintf('%d/%d \n',n,Nruns)
    % simulate noisy current measurements: 
    zk_i = Battery.add_noise(I.current, current_noise);
    % coulomb couting soc estimation:
    xk_cc = coulomb_counting(zk_i, I.time, intial_soc=xk0, capacity=Qc);
    variance_sim = variance_sim + (Battery.soc-xk_cc.soc).^2;
end

% THEORETICAL VARIANCE:
variance_theory = xk_cc.theoretical_variance(current_noise); 

%% PLOT: 
figure(Units=Ploty.Units, Position=Ploty.Position); 
hold on; box on; grid on;
plot(I.time/(60*60), sqrt(variance_theory), 'r-', LineWidth=Ploty.LineWidth, DisplayName='Theory')
plot(I.time/(60*60), sqrt(variance_sim/Nruns), 'k--',  LineWidth=Ploty.LineWidth, DisplayName='Simulation')
ylabel('Standard error'); xlabel('Time (h)'); 
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)

figure(Units=Ploty.Units, Position=Ploty.Position); 
hold on; box on; grid on;
plot(I.time/(60*60), Battery.soc, 'k-',  LineWidth=Ploty.LineWidth, DisplayName='True')
plot(I.time/(60*60), xk_cc.soc, 'r--', LineWidth=Ploty.LineWidth, DisplayName='Coulomb counting')
ylabel('SOC'); xlabel('Time (h)'); 
legend(Visible="on",Location="best")
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)