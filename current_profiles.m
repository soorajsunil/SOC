clc; clear; close all; 

sampling_period = 0.1; % in secs 
sample_duration = 100;  % total duration in secs

Battery = battery_simulator(sampling_period, sample_duration);

tiledlayout('flow')
tk = Battery.time; 

nexttile
ik = Battery.constant_charge(); 
plot(tk, ik, 'b-')
title('constant current charging')
xlabel('Time (s)'); ylabel('Current (A)')

nexttile
ik = Battery.pulse_charge(); 
plot(tk, ik, 'b-')
title('pulsed current charging')
xlabel('Time (s)'); ylabel('Current (A)')

nexttile
ik = Battery.charge_and_discharge();
hold on
plot(tk, ik, 'k-')
title('pulsed current charging-discharging')
xlabel('Time (s)'); ylabel('Current (A)')

nexttile
ik = Battery.constant_discharge(); 
plot(tk, ik, 'r-')
title('constant discharging')
xlabel('Time (s)'); ylabel('Current (A)')

nexttile
ik = Battery.pulse_discharge(); 
plot(tk, ik, 'r-')
title('pulsed current discharging')
xlabel('Time (s)'); ylabel('Current (A)')

nexttile
ik = Battery.random_discharge();
plot(tk, ik, 'r-')
title('random current discharging')
xlabel('Time (s)'); ylabel('Current (A)')

