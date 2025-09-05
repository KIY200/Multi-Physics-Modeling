clear; clc; close all;
addpath('functions/');
rng('default');

%% --- Sea‐state transition parameters ---
T1 = 6;   H1 = 1.44;    % Sea State 4 → 5
T2 = 8;   H2 = 2.6;     % Sea State 5 hold
T3 = 10;  H3 = 4;       % Sea State 5 → 6
dur = 3600; dt = 0.2;   % seconds per segment
wbar = 1/10*2*pi;       % central radian freq

%% --- Build ground‐truth mean‐period profile ---
% Single realization to extract PSD‐based mean periods
[eta1,t1] = fn_sea_state_transition(H1,T1,H2,T2,dur,dt);
[eta2,t2] = fn_sea_state_transition(H2,T2,H2,T2,dur,dt);
[eta3,t3] = fn_sea_state_transition(H2,T2,H3,T3,dur,dt);

t_profile   = [t1, t1(end)+t2, t1(end)+t2(end)+t3];
eta_profile = [eta1, eta2, eta3];
dt = t_profile(2)-t_profile(1);

PSD1 = compute_psd_from_eta(eta1,1/dt,10);
PSD2 = compute_psd_from_eta(eta2,1/dt,10);
PSD3 = compute_psd_from_eta(eta3,1/dt,10);

n1 = numel(t1); 
n2 = numel(t2); 
n3 = numel(t3);
% Ramp-up 1 (midpoint→end of t1)
t_mid1 = t1(ceil(n1/2)); T_mid1 = PSD1.T_mean;
t_end1 = t1(end);        T_end1 = PSD2.T_mean;
slope1 = (T_end1-T_mid1)/(t_end1-t_mid1);
mean_ramp1 = T_mid1 + slope1*(t1-t_mid1);
% Hold
mean_plateau = PSD2.T_mean * ones(1,n2);
% Ramp-up 2 (start→midpoint of t3)
t_start3 = t3(1);        T_start3 = PSD2.T_mean;
t_mid3   = t3(ceil(n3/2)); T_mid3 = PSD3.T_mean;
slope3   = (T_mid3-T_start3)/(t_mid3-t_start3);
mean_ramp2 = T_start3 + slope3*(t3-t_start3);

mean_period = [mean_ramp1, mean_plateau, mean_ramp2];

%% --- Smoothing & FT‐method parameters ---
Tp_smooth    = 10;    % reference period for smoothing (s)
Ncycles      = 50;    % # cycles in moving‐mean window
M            = round(Ncycles * Tp_smooth / dt);

window_size  = round(10*2*pi/wbar/dt);
delay_factor = 0.01;
median_win   = round(delay_factor * window_size);
filter_size  = round(8/dt * 2*pi/wbar);

%% --- Monte Carlo collection ---
nMC = 100;
Ntot = length(t_profile);
T_est.poly0    = nan(nMC,Ntot);
T_est.poly1    = nan(nMC,Ntot);
T_est.median   = nan(nMC,Ntot);
T_est.cheat    = nan(nMC,Ntot);
T_est.forecast = nan(nMC,Ntot);

for k = 1:nMC
  % Resynthesize the three‐segment series
  [e1,t1] = fn_sea_state_transition(H1,T1,H2,T2,dur,dt);
  [e2,t2] = fn_sea_state_transition(H2,T2,H2,T2,dur,dt);
  [e3,t3] = fn_sea_state_transition(H2,T2,H3,T3,dur,dt);
  t_prof   = [t1, t1(end)+t2, t1(end)+t2(end)+t3];
  eta_prof = [e1, e2, e3];

  % Instantaneous freq by each method
  f0 = poly_inst_f(      t_prof', eta_prof', window_size,    0).inst_freq;
  f1 = poly_inst_f(      t_prof', eta_prof', window_size,    1).inst_freq;
  fm = median_inst_f(    t_prof', eta_prof', window_size, median_win).inst_freq;
  fc = cheat_inst_f(     t_prof', eta_prof', filter_size).inst_freq;
  ff = forecast_inst_freq(t_prof', eta_prof', window_size/8).inst_freq;

  % Smooth & convert to period
  T_est.poly0(k,:)    = 1./movmean(f0,    M);
  T_est.poly1(k,:)    = 1./movmean(f1,    M);
  T_est.median(k,:)   = 1./movmean(fm,    M);
  T_est.cheat(k,:)    = 1./movmean(fc,    M);
  T_est.forecast(k,:) = 1./movmean(ff,    M);
end

%% --- Compute bias & RMSE ---
methods = fieldnames(T_est);
for i = 1:numel(methods)
  name = methods{i};
  E = T_est.(name) - mean_period;       % error matrix
  bias.(name)   = mean(E(:));
  rmse.(name)   = sqrt(mean(E(:).^2));
  bias_t.(name) = mean(E,1);
  std_t.(name)  = std(E,0,1);
end

%% --- Plot bias ±1σ over time ---
figure; hold on;
cols = lines(numel(methods));
for i = 1:numel(methods)
  name = methods{i};
  b = bias_t.(name);
  s = std_t.(name);
  fill([t_profile, fliplr(t_profile)], ...
       [b+s, fliplr(b-s)], cols(i,:), 'EdgeColor','none', 'FaceAlpha',.2);
  plot(t_profile, b, 'Color',cols(i,:),'LineWidth',1.5,'DisplayName',name);
end
xlabel('Time (s)'); ylabel('Period error (s)');
title('Bias ±1σ of Estimated Mean Period');
legend('Location','best'); grid on;

%% --- Print performance table ---
fprintf('Method     |   Bias (s)   |  RMSE (s)\n');
fprintf('-----------|--------------|-----------\n');
for i = 1:numel(methods)
  name = methods{i};
  fprintf('%-10s | %10.3f | %8.3f\n', name, bias.(name), rmse.(name));
end
