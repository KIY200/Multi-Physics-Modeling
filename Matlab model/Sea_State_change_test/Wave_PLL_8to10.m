clear; clc; close all;

%% Load ETA Signal (Ensure ETA is already defined)
T_eta = 1e-2;                      % Hilbert Transform Timestep
T_sogi = 1e-4;                  % SOGI-PLL Timestep
T_total = 1200;                 % Total Simulation Time

%%Create time series 
T1=7;
T2=11;
H1=1.5;
H2=1.5;

[ETA, t] = fn_sea_state_transition(H1,T1,H2,T2,T_total)
plot(t,ETA)
dt = t(2)-t(1);

% Time vectors;
t_eta=t;  
t_sogi = 0:T_sogi:T_total;    

%% SOGI-FLL Parameters
f_nom = 0.2;                % Nominal frequency (Hz)
omega_nom = 2 * pi * f_nom; % Nominal angular frequency
k = 0.5*sqrt(2);          % SOGI gain parameter
Gamma = 0.8;

% Generate ETA from JONSWAP spectrum
%PSD = JONSWAP(3.3, 0.125, 1.5);  
%ETA = psd2eta(PSD, 0.125, t_eta); 

% Interpolate ETA to match fine time grid of SOGI-PLL
ETA_interp = interp1(t_eta, ETA, t_sogi, 'spline');

%% Hilbert Transform for Frequency Extraction (Using Built-in Function)
z = hilbert(ETA);  % Using MATLAB's built-in hilbert() function
hilbert_phase = unwrap(angle(z));
hilbert_freq = gradient(hilbert_phase, t_eta) / (2 * pi); % Frequency from Hilbert
filter_size=round(((2*pi)/(omega_nom))*8/(t_eta(2)-t_eta(1)));
frequency_filter=movmedian(hilbert_freq,filter_size)
% Define single value for Kp and Ki
%Kp = 1e-3;
%Ki = 1e-4;

%% Initialize SOGI-FLL variables
x1 = 0; x2 = 0;
theta_est = 0; omega_est = omega_nom; omega_est_prev = omega_nom;
integral_error = 0;

% Storage for plotting
x1_array = zeros(size(t_sogi));
x2_array = zeros(size(t_sogi));
omega_est_array = zeros(size(t_sogi));

%% Run SOGI-FLL simulation
for t = 1:length(t_sogi)
    v_in = ETA_interp(t);  % Use same ETA input
    
    % Tustin's Integration Method for Phase
    %theta_est = theta_est + (T_sogi / 2) * (omega_est + omega_est_prev);
    %omega_est_prev = omega_est;  % Store previous omega for next iteration
    
    % SOGI Update
    %dx1 = k * omega_est * (v_in - x1) - omega_est * x2;
    dx1 = (k*(v_in-x1)-x2)*omega_est;
    dx2 = omega_est * x1;
    x1 = x1 + dx1 * T_sogi;
    x2 = x2 + dx2 * T_sogi;

    % Compute phase error
    %phase_error = atan2(x2, x1);
    phase_error = (v_in-x1)*x2*(-Gamma);

    % Update frequency estimate
    integral_error = integral_error + phase_error * T_sogi;
    omega_est = integral_error+omega_nom;

    % Store data
    x1_array(t) = x1;
    x2_array(t) = x2;
    omega_est_array(t) = omega_est;

end

%% Plot ETA on top of In-phase (x1) signal
figure;
subplot(3, 1, 1);
plot(t_sogi, ETA_interp, 'k', 'LineWidth', 1.5); hold on;
plot(t_sogi, x1_array, 'r--', 'LineWidth', 1.5);
title('ETA (Input Signal) and SOGI In-Phase (x1)');
xlabel('Time (s)');
ylabel('Amplitude');
legend('ETA', 'x1 (In-Phase)', 'Location', 'Best');

%% Plot SOGI Quadrature (x2) signal
subplot(3, 1, 2);
plot(t_sogi, x2_array, 'b', 'LineWidth', 1.5);
title('SOGI Quadrature (x2)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% Plot Frequency Estimates (Hilbert vs SOGI-FLL)
subplot(3, 1, 3);
hold on;
plot(t_eta, frequency_filter, 'r-', 'LineWidth', 1.5);          % Hilbert frequency (red)
plot(t_sogi, omega_est_array / (2 * pi), 'g--', 'LineWidth', 1.5); % SOGI-FLL frequency (green)
title('Frequency Comparison: Hilbert vs SOGI-FLL (Tustin)');
%ylim([0 1])
xlabel('Time (s)');
ylabel('Frequency (Hz)');
legend('Hilbert Transform', 'SOGI-FLL (Tustin)');
grid on;


%%
p=polyfit(t_eta,frequency_filter,1);
inst_freq=polyval(p,t_eta);
p=polyfit(t_sogi,omega_est_array / (2 * pi),1);
inst_freq_FLL=polyval(p,t_sogi);
subplot(2,1,1)
plot(t_eta,inst_freq,t_eta,frequency_filter)
subplot(2,1,2)
plot(t_sogi,inst_freq_FLL,t_sogi,omega_est_array / (2 * pi))
