%% Instantaneous frequency experiments

% * v(t) = A(t)*sin(chi(t))
% * dchi(t) = wbar + deps(t)    [instantaneous frequency, rad/s]
% * chi(t) = wbar t + eps(t)    [total phase, rad]
% * eps(t) is the (relative) phase

clear
close all

addpath("functions/")
WEC_data=load('rm3excitationforces_H2p4T9p0_0p1_seed1.mat');
duration=1200; % simulation time
scale=1; % figure scaling factor
t = linspace(0,duration,duration*10)';
dt=t(2)-t(1); % timestep
% t=WEC_data.eta_RM3_H2p4T9p0_0p1_seed1.Time;
% dt=t(2)-t(1);
% case4.eta = WEC_data.eta_RM3_H2p4T9p0_0p1_seed1;

%%% Wave time series generation (JOSWAP Spectrum)
gamma = 3.3; %% Narrowness of spectrum
fp = 1/9; %% Peak Frequency
H_s = 2; %% Significant wave height = (m)
[S_f, S_w] = JONSWAP(gamma,fp,H_s);
case4.eta= psd2eta(S_w,fp,t);
case4.eta=[t,case4.eta];

A = 1 + 0.1*sin(2*pi/40*t); % eta envelope modulation
epsilon = 0.9*sin(2*pi/25*t);     % phase modulation;
wbar = 2*pi*fp;             % base frequency
chi = wbar*t + epsilon;         % total angle
case1.inst_w = [t,gradient(chi,t)];        % instantaneous frequency
case1.eta = [t A.*sin(chi)];

%%% A noise add
A_noisy = 1*(t<200) + 0.7*(t>=200);
case2.eta = [t A_noisy.*sin(chi)];
case2.inst_w = [t,gradient(chi,t)];

%%% f noise add
eta_no_eps = A.*sin(chi-epsilon);
wbar_noisy = wbar*(t<200)+1.5*wbar*(t>=200);
chi_noisy = cumtrapz(t,wbar_noisy);
case3.inst_w = [t,gradient(chi_noisy,t)];
case3.eta=[t A.*sin(chi_noisy)];

%%% Instantaneous value calculation parameters
window_size = round(10*2*pi/wbar/dt); % real time calulation window estimated with 10 waves 
% delay_time = 0.1; % seconds
% df = 1 - (delay_time/dt/window_size); % determine the delay factor from delay time.
% filter_size = round(2*pi/wbar*0.5/dt); % moving filter size
% median_window_seconds=round(0.01*window_size*dt);
delay_factor=0.055; % 5% of window_size 
filter_size=round(8/dt*2*pi/wbar);
%% Case test
median_window=round(delay_factor*window_size);
Case1_Hilbert = median_inst_f(t,case1.eta(:,2),window_size,median_window);
Case1_Hilbert.inst_freq(window_size)=Case1_Hilbert.inst_freq(window_size-1);

median_window=round(delay_factor*window_size);
Case2_Hilbert = median_inst_f(t,case2.eta(:,2),window_size,median_window);
Case2_Hilbert.inst_freq(window_size)=Case2_Hilbert.inst_freq(window_size-1);

median_window=round(2*delay_factor*window_size);
Case3_Hilbert = median_inst_f(t,case3.eta(:,2),window_size,median_window);
Case3_Hilbert.inst_freq(window_size)=Case3_Hilbert.inst_freq(window_size-1);


%%
median_window=round(2*delay_factor*window_size);
% Case4_Hilbert = median_inst_f(t,case4.eta.data,window_size,median_window);
Case4_Hilbert = median_inst_f(t,case4.eta(:,2),window_size,median_window);
Case4_Hilbert.inst_freq(window_size+1)=Case4_Hilbert.inst_freq(window_size);

%%% real_eta Case
% Full_access=cheat_inst_f(t,case4.eta.data,filter_size);
Full_access=cheat_inst_f(t,case4.eta(:,2),filter_size);
%% PLL tuning

Kp_LF = 1;
Ki_LF = 1;
case_input=4;
mdl = 'PLL_vs_Hilbert_Mdpi';
fc_1 = 1.1; %cutoff frequency for PI controller
phase_margin = 60; %% Phase margin for PI controler
[Kp_LF,Ki_LF]=PLL_tune(mdl,fc_1,phase_margin);


%% testing 4 cases
% Open the Simulink model
open(mdl);

% Loop over the desired number of cases
for ii = 1:3
    % Set the case input parameter
    case_input = ii;
    
    % Run the simulation
    out = sim(mdl);
    
    % Define the filename for saving the output
    filename = sprintf('output/case%d.mat', ii);
    
    % Save the entire simulation output
    save(filename, 'out');
end
%% Special tune for case 4
case_input=4;

mdl = 'PLL_vs_Hilbert_Mdpi';
fc_2 = 0.2; %cutoff frequency for PI controller
phase_margin = 60; %% Phase margin for PI controler
[Kp_LF,Ki_LF]=PLL_tune(mdl,fc_2,phase_margin);

% Run the simulation
out = sim(mdl);

% Define the filename for saving the output
filename = sprintf('output/case%d.mat', case_input);

% Save the entire simulation output
save(filename, 'out');
%% Plotting

% Create the formatted string using sprintf with the proper format specifiers.
message = sprintf("Median window delay factor : %f, fc_1 = %f, fc_2 = %f", delay_factor, fc_1, fc_2);

% Display the formatted message
disp(message);

run('Plotting_results.m')

%%
% instantaneous_values_real=median_inst_f(t,eta_real.eta',window_size,median_window);
% % fixing spike at the boundary.
% % instantaneous_values_A_case.inst_freq(5000)=instantaneous_values_A_case.inst_freq(4999);
% customPlot(t,instantaneous_values_real.inst_freq,1.5)
% ylabel('Instantaneous Frequency (Hz)');
% % legend('True Value','Estimate Value');
% xlim([0,400])
% plot(t,cheat_f.inst_freq)


% subplot(2,1,1)
% customPlot(t,Full_access.inst_freq_filtered,1,Hilbert_median.inst_freq_filtered)
% legend('Full access','RT Hilbert')
% xlabel('Time (s)')
% ylabel('Instantaneous Frequency (Hz)')
% subplot(2,1,2)
% customPlot(t,case4.eta(:,2),1)
% legend('\eta_{JONSWAP}');
% xlabel('Time (s)')
% ylabel('Water Elevation (m)')
