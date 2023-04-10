%% plotting

clear;close all;clc;
WEC_Sim=load('results/current');
%basic parameters
rho=1000; %water density
g=9.81; %acceleration by gravity

wave.H = WEC_Sim.waves.H; %significant wave height
wave.T = WEC_Sim.waves.T;

%%% Load outputs
if WEC_Sim.waves.type=="regular"
    ckt=sprintf('Results/out_ckt_T_%d.mat',wave.T);
    WEC_Sim_L=sprintf('Results/out_WEC_Sim_T_%d.mat',wave.T);
else 
    ckt=sprintf('Results/out_ckt_ir_T_%d.mat',wave.T);
    WEC_Sim_L=sprintf('Results/out_WEC_Sim_ir_T_%d.mat',wave.T);
end

load(ckt)
load(WEC_Sim_L)
%%% Circuit model output
t_ckt = out_ckt.dz_1.Time;
mode.dz2 = [squeeze(out_ckt.dz_1.data) squeeze(out_ckt.dz_2.data)]';
mode.Fex2 = [squeeze(out_ckt.F_1.data) squeeze(out_ckt.F_2.data)]';
mode.F_B2 = [squeeze(out_ckt.F_B1.data) squeeze(out_ckt.F_B2.data)]';


dz7 = hydro.Phi72*mode.dz2;
dz12 = hydro.Tc*dz7;
Fex7 = hydro.Phi72*mode.Fex2;
Fex12 = hydro.Tc*Fex7;
F_B7 = hydro.Phi72*mode.F_B2;
F_B12 = hydro.Tc*F_B7;

% dz_float_ckt=dz12(3,:)';
dz_float_ckt=dz12(3,:)';
dz_spar_ckt=dz12(9,:)';
dz_rel_ckt=dz7(7,:)';
z_spar_ckt=cumtrapz(t_ckt,dz_spar_ckt);
z_float_ckt=cumtrapz(t_ckt,dz_float_ckt);

Fex_float_ckt = Fex12(3,:)';
Fex_spar_ckt = Fex12(9,:)';

Fpto_ckt=-WEC_Sim.pto.c*dz_rel_ckt;

F_rad_float = (F_B12(3,:)'+Fpto_ckt);
F_rad_spar = (F_B12(9,:)'-Fpto_ckt);

% Fpto_ckt = squeeze(out_ckt.Fpto.data);
P_pto_ckt = (Fpto_ckt.*dz_rel_ckt);
% P_in = rho*g^2/(64*pi)*wave.T*wave.H^2;
% Eff_ckt = P_pto_ckt./P_in;

%%% WEC-Sim output
t_wec = output.bodies(1).time;
float_dz=output.bodies(1).velocity(:,3);
spar_dz=output.bodies(2).velocity(:,3);
float_z=output.bodies(1).position(:,3)+0.72;
spar_z=output.bodies(2).position(:,3)+21.29;
float_Fex=output.bodies(1).forceExcitation(:,3);
spar_Fex=output.bodies(2).forceExcitation(:,3);
float_F_rad=output.bodies(1).forceRadiationDamping(:,3);
spar_F_rad=output.bodies(2).forceRadiationDamping(:,3);
v_rel = output.ptos.velocity(:,3);
P_pto_WEC = output.ptos.velocity(:,3).*output.ptos.forceInternalMechanics(:,3);
%%
normparam = 1;
v_rel_error = ...
    norm(dz_rel_ckt-v_rel,normparam)/norm(v_rel,normparam) * 100;
v_float_error = ...
    norm(dz_float_ckt-float_dz,normparam)/norm(float_dz,normparam) * 100;
v_spar_error = ...
    norm(dz_spar_ckt-spar_dz,normparam)/norm(spar_dz,normparam) * 100;
d_float_error = ...
    norm(z_float_ckt-float_z,normparam)/norm(float_z,normparam) * 100;
d_spar_error = ...
    norm(z_spar_ckt-spar_z,normparam)/norm(spar_z,normparam) * 100;
Fex_float_error = ...
    norm(Fex_float_ckt-float_Fex,normparam)/norm(float_Fex,normparam) * 100;
Fex_spar_error = ...
    norm(Fex_spar_ckt-spar_Fex,normparam)/norm(spar_Fex,normparam) * 100;

P_pto_error = ...
    norm(P_pto_WEC-P_pto_ckt,normparam)/norm(P_pto_WEC,normparam) * 100;

fprintf(['when T=%d, \nThe errors are calculated \n' ...
    '   In velocity \n' ...
    '       float: %0.5f%% \n' ...
    '       spar: %0.5f%% \n \n' ...
    '   In displacement \n' ...
    '       float: %0.5f%% \n' ...
    '       spar: %0.5f%% \n \n' ...
    'Elapsed times for the calculation are \n' ...
    '   %0.1f s in WEC-Sim \n' ...
    '   %0.1f s in Equivalent circuit model \n'], ...
    wave.T,v_float_error,v_spar_error,d_float_error,d_spar_error,output.ElapsedTime,out_ckt.Elapsed_time);


%%% plot
figure(1)
subplot(2,1,1);
plot(t_wec,dz_float_ckt)
hold on
plot(t_wec,float_dz);
hold off
% title_v = sprintf('float heave velocity(equivalent circuit model error of %0.1f%%)',v_float_error);
% title(title_v)
grid on
xlabel('time (s)')
ylabel('Velocity (m/s)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;


subplot(2,1,2);
plot(t_wec,dz_spar_ckt);
hold on
plot(t_wec,spar_dz);
hold off
% title_v = sprintf('spar heave velocity(equivalent circuit model error of %0.1f%%)',v_spar_error);
% title(title_v)
grid on
xlabel('time (s)')
ylabel('Velocity (m/s)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;


figure(2)
subplot(2,1,1);
plot(t_wec,z_float_ckt);
hold on
plot(t_wec,float_z);
hold off
% title_d = sprintf('float heave displacement(equivalent circuit model error of %0.1f%%)',d_float_error);
% title(title_d)
grid on
xlabel('time (s)')
ylabel('displacement (m)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;

subplot(2,1,2);
plot(t_wec,z_spar_ckt);
hold on
plot(t_wec,spar_z);
hold off
% title_d = sprintf('spar heave displacement(equivalent circuit model error of %0.1f%%)',d_spar_error);
% title(title_d)
grid on
xlabel('time (s)')
ylabel('displacement (m)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;

figure(3)
subplot(2,1,1);
plot(t_wec,Fex_float_ckt,'linestyle','--','color','b','linewidth',1.5);
hold on
plot(t_wec,float_Fex);
hold off
title('float heave excitation force')
grid on
xlabel('time (s)')
ylabel('Force (N)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;

subplot(2,1,2);
plot(t_wec,Fex_spar_ckt,'linestyle','--','color','b','linewidth',1.5);
hold on
plot(t_wec,spar_Fex);
hold off
title('spar heave excitation force')
grid on
xlabel('time (s)')
ylabel('Force (N)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;

figure(4)
subplot(2,1,1);
plot(t_wec,F_rad_float,'linestyle','--','color','b','linewidth',1.5);
hold on
plot(t_wec,float_F_rad);
hold off
title('float heave Radiation damping')
grid on
xlabel('time (s)')
ylabel('Force (N)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;

subplot(2,1,2);
plot(t_wec,F_rad_spar,'linestyle','--','color','b','linewidth',1.5);
hold on
plot(t_wec,spar_F_rad);
hold off
title('spar heave Radiation damping')
grid on
xlabel('time (s)')
ylabel('Force (N)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;

% 
% PTO Force
figure(5)
plot(t_wec,Fpto_ckt./1000,'linestyle','--','color','b','linewidth',1.5);
hold on
plot(t_wec,output.ptos.forceInternalMechanics(:,3)./1000);
hold off
title('PTO Force')
grid on
xlabel('time (s)')
ylabel('Force (kN)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;
% 
% PTO power generation
figure(6)
plot(t_wec,abs(Fpto_ckt.*dz_rel_ckt/1000),'linestyle','--','color','b','linewidth',1.5);
hold on
plot(t_wec,abs(output.ptos.velocity(:,3).*output.ptos.forceInternalMechanics(:,3)/1000));
hold off
% title_P = sprintf('PTO power generation(equivalent circuit model error of %0.1f%%)',P_pto_error);
% title(title_P)
grid on
xlabel('time (s)')
ylabel('Power (kW)')
legend('Equivalent circuit model','WEC-Sim','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;

%%saving fig
cd Results/

if WEC_Sim.waves.type == "regular"
    fig_v=sprintf('vel_T_%d',wave.T);
    fig_d=sprintf('dis_T_%d',wave.T);
    fig_P=sprintf('Power_T_%d',wave.T);
else 
    fig_v=sprintf('vel_ir_T_%d',wave.T);
    fig_d=sprintf('dis_ir_T_%d',wave.T);
    fig_P=sprintf('Power_ir_T_%d',wave.T);
end

saveas(figure(1),fig_v,'epsc')
saveas(figure(2),fig_d,'epsc')
saveas(figure(6),fig_P,'epsc')

cd ../