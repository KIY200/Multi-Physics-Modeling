clc;clear;close all;

%% Iteration script for wave propagation model
for ii = 10:50
wave_period = 0.1*ii;
run("wec_array_init.mlx")
out=sim("wec_array.slx");
filename=sprintf("sim_out/WEC_array_apf/T%d.mat",wave_period*100);
save(filename,"out")
clear
end
%% Data load
RAO = zeros(41,2);
for ii = 10:50
    wave_period = 0.1*ii;
filename=sprintf("sim_out/WEC_array_apf/T%d.mat",wave_period*100);
load(filename)
V_s_max = max(out.logsout{1}.Values);
V_WEC1_max = max(out.logsout{4}.Values);

RAO(ii-9,1)=wave_period;
RAO(ii-9,2)=V_WEC1_max/V_s_max;
end

%% plotting
% Open the figure file
fig = openfig("FloatHeaveRAOOneBodyHeaveOnlyExpTNumBEM_20231004_112907_legend edit.fig");

% Get current axes of the figure
ax = gca;

% hold(ax, 'on');
% % Clear existing plots on the same axes (optional)
% delete(findobj(ax, 'Type', 'Line', 'DisplayName', 'Eq-ckt')); % Remove any existing 'Eq-ckt' line
% 
% eq_ckt = plot(RAO(:,1),RAO(:,2), 'DisplayName', 'Eq-ckt'); % Add DisplayName for legend
% 
% hold(ax, 'off');
lines = findobj(ax, 'Type', 'Line');

set(lines(1), 'LineWidth', 1.5, 'LineStyle','-','Color','r');
% Release hold


% Set the window size and position
% Position = [left, bottom, width, height]

% grid on
% xlabel("Wave Period (seconds)")
% ylabel("RAO")
% ylim([0,2])

