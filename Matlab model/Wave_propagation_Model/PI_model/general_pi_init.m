%% Housekeeping
clearvars; close all; clc;

%% Parameters
f        = 0.1;                % wave frequency [Hz]
T        = 1/f;                % period [s]
t_stop   = 3*T;                % total simulation time [s]
rho      = 1000;               % water density [kg/m^3]
g        = 9.81;               % gravity [m/s^2]
w        = 2*pi*f;             % angular frequency [rad/s]
k        = w^2/g;              % wave number [1/m]
L_wave   = 2*pi/k;             % wavelength [m]
H        = 2;                  % wave height [m]
distance = 7.5;                % separation distance [m]

%% Derived quantities
del_angle = distance * k * (180/pi);           % theoretical phase shift [deg]
d_eta_RMS = H/(2*sqrt(2));                     % RMS wave elevation [m]
P_wave     = rho*g^2*H^2/(32*pi);              % power flux per unit width [W/m]
SIL        = d_eta_RMS^2 / P_wave;             % Surge Impedance Load
L_per_l    = (w/g) * SIL;                      % inductance per unit length
C_per_l    = (w/g) / SIL / 2;                  % capacitance per branch
L          = distance * L_per_l;               % total inductance [H]
C          = distance * C_per_l;               % total capacitance [F]

%% Run the simulation with explicit stop time
simIn  = Simulink.SimulationInput('general_pi_model');
simIn  = setModelParameter(simIn, 'StopTime', num2str(t_stop));
simOut = sim(simIn);

%% Extract signals
t  = simOut.tout;
V0 = simOut.V0.data;
V1 = simOut.V1.data;
V2 = simOut.V2.data;

% 1) Find peaks in time domain (returns peak values & their times)
[~, locs0] = findpeaks(V0, t, 'MinPeakProminence', H/4);
[~, locs1] = findpeaks(V1, t, 'MinPeakProminence', H/4);
[~, locs2] = findpeaks(V2, t, 'MinPeakProminence', H/4);

% 2) Pick the 2nd peak to avoid startup transient
iPeak = 2;
t0 = locs0(iPeak);
t1 = locs1(iPeak);
t2 = locs2(iPeak);

% 3) Compute time delays
tau01 = t1 - t0;    % time delay branch1 vs branch0
tau02 = t2 - t0;    % time delay branch2 vs branch0

% 4) Convert to phase shift [deg]
T = 1/f;
phi01_deg = tau01/T * 360;
phi02_deg = tau02/T * 360;

% 5) Display results
fprintf('Peak-timing: branch1 leads branch0 by %.2f° (τ=%.4fs)\n', phi01_deg, tau01);
fprintf('Peak-timing: branch2 leads branch0 by %.2f° (τ=%.4fs)\n', phi02_deg, tau02);
