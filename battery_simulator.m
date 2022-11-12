clc; clear; close all; addpath("_utls/"); 

% simulate current: 
I = current_simulator(profile='pulse', amplitude=[1,-1], ...
    sampling_period=1, duration=(2*6840), frequency=1/(2*6840));

% model battery based on coulomb counting: 
Battery = coulomb_counting(I.current, I.time, intial_soc=0);

% equivalent circuit model of a battery: 
ECM = equivalent_circuit_model(Battery.scaled_soc, Battery.scaling_factor);
ECM = ECM.internal_resistance(I.current, 0.14); 

%% Plot
PLOTTY = my_plot();
figure(Units=PLOTTY.Units, Position=PLOTTY.Position + [0 0 -2 8]); 
tiledlayout(3,1)
nexttile
hold on; box on;grid on;
plot(I.time/(60*60), I.current, LineWidth=PLOTTY.LineWidth)
ylabel('Current (A)')
xlabel('Time (h)')
axis('padded')
set(gca, Fontsize=PLOTTY.FontSize, FontName=PLOTTY.FontName)
nexttile
hold on; box on;grid on;
plot(I.time/(60*60), Battery.soc,LineWidth=PLOTTY.LineWidth)
ylabel('SOC')
xlabel('Time (h)')
set(gca, Fontsize=PLOTTY.FontSize, FontName=PLOTTY.FontName)
nexttile
hold on; box on;grid on;
plot(ECM.soc, ECM.open_circuit_voltage, LineWidth=PLOTTY.LineWidth)
ylabel('OCV (V)')
xlabel('SOC')
axis('padded')
set(gca, Fontsize=PLOTTY.FontSize, FontName=PLOTTY.FontName)