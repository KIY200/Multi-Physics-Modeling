%%
close all
clear all
clc
%% before running this code first set path for all the subfolders inside WEC-Sim source folder

% inputs for wave conditions (no limit on number of wave componants), simulation duration and dt:

wave.T = [7.0]; % wave periods 
wave.H = [1]; % wave heights corresponding to the above periods
wave.phi = [0]; % initial phases for each component 
rampTime =140; %it is better to be defined (matched) with wec-sim ramptime input fpr fair comparison
duration = 700; % duration of the simulation in seconds
dt = 0.01; % Constant dt of the solution 

k_pto=0;
c_pto=0;
%%% loading WEC-Sim output files for cases with different period T
% load T_2_H_1_20_100.mat
% load T_3_H_1_20_100.mat
% load T_4_H_1_20_100.mat
% load T_5_H_1_20_100.mat
% load T_6_H_1_20_100.mat
load T_7_H_1_20_100.mat
% load T_8_H_1_20_100.mat
% load T_9_H_1_20_100.mat
% load T_10_H_1_20_100.mat
% load T_11_H_1_20_100.mat


%%%%%% damped cases

% load T_10_H_1_20_100_C_1200000.mat

% calling preprocessing step for wave elevation:

[time, eta,rampFunction] = prepro_wave(wave.T,wave.H,wave.phi, duration,dt,rampTime);

%%
% Loading the hydrodynamic coefficients of the system 
[d,M_b1,M_b2,b1_Ma,b2_Ma,b1_Res,b2_Res,b1_C_rad_all,b2_C_rad_all,b1_cg,b2_cg,b1_Ex_re,b1_Ex_im,b2_Ex_re,b2_Ex_im,w] = prepro_hydro_lin(wave.T);


%initial constraint matrix (linear and constant)

 Tc = zeros([12 7]);
Tc(7,1)=1; Tc(8,2)=1;Tc(9,3)=1;Tc(10,4)=1;Tc(11,5)=1;
Tc(12,6)=1; Tc(1,1)=1;Tc(1,5)=d;Tc(2,2)=1;Tc(2,4)=d;
Tc(3,3)=0;Tc(3,5)=0;Tc(3,7)=1;Tc(4,4)=1;Tc(5,5)=1;Tc(6,6)=1; 




%constant transformation matrix, now is assumed unity due to small rotation
%and linearization assumption

Trans = diag(ones([6 1]));

[M7,K7,Ma,k12] = pre_main_const(Trans,Tc,M_b1,M_b2,b1_Ma,b2_Ma,b1_Res,b2_Res,k_pto);

%Modal analysis
%V_e is eigen vector
%D_e is eigen value

[V_e,D_e] = eig(K7,M7); 

for ii=1:7
    D_vectore(ii,1)=D_e(ii,ii); % vecorizing the eigen values D_e, D_vector is 7*1
end

T_e = 2*pi./sqrt(D_vectore); % is a 7*1 vector (natural period of the WEC)

%main simulation time loop

% x is disp 
% v is velocity

% initialization x, v and out_dx

x(1:7,1:length(time))=0;
v(1:7,1:length(time))=0;

x2mode(1:2,1:length(time))=0;
v2mode(1:2,1:length(time))=0;

out_dx(1:4,1:length(time))=0;

for jj=1:length(wave.T)

    %find the closest periods ( T(jj) for random/bimodal cases)
    
    target = ones(size(T_e))*wave.T(jj);   % 7*1 vector (incoming wave period)
    temp = abs(target - T_e);
    [B,I] = mink(temp,2,'ComparisonMethod','abs');
    
    %here I is the 2 most closest eigen values to the incoming wave

    v_phi = [V_e(:,I(1)) V_e(:,I(2))]; % is eigen vector basis 7*2 

%C_r is   7 by 7 radiation damping coefficient matrix for a single frequancy wave
%c_r_12   12 by 12 radiation damping coefficient matrix for a single frequancy wave

[F_ex,C_r,c_r_12,F_ex12] = pre_main_const_2(Trans,Tc,wave.H,wave.T,wave.phi,rampFunction,b1_Ex_re,b2_Ex_re,b1_Ex_im,b2_Ex_im,b1_C_rad_all,b2_C_rad_all,time,c_pto);


M2 = v_phi'*M7*v_phi; % 2*1g eneralized mass matrix in eigon vector domain
K2 = v_phi'*K7*v_phi; % 2*1 generalized restoring matrix in eigon vector domain
C_r2=  v_phi'*C_r*v_phi; % 2*1 generalized radiation damping coeff matrix in eigon vector domain
F_ex2 = v_phi'*F_ex; % 2*1 exciatation force in eign vector domain



for ii=2:length(time)


    [dx] = RM3_NA_v8(F_ex2(:,ii),M2,K2,C_r2,x2mode(:,ii-1),v2mode(:,ii-1)); 
    
    out_dx(:,ii) = dx;
    x2mode(:,ii)=dx(1:2)*dt+x2mode(:,ii-1);
    v2mode(:,ii)=dx(3:4)*dt+v2mode(:,ii-1);
    acc2mode(:,ii)=dx(3:4);


ii
end
jj
end

x = v_phi*x2mode;     % 7*1
v = v_phi*v2mode;     % 7*1
acc= v_phi*acc2mode;  % 7*1

x12=Tc*x;
v12=Tc*v;
acc12=Tc*acc;
rad_f=c_r_12*v12;   
f_res = k12*x12;



Max_error_float_heave=100*abs(max(detrend(output.bodies(1).position(:,3)))-max(x12(3,:)))/max(detrend(output.bodies(1).position(:,3)));
Max_error_spar_heave=100*abs(max(detrend(output.bodies(2).position(:,3)))-max(x12(9,:)))/max(detrend(output.bodies(2).position(:,3)));


figure 
plot(time,x12(3,:),output.bodies(1).time,detrend(output.bodies(1).position(:,3)))
legend('ROM','WEC-Sim')
title('Heave disp of float')
xlabel('time (s)')
ylabel('Heave (m)')





figure
plot(time,x12(9,:),output.bodies(2).time,detrend(output.bodies(2).position(:,3)))
legend('ROM','WEC-Sim')
title('Heave disp of spar')
xlabel('time (s)')
ylabel('Heave (m)')









error_new_f=100*rms(interp1(time,x12(3,:),output.bodies(1).time)-detrend(output.bodies(1).position(:,3)))/rms(detrend(output.bodies(1).position(:,3)));
error_new_s=100*rms(interp1(time,x12(9,:),output.bodies(2).time)-detrend(output.bodies(2).position(:,3)))/rms(detrend(output.bodies(2).position(:,3)));

error_new_velocity_f=100*rms(interp1(time,v12(3,:),output.bodies(1).time)-detrend(output.bodies(1).velocity(:,3)))/rms(detrend(output.bodies(1).velocity(:,3)));
error_new_velocity_s=100*rms(interp1(time,v12(9,:),output.bodies(2).time)-detrend(output.bodies(2).velocity(:,3)))/rms(detrend(output.bodies(2).velocity(:,3)));

error_new_acceleration_f=100*rms(interp1(time,acc12(3,:),output.bodies(1).time)-detrend(output.bodies(1).acceleration(:,3)))/rms(detrend(output.bodies(1).acceleration(:,3)));
error_new_acceleration_s=100*rms(interp1(time,acc12(9,:),output.bodies(2).time)-detrend(output.bodies(2).acceleration(:,3)))/rms(detrend(output.bodies(2).acceleration(:,3)));

error_new_radiationforce_f=100*rms(interp1(time,rad_f(3,:),output.bodies(1).time)-detrend(output.bodies(1).forceRadiationDamping(:,3)))/rms(detrend(output.bodies(1).forceRadiationDamping(:,3)));
error_new_radiationforce_s=100*rms(interp1(time,rad_f(9,:),output.bodies(2).time)-detrend(output.bodies(2).forceRadiationDamping(:,3)))/rms(detrend(output.bodies(2).forceRadiationDamping(:,3)));





rootmeansquare_float=100*rms(interp1(time, x12(3,:),output.bodies(1).time)-detrend(output.bodies(1).position(:,3)))/wave.H;%max(detrend(output.bodies(1).position(:,3))); %float
rootmeansquare_spar=100*rms(interp1(time, x12(9,:),output.bodies(2).time)-detrend(output.bodies(2).position(:,3)))/wave.H;%max(detrend(output.bodies(2).position(:,3))); %spar

