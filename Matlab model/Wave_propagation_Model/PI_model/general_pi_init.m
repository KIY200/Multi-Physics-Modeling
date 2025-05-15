% general pi model init
f=0.1;
T=10; % 10 seconds
t_stop=T*3;
rho = 1000;
g = 9.81;
w = 2*pi*f;
k = w^2/g;
L_wave = 2*pi/k;

distance=100;
del_theta = k*distance*2*pi;

% SIL = 0.01;  % SIL = sqrt(L/C)
% C = distance * w/g/2;
% L = distance * w/g * SIL^2;
C = 1.97e3/2;
L = 5.21e-5;

SIL = sqrt(L/C);

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
