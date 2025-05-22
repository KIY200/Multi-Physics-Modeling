%% House keeping
clear;clc;close all;

%% general pi model init
f=0.1;
T=10; % 10 seconds
t_stop=T*3;
rho = 1000;
g = 9.81;
w = 2*pi*f;
k = w^2/g;
L_wave = 2*pi/k;
% c=3e8; % light speed
% L_light = c*T;
H = 2;

distance=7.5;
del_angle = distance*k *180/pi;
d_eta_RMS = H/2 * 2*pi / T /sqrt(2);
P_wave = 1/32/pi * rho * g^2 * 10 * H^2; % Power flux per width (W/m)
SIL = d_eta_RMS^2/P_wave;  % SIL = sqrt(L/C)
% LC = w^2/g^2
% L/C = SIL^2
% L^2 = w^2/g^2*SIL^2
L = distance * w/g*SIL;
C = distance * w/g/SIL/2;


% C = 1.97e3/2;
% L = 5.21e-5;

% SIL = sqrt(L/C);

%%
Simout=sim("general_pi_model.slx");
%%

t = Simout.tout;
V0=Simout.V0.data;
[idx_V0,~]=find(V0==max(V0(1:200)));
V1=Simout.V1.data;
[idx_V1,~]=find(V1==max(V1(1:200)));

del_t = (t(idx_V1)-t(idx_V0));
del_theta=del_t/T*360;
