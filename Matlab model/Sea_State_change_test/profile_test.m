clear; clc; close all;
addpath('functions/')

%% --- Sea-state transition profile ---
T1 = 6;  H1 = 1.44;
T2 = 8;  H2 = 2.6;
T3 = 10; H3 = 4;
dur = 3600; dt = 0.2; % seconds per segment
wbar = 1/10*2*pi;


% 1st segment: (H1,T1) → (H2,T2)
[eta1, t1] = fn_sea_state_transition(H1, T1, H2, T2, dur,dt);
% 2nd segment: hold at (H2,T2)
[eta2, t2] = fn_sea_state_transition(H2, T2, H2, T2, dur,dt);
% 3rd segment: (H2,T2) → (H1,T1)
[eta3, t3] = fn_sea_state_transition(H2, T2, H3, T3, dur,dt);


% stitch together
t_profile   = [ t1,           t1(end)+t2,            t1(end)+t2(end)+t3 ];
eta_profile = [ eta1,         eta2,                  eta3 ];
dt=t_profile(2)-t_profile(1);


PSD_reverse1=compute_psd_from_eta(eta1,1/dt,10);
PSD_reverse2=compute_psd_from_eta(eta2,1/dt,10);
PSD_reverse3=compute_psd_from_eta(eta3,1/dt,10);



%% --- Sea-state number (for reference plot) ---
sea_state = [ 4 + 1/t1(end)*t1, ...
              5*ones(size(t2)), ...
              5 + 1/t3(end)*t3 ];
%— assume you have in your workspace:
%     t1, t2, t3                % time vectors for each segment
%     PSD_reverse1.T_mean       % mean‐period at midpoint of t1
%     PSD_reverse2.T_mean       % plateau mean‐period over t2
%     PSD_reverse3.T_mean       % mean‐period at midpoint of t3

% segment lengths
n1 = numel(t1);
n2 = numel(t2);
n3 = numel(t3);

% 1) Extrapolated ramp from midpoint of t1 → plateau at end of t1
t_mid1 = t1(ceil(n1/2));               % midpoint time of segment 1
T_mid1 = PSD_reverse1.T_mean;          % mean‐period at that midpoint
t_end1 = t1(end);                      
T_end1 = PSD_reverse2.T_mean;          % plateau level at start of segment 2

% slope so line passes through (t_mid1,T_mid1) and (t_end1,T_end1)
slope1 = (T_end1 - T_mid1) / (t_end1 - t_mid1);

% evaluate linear extrapolation at every t1
mean_ramp1 = T_mid1 + slope1 * (t1 - t_mid1);

% 2) Plateau over t2
mean_plateau = PSD_reverse2.T_mean * ones(1, n2);

% 3) Extrapolated ramp from plateau → midpoint of t3
t_start3 = t3(1);
T_start3 = PSD_reverse2.T_mean;
t_mid3   = t3(ceil(n3/2));
T_mid3   = PSD_reverse3.T_mean;

% slope for segment 3
slope3 = (T_mid3 - T_start3) / (t_mid3 - t_start3);

% evaluate linear extrapolation at every t3
mean_ramp2 = T_start3 + slope3 * (t3 - t_start3);

% 4) Concatenate into full mean‐period profile
mean_period = [ mean_ramp1, mean_plateau, mean_ramp2 ];



%% --- Instantaneous-frequency estimates ---
window_size = round(10*2*pi/wbar/dt); % real time calulation window estimated with 10 waves 
% delay_time = 0.1; % seconds
% df = 1 - (delay_time/dt/window_size); % determine the delay factor from delay time.
% filter_size = round(2*pi/wbar*0.5/dt); % moving filter size
delay_factor=0.05; % 1% of window_size 
filter_size=round(8/dt*2*pi/wbar);
median_window=round(delay_factor*window_size);

f_t_median = median_inst_f(t_profile', eta_profile', window_size, ...
    median_window);
f_t_cheat  = cheat_inst_f(  t_profile', eta_profile', filter_size);
f_t_forecast = forecast_inst_freq(t_profile', eta_profile', window_size/8);



f_t_o0     = poly_inst_f(t_profile', eta_profile', window_size, 0);
f_t_o1     = poly_inst_f(t_profile', eta_profile', window_size, 1);
% (you can uncomment higher orders if desired)
% f_t_o2   = poly_inst_f(t_profile', eta_profile, history_window, 2);

%% --- Trend (moving average) + curvefit(1st-order) parameters ---
% --- parameters & prep ---
Tp          = 10;                   % dominant period (s)
N           = 50;                 % # of periods in smoothing window
M           = round(N * Tp / dt);  % window length (samples)
seg_dur     = 3600;                % section duration in seconds
seg_samples = round(seg_dur / dt); % # samples per section
nSections   = ceil(length(t_profile) / seg_samples);

% --- original moving‐mean trends ---
f0_trend = movmean(f_t_o0.inst_freq,         M);
f1_trend = movmean(f_t_o1.inst_freq,         M);
fm_trend = movmean(f_t_median.inst_freq,     M);
fc_trend = movmean(f_t_cheat.inst_freq,      M);
ff_trend = movmean(f_t_forecast.inst_freq,   M);


% --- piecewise linear fits ---
f0_lin = nan(size(f0_trend));
f1_lin = nan(size(f1_trend));
fm_lin = nan(size(fm_trend));
fc_lin = nan(size(fc_trend));
ff_lin = nan(size(ff_trend));
for i = 1:nSections
    idx_start = (i-1)*seg_samples + 1;
    idx_end   = min(i*seg_samples, length(t_profile));
    idx       = idx_start:idx_end;
    tt        = t_profile(idx);
    
    p0        = polyfit(tt, f0_trend(idx), 1);
    f0_lin(idx) = polyval(p0, tt);
    
    p1        = polyfit(tt, f1_trend(idx), 1);
    f1_lin(idx) = polyval(p1, tt);
    
    pm        = polyfit(tt, fm_trend(idx), 1);
    fm_lin(idx) = polyval(pm, tt);
    
    pc        = polyfit(tt, fc_trend(idx), 1);
    fc_lin(idx) = polyval(pc, tt);

    pf        = polyfit(tt, ff_trend(idx), 1);
    ff_lin(idx) = polyval(pf, tt);
end



%% plotting the result
xlims = [Tp*10, t_profile(end)];
mod   = 1;
%%% —————— Define OSU Color Palette ——————
colors.osu.orange     = [243 115  33]/256;
colors.osu.darkblue   = [ 93 135 161]/256;
colors.osu.lightblue  = [156 197 202]/256;
colors.osu.lightgray  = [201 193 184]/256;
colors.osu.darkgray   = [171 175 166]/256;
colors.osu.gold       = [238 177  17]/256;
colors.osu.lightbrown = [176  96  16]/256;
colors.osu.red        = [192  49  26]/256;
colors.osu.green      = [159 166  23]/256;
colors.osu.purple     = [ 98  27  75]/256;
colors.osu.black      = [  0   0   0]/256;

%% —————— Figure 1: Sea‐State Transition with Tiled Layout ——————
figure(1); clf;

% create a 2×1 tiled layout with compact spacing
tiled = tiledlayout(2,1, ...
    'TileSpacing','compact', ...
    'Padding','compact');

scale = 2;  % font scaling

% compute global y‐limits
ymin = min(eta_profile);
ymax = max(eta_profile);

% — Tile 1: η with 3‐section shading
ax1 = nexttile(1);
hold(ax1,'on');
% Ramp‐Up 1
patch(ax1, [t1(1), t1(end), t1(end), t1(1)], ...
           [ymin, ymin, ymax, ymax], ...
      colors.osu.lightgray, 'FaceAlpha',0.3,'EdgeColor','none');
% Hold
t2_shift = t1(end);
patch(ax1, t2_shift + [t2(1), t2(end), t2(end), t2(1)], ...
           [ymin, ymin, ymax, ymax], ...
      colors.osu.lightblue,'FaceAlpha',0.3,'EdgeColor','none');
% Ramp‐Up 2
t3_shift = t1(end) + t2(end);
patch(ax1, t3_shift + [t3(1), t3(end), t3(end), t3(1)], ...
           [ymin, ymin, ymax, ymax], ...
      colors.osu.darkgray,'FaceAlpha',0.6,'EdgeColor','none');
% η trace
plot(ax1, t_profile, eta_profile, 'Color',colors.osu.orange,'LineWidth',2);
hold(ax1,'off');

ylabel(ax1,'\eta (m)','FontSize',14*scale);
legend(ax1,{'Ramp: 6→8 s','Hold: 8 s','Ramp: 8→10 s'}, ...
       'Location','best','FontSize',12*scale);
xlim(ax1, xlims);
grid(ax1,'on');

% — Tile 2: Sea‐state profile
ax2 = nexttile(2);
plot(ax2, t_profile, sea_state, 'Color',colors.osu.orange,'LineWidth',2);
xlabel(ax2,'Time (s)','FontSize',14*scale);
ylabel(ax2,'Sea State','FontSize',14*scale);
xlim(ax2, xlims);
grid(ax2,'on');


%% —————— Figure 2: Moving Means & Linear Fits with Tiled Layout ——————
figure('Name','Moving Mean & Linear Fits','NumberTitle','off'); 

tiled2 = tiledlayout(2,1, ...
    'TileSpacing','compact', ...
    'Padding','compact');

% Upper tile — moving–mean trends only
ax3 = nexttile(1);
hold(ax3,'on');
plot(ax3, t_profile, mod./f0_trend, '-',  'Color',colors.osu.black,    'LineWidth',2);
plot(ax3, t_profile, mod./f1_trend, '-',  'Color',colors.osu.darkblue, 'LineWidth',2);
plot(ax3, t_profile, mod./fm_trend, '--', 'Color',colors.osu.red,      'LineWidth',2);
plot(ax3, t_profile, mod./fc_trend, '-.', 'Color',colors.osu.green,    'LineWidth',2);
plot(ax3, t_profile, mod./ff_trend, '-.', 'Color',colors.osu.purple,   'LineWidth',2);
hold(ax3,'off');
grid(ax3,'on');
legend(ax3,{'Poly-0','Poly-1','Median','Non-causal','Forecast'}, ...
       'Location','best','FontSize',12*scale);
ylabel(ax3,'Period (s)','FontSize',14*scale);
xlim(ax3, xlims);

% Lower tile — linear‐fit curves + intended mean‐period profile
ax4 = nexttile(2);
hold(ax4,'on');
plot(ax4, t_profile, mod./f0_lin, '--', 'Color',colors.osu.black,   'LineWidth',2);
plot(ax4, t_profile, mod./f1_lin, '--', 'Color',colors.osu.darkblue,'LineWidth',2);
plot(ax4, t_profile, mod./fm_lin, ':',  'Color',colors.osu.red,     'LineWidth',2);
plot(ax4, t_profile, mod./fc_lin, ':',  'Color',colors.osu.green,   'LineWidth',2);
plot(ax4, t_profile, mod./ff_lin, ':',  'Color',colors.osu.purple,  'LineWidth',2);
plot(ax4, t_profile, mean_period,    '-',  'Color',colors.osu.orange,'LineWidth',3);
hold(ax4,'off');
grid(ax4,'on');
legend(ax4,{'Poly-0 trend','Poly-1 trend','Median trend','Non-Causal trend','Forecast trend', ...
    'Reference period profile'}, ...
       'Location','best','FontSize',12*scale);
xlabel(ax4,'Time (s)','FontSize',14*scale);
ylabel(ax4,'Period (s)','FontSize',14*scale);
xlim(ax4, xlims);
