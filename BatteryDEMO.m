addpath("Functions/"); clc; clear; close all; 

% CURRENT PROFILE SIMULATION:
I = current_simulator(profile='pulse', amplitude=[0.1,-0.1], ...
    sampling_period=60, duration= 10*(2*3*3600), frequency=1/(10*2*3*3600));

% BATTERY CHARACTERISTICS BASED ON COULOMB COUNTING: 
Battery = coulomb_counting(I.current, I.time, intial_soc=0);

% BATTERY EQUIVALENT CIRCUIT MODELING: 
ECM = equivalent_circuit(Battery.scaled_soc, Battery.scaling_factor);
ECM = ECM.internal_resistance(I.current, 0.14); 

%% PLOT:
Ploty = my_plot(); 
figure(Units=Ploty.Units, Position=Ploty.Position+[0,0,0,8]); 
tiledlayout(3,1)
nexttile; hold on; box on;grid on;
plot(I.time/(60*60), I.current, LineWidth=Ploty.LineWidth)
ylabel('Current (A)'); xlabel('Time (h)'); axis('padded')
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)

nexttile; hold on; box on;grid on;
plot(I.time/(60*60), Battery.soc,LineWidth=Ploty.LineWidth)
ylabel('SOC'); xlabel('Time (h)')
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)

nexttile; hold on; box on;grid on;
plot(ECM.soc, ECM.open_circuit_voltage, LineWidth=Ploty.LineWidth)
ylabel('OCV (V)'); xlabel('SOC'); axis('padded')
set(gca, Fontsize=Ploty.FontSize, FontName=Ploty.FontName)