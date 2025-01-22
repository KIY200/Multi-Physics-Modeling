clc;clear;close all;

%% Iteration script for wave propagation model
for ii = 10:50
wave_period = 0.1*ii;
run("wec_array_init.mlx")
out=sim("wec_array.slx");
filename=sprintf("sim_out/WEC_array_apf/delay_T%d.mat",wave_period*100);
save(filename,"out")
clear
end
%% Data load
RAO = zeros(41,2);
for ii = 10:50
    wave_period = 0.1*ii;
filename=sprintf("sim_out/WEC_array_apf/delay_T%d.mat",wave_period*100);
load(filename)
V_s_max = max(out.logsout{1}.Values);
V_WEC1_max = max(out.logsout{4}.Values);

RAO(ii-9,1)=wave_period;
RAO(ii-9,2)=V_WEC1_max/V_s_max;
end
plot(RAO(:,1),RAO(:,2))
%% plotting
% Open the figure file
fig = openfig("FloatHeaveRAOOneBodyHeaveOnlyExpTNumBEMEqCkt_20250122.fig");

% Get current axes of the figure
ax = gca;
% lines = findobj(ax, 'Type', 'Line');
% delete(lines(1))
hold(ax, 'on');
% % Clear existing plots on the same axes (optional)
% delete(findobj(ax, 'Type', 'Line', 'DisplayName', 'Eq-ckt')); % Remove any existing 'Eq-ckt' line
% 
eq_ckt = plot(RAO(:,1),RAO(:,2),'-o','Color','r','markersize',8,'DisplayName', 'Eq-ckt','linewidth',1.5); % Add DisplayName for legend
% 
hold(ax, 'off');



