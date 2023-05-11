clc;clear;
%% data load
Ystar = load("complex_conjugate.mat");
Rstar = load("Real_Impedence_matching.mat");
WEC_Sim = load("WEC_Sim_original.mat");

%% plot

% PTO power generation
figure(1)
plot(Ystar.out.Ppto./1000,'linestyle','--','color','b','linewidth',1.5);
hold on
plot(Rstar.out.Ppto./1000);
plot(WEC_Sim.out.Ppto./1000)
hold off
% title_P = sprintf('PTO power generation(equivalent circuit model error of %0.1f%%)',P_pto_error);
% title(title_P)
grid on
xlabel('time (s)')
ylabel('Power (kW)')
legend('complex conjugate','Real','original','Location','northwest')
ax=gca;
ax.FontSize=24;
ax.XAxis.FontSize=18;
ax.YAxis.FontSize=18;
ax.Legend.FontSize=16;
wdw=gcf;
wdw.Position=[0,661,1920,920]/2;
