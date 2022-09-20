addpath("utls/")
clc; clear; close all;

% simulate current: 
I = current_simulator(profile='random', amplitude=-1.5, ...
    duration=180, frequency=1e-3);

% model "true soc" using coulomb counting: 
Current = current_based_soc(I.current, I.time, intial_soc=0.5);

% simulate terminal voltage based on "scaled true soc": 
Voltage  = voltage_based_soc(Current.scaled_soc);
Voltage  = Voltage.R_int(I.current, 0.1); 

%%
figure; 
subplot(311)
plot(I.time, I.current)
ylabel('Current (A)')
axis('padded')

subplot(312)
plot(I.time, Voltage.terminal)
ylabel('Voltage (V)')
xlabel('Time (s)')
axis('padded')

subplot(313)
plot(I.time, Current.soc)
ylabel('SOC')



