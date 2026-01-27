%% Data acquisition
load("T_2_H_p1_D_4m.mat")
sc_factor = 20;
% If the loaded variable isn't literally named "data", you can adapt this:
% e.g., data = logsout;  or data = out.logsout;

output = struct();

for ii = 1:data.numElements
    elem = data.get(ii);                    % Simulink.SimulationData.Signal
    sigName = matlab.lang.makeValidName(elem.Name);

    % elem.Values is usually a timeseries
    output.(sigName).ts = elem.Values;      % store full timeseries object
    % Optionally also store raw arrays:
    output.(sigName).t  = elem.Values.Time;
    output.(sigName).x  = elem.Values.Data;
end

output.P_in_WEC1_scaled.x = output.P_in_WEC1.x.*20^3.5;
output.P_in_WEC2_scaled.x = output.P_in_WEC2.x.*20^3.5;

P_loss_LUPA1 = -mean(output.P_loss_WEC1.x);
P_loss_LUPA2 = -mean(output.P_loss_WEC2.x);


%% Plotting
% --- Publication-style plotting for power signals (3x1) ---

% Optional: OSU-inspired colors (adjust if you already have a palette struct)
c1 = [243 115  33]/255;   % orange
c2 = [ 93 135 161]/255;   % dark blue

% Figure + global styling
fig = figure(1); clf(fig);
set(fig, 'Color','w', 'Units','inches', 'Position',[1 1 6.5 7.0]); % IEEE-friendly width

tiledlayout(3,1, 'TileSpacing','compact', 'Padding','compact');

LW = 1.6;      % line width
FS = 11;       % font size
AXLW = 1.0;    % axis line width

% Helper for consistent axis formatting
formatAx = @(ax) set(ax, ...
    'FontName','Times New Roman', ...
    'FontSize',FS, ...
    'LineWidth',AXLW, ...
    'Box','on', ...
    'TickDir','in', ...
    'XGrid','on', 'YGrid','on', ...
    'GridLineStyle',':');

% -------------------------
% (1) Wave Power Input
% -------------------------
ax1 = nexttile; hold(ax1,'on');
plot(ax1, output.P_in_WEC1.t*sc_factor^0.5, output.P_in_WEC1_scaled.x/1000, ...
    'LineWidth', LW, 'Color', c1);
plot(ax1, output.P_in_WEC2.t*sc_factor^0.5, output.P_in_WEC2_scaled.x/1000, ...
    'LineWidth', LW, 'Color', c2);
ylabel(ax1, 'Power (kW)', 'FontName','Times New Roman');
title(ax1, 'Wave-Excitation Power', 'FontName','Times New Roman', 'FontWeight','normal');
legend(ax1, {'WEC1','WEC2'}, 'Location','northeast', 'Box','off');
formatAx(ax1);
hold(ax1,'off');

% -------------------------
% (2) PTO Power Generation
% -------------------------
ax2 = nexttile; hold(ax2,'on');
plot(ax2, output.P_WEC1_Full_scale.t*sc_factor^0.5, output.P_WEC1_Full_scale.x/1000, ...
    'LineWidth', LW, 'Color', c1);
plot(ax2, output.P_WEC2_Full_scale.t*sc_factor^0.5, output.P_WEC2_Full_scale.x/1000, ...
    'LineWidth', LW, 'Color', c2);
ylabel(ax2, 'Power (kW)', 'FontName','Times New Roman');
title(ax2, 'PTO Power Generation', 'FontName','Times New Roman', 'FontWeight','normal');
legend(ax2, {'WEC1','WEC2'}, 'Location','northeast', 'Box','off');
formatAx(ax2);
hold(ax2,'off');

% -------------------------
% (3) Transmission Power Loss
% -------------------------
ax3 = nexttile; hold(ax3,'on');
plot(ax3, output.P_loss_Full_scale_WEC1.t*sc_factor^0.5, output.P_loss_Full_scale_WEC1.x/1000, ...
    'LineWidth', LW, 'Color', c1);
plot(ax3, output.P_loss_Full_scale_WEC2.t*sc_factor^0.5, output.P_loss_Full_scale_WEC2.x/1000, ...
    'LineWidth', LW, 'Color', c2);
xlabel(ax3, 'Time (s)', 'FontName','Times New Roman');
ylabel(ax3, 'Power (kW)', 'FontName','Times New Roman');
title(ax3, 'Transmission Power Loss', 'FontName','Times New Roman', 'FontWeight','normal');
legend(ax3, {'WEC1','WEC2'}, 'Location','northeast', 'Box','off');
formatAx(ax3);
hold(ax3,'off');

% Link x-axes (common time axis)
linkaxes([ax1 ax2 ax3], 'x');

% Optional: consistent x-limits if you want to focus a window
% xlim(ax1, [t0 t1]);

%Export (vector PDF recommended for publications)
exportgraphics(fig, 'Power_3panel.pdf', 'ContentType','vector', 'Resolution',300);
exportgraphics(fig, 'Power_3panel.png', 'ContentType','vector', 'Resolution',300);




%% Average Power Metrics (kW)

% Wave input power
Pin1_avg = mean(output.P_in_WEC1_scaled.x) / 1000;
Pin2_avg = mean(output.P_in_WEC2_scaled.x) / 1000;

% PTO generated power
PTO1_avg = mean(output.P_WEC1_Full_scale.x) / 1000;
PTO2_avg = mean(output.P_WEC2_Full_scale.x) / 1000;

% Transmission losses
Loss1_avg = mean(output.P_loss_Full_scale_WEC1.x) / 1000;
Loss2_avg = mean(output.P_loss_Full_scale_WEC2.x) / 1000;

% Transmission loss as % of PTO power
Loss1_pct = Loss1_avg / PTO1_avg * 100;
Loss2_pct = Loss2_avg / PTO2_avg * 100;

Eff1 = (PTO1_avg - Loss1_avg) / Pin1_avg * 100;   % %
Eff2 = (PTO2_avg - Loss2_avg) / Pin2_avg * 100;   % %

%% Create Summary Table for Report (Word-ready)

Metric = {
    'Average Wave Input Power (kW)';
    'Average PTO Power (kW)';
    'Average Transmission Loss (kW)';
    'Transmission Loss (% of PTO Power)';
    'Overall Efficiency ((PTO - Loss) / Input) (%)'
};

WEC1 = [
    Pin1_avg;
    PTO1_avg;
    Loss1_avg;
    Loss1_pct;
    Eff1
];

WEC2 = [
    Pin2_avg;
    PTO2_avg;
    Loss2_avg;
    Loss2_pct;
    Eff2
];

T = table( ...
    Metric, ...
    round(WEC1,2), ...
    round(WEC2,2), ...
    'VariableNames', {'Metric','WEC1','WEC2'} );

%% Export table to Microsoft Word

docFile = 'Average_Power_Summary.docx';

if isfile(docFile)
    delete(docFile);
end

import mlreportgen.dom.*

d = Document(docFile,'docx');
append(d, Paragraph('Average Power Performance Summary'));

tbl = FormalTable(T);
tbl.Header.Style = {Bold(true)};
tbl.Style = { ...
    Width('100%'), ...
    Border('single'), ...
    ColSep('single'), ...
    RowSep('single') };

append(d, tbl);
close(d);
