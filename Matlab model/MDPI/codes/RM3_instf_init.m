clear; clc;
addpath("functions/")

% %% JONSWAP wave generator
% 
% duration=1200; % simulation time
% 
% t = linspace(0,duration,duration*100)';
% dt=t(2)-t(1); % timestep
% 
%%% Wave time series generation (JOSWAP Spectrum)
gamma = 4; %% Narrowness of spectrum
fp = 1/9; %% Peak Frequency

Te=1/1.1/fp;
wbar = 2*pi*fp;
H_s = 2.4; %% Significant wave height = (m)
[S_f, S_w] = JONSWAP(gamma,fp,H_s);
rho=1000;
g=9.81;

E_wave_theoretical = (1/16) * rho * g * H_s^2;

k = (2*pi*S_f(:,1)).^2/g;
v_g = 1/2*sqrt(g./k);
P_wave = rho*g*trapz(S_f(:,1),v_g.*S_f(:,2));
P_wave_a = rho*g^2*H_s^2*Te/64/pi;

% 
% 

% % eta_JONSWAP= psd2eta(S_w,fp,t);
% % eta = [t eta_JONSWAP];
% 

%% load files
filename = "hydro/rm3.h5";
hydro=h5tostruct(filename);

Fex_ts=load("rm3excitationforces_H2p4T9p0_0p1_seed1.mat");
Fex = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1;
t=Fex_ts.eta_RM3_H2p4T9p0_0p1_seed1.Time;
dt = round(t(2)-t(1),1);
% Fex_ts.Fex_2 = Fex_ts.Fex_RM3_H2p4T9p0_0p1_seed1.data;
eta= Fex_ts.eta_RM3_H2p4T9p0_0p1_seed1;
load("rm3_ss_0p1.mat")
fp = 1/9; %% Peak Frequency
wbar = 2*pi*fp;
H_s = 2; %% Significant wave height = (m)

%% Instantaneous value calculation parameters
window_size = round(10*2*pi/wbar/dt); % real time calulation window estimated with 10 waves 
% delay_time = 0.1; % seconds
% df = 1 - (delay_time/dt/window_size); % determine the delay factor from delay time.
% filter_size = round(2*pi/wbar*0.5/dt); % moving filter size
delay_factor=0.005; % 0.5% of window_size 
filter_size=round(8/dt*2*pi/wbar);

median_window=round(2*delay_factor*window_size);
Hilbert = median_inst_f(t,eta.data,window_size,median_window);
Hilbert.inst_freq(window_size+1)=Hilbert.inst_freq(window_size);

%%% real_eta Case
Full_access=cheat_inst_f(t,eta.data,filter_size);


%% PTO control setup
PTO_ctrl = 0; % 0 : Damping only control
          % 1 : PI control

% Define the range of T_ref values

% Initialize arrays to store outputs
pto_damping_values = zeros(size(hydro.w));
pto_stiffness_values = zeros(size(hydro.w));

% Loop through T_ref values to compute outputs
for i = 1:length(hydro.w)
    w_ref = hydro.w(i);
    % Call your existing function or computation here
    [pto_damping, pto_stiffness] = pto_opt(w_ref, PTO_ctrl,hydro);
    pto_damping_values(i) = pto_damping;
    pto_stiffness_values(i) = pto_stiffness;
end
w_ref = hydro.w;

estimation_method_selection = 2; % Instantaneous frequency Estimation Method 
                       % 1 : PLL; 2 = Hilbert_median; 3 = Cheat
%% PLL tuning

mdl = 'RM3_instf_ctrl';
Kp_LF = 1;
Ki_LF = 1;
fc = 0.65; %cutoff frequency for PI controller
phase_margin = 60; %% Phase margin for PI controler
[Kp_LF,Ki_LF]=PLL_tune(mdl,fc,phase_margin);
%%
out = sim("RM3_instf_ctrl.slx");
switch PTO_ctrl
    case 0
    switch estimation_method
        case 1
            location=sprintf("Output/SS_model/PLL_damping");
            save(location,"out")
        case 2
           location=sprintf("Output/SS_model/Hilbert_damping");
            save(location,"out") 
        case 3
            location=sprintf("Output/SS_model/Cheat_damping");
            save(location,"out")
    end
    case 1
    switch estimation_method
        case 1
            location=sprintf("Output/SS_model/PLL_PI");
            save(location,"out")
        case 2
           location=sprintf("Output/SS_model/Hilbert_PI");
            save(location,"out") 
        case 3
            location=sprintf("Output/SS_model/Cheat_PI");
            save(location,"out")
    end
end


%% PTO control sweep test
for ii =5:12
    ctrl_f = 1/ii;
    out=sim(mdl);
    location=sprintf("Output/SS_model/T%d",ii);
    save(location,"out")
end

%% Plotting 
colors.osu.orange = [243 115 33]/256;
colors.osu.darkblue = [93 135 161]/256;
colors.osu.lightblue = [156 197 202]/256;
colors.osu.lightgray = [201 193 184]/256;
colors.osu.darkgray = [171 175 166]/256;
colors.osu.gold = [238 177 17]/256;
colors.osu.lightbrown = [176 96 16]/256;
colors.osu.red = [192 49 26]/256;
colors.osu.green = [159 166 23]/256;
colors.osu.purple = [98 27 75]/256;
colors.osu.black = [0 0 0]/256;

scale = 1;
figure;
hold on;

% Variables to track the maximum energy and corresponding period
maxEnergy = -inf;
maxPeriodIndex = -1;

% Array of custom colors
colorNames = fieldnames(colors.osu);
numColors = length(colorNames);

% First loop to determine the period with the maximum energy
for ii = 5:12
    location = sprintf('Output/SS_model/T%d_PI_ctrl', ii);
    load(location, 'out');
    % Calculate the total energy for the current period
    totalEnergy = sum(out.Epto.Data);
    end_energy(ii-4) = out.Epto.Data(end);
    P_pto = end_energy/1200/20;
    % Update the maximum energy and period index if current is greater
    if totalEnergy > maxEnergy
        maxEnergy = totalEnergy;
        maxPeriodIndex = ii;      
    end
end

% Second loop to plot all periods, highlighting the maximum energy period
colorIndex = 1;
for ii = 5:12
    location = sprintf('Output/SS_model/T%d_PI_ctrl', ii);
    load(location, 'out');
    % Assign color from the custom palette
    colorName = colorNames{colorIndex};
    plotColor = colors.osu.(colorName);
    % Check if this is the period with the maximum energy
    if ii == maxPeriodIndex
        % Highlight this plot with a thicker line width
        plot(out.Epto.Time, out.Epto.Data / 1e6, 'LineWidth', 3, 'Color', 'r', ...
            'DisplayName', sprintf('T = %ds (Max Energy)', ii));
    else
        % Regular plot for other periods
        plot(out.Epto.Time, out.Epto.Data / 1e6, 'LineWidth', 1.5, 'Color', plotColor, ...
            'DisplayName', sprintf('T = %ds', ii), 'LineStyle', '--');
    end
    % Update color index
    colorIndex = mod(colorIndex, numColors) + 1;
end

hold off;
legend('show');
xlabel('Time (s)');
ylabel('Energy (MJ)');
ax = gca;
ax.FontSize = 24 * scale;
ax.XAxis.FontSize = 18 * scale;
ax.YAxis.FontSize = 18 * scale;
set(gca, 'LineWidth', 2 * scale);
grid on;
wdw = gcf;
wdw.Position = [0, 661, 1920, 920] / 2;


CWR = P_pto' ./ P_wave_a * 100;
formattedCWR = arrayfun(@(x) sprintf('%.2f', x), CWR, 'UniformOutput', false);