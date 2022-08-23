clc; clear; close all;
addpath("utls/")

% simulate current
I  = current_simulator(sampling_period=0.1, charge_pattern='pulse');
I.plot

% simulate soc
Battery = battery_simulator(I.current, I.time, intial_soc=0.5);
Battery.plot_soc

