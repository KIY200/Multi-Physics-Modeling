clc;clear;close all;
%% Iteration script for wave propagation model
T=[1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5];
Mod_values = 1000*[1.7,-0.15,0.18,0.43,0.0001,0.7,0.8,1.1,1];
B_ref = 350;
k = Mod_values/B_ref;

% load('lupadata_spring2024_sparD1_14m.mat');
% w = 2*pi*1./T;
% [hydro.float_mass, ...
%     hydro.float_added_mass,...
%     hydro.float_damping, ...
%     hydro.float_stiffness, ...
%     hydro.spar_mass, ...
%     hydro.spar_added_mass,...
%     hydro.spar_damping, ...
%     hydro.spar_stiffness] = fn_get_lupa_params(w,lupadata);

for ii = 1:9
wave_period = T(ii);
% damping_mod = Mod_values(ii);
k_mod = k(ii);
run("wec_array_init.mlx")
out=sim("wec_array.slx");
filename=sprintf("sim_out/delay_T%d.mat",T(ii)*100);
save(filename,"out")
end

%% Data load
T=[1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5];
Target_RAO=[0.257, 0.986, 0.87, 0.847, 0.97, 0.879, 0.892, 0.887, 0.91];
RAO=zeros(9,3);
e_RAO=zeros(9,1);
for ii = 1:9
wave_period = T(ii);
filename=sprintf("sim_out/delay_T%d.mat",wave_period*100);
load(filename)
V_s_max = max(out.logsout{4}.Values);
V_WEC1_max = max(out.logsout{3}.Values);
RAO(ii,1)=wave_period;
RAO(ii,2)=V_WEC1_max/V_s_max;
e_RAO(ii) = abs(RAO(ii,2)-Target_RAO(ii));
end
RAO(:,3)=Target_RAO;

% Define figure properties
figure('Name', 'RAO and Friction Adjustment Factor', 'NumberTitle', 'off', ...
       'Units', 'normalized', 'Position', [0.2, 0.2, 0.6, 0.6]);

% Define common properties
markerSize = 8;
fontSize = 20;
labelFontSize = 24;
lineWidth = 1.5;

% Subplot 1: RAO Comparison
subplot(2, 1, 1);
hold on;
plot(RAO(:,1), RAO(:,2), 'o', 'MarkerSize', markerSize, 'MarkerEdgeColor', 'b', 'LineStyle', 'none', 'DisplayName', 'Estimated RAO');
plot(RAO(:,1), RAO(:,3), 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', 'r', 'LineStyle', 'none', 'DisplayName', 'Target RAO');
hold off;
grid on;
xlabel('Period (s)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
ylabel('RAO (m/m)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
title('Response Amplitude Operator (RAO) Comparison', 'FontWeight', 'bold', 'FontSize', labelFontSize);
legend('Location', 'best', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize, 'LineWidth', lineWidth);

% Subplot 2: Friction Adjustment Factor
subplot(2, 1, 2);
plot(T, k, '^-', 'MarkerSize', markerSize, 'MarkerEdgeColor', 'g', 'LineWidth', lineWidth, 'DisplayName', 'Friction Adjustment Factor');
grid on;
xlabel('Period (s)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
ylabel('Factor', 'FontWeight', 'bold', 'FontSize', labelFontSize);
title('Friction Adjustment Factor vs. Period', 'FontWeight', 'bold', 'FontSize', labelFontSize);
legend('Location', 'best', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize, 'LineWidth', lineWidth);

openfig("FloatHeaveRAOOneBodyHeaveOnlyExpTNumBEMEqCkt_20250122.fig")
grid on;
xlabel('Period (s)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
ylabel('RAO (m/m)', 'FontWeight', 'bold', 'FontSize', labelFontSize);
title('Response Amplitude Operator (RAO) Comparison', 'FontWeight', 'bold', 'FontSize', labelFontSize);
legend('Location', 'best', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize, 'LineWidth', lineWidth);

avg_error = mean(e_RAO);