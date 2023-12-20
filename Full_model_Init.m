
%% wave config
clc;clear;
addpath("functions/")
T = input('Choose a period:  ');

% %% WEC-Sim
% init_T(T) % set Wave period of WEC-Sim. Default is JONSWAP spectrum with gamma = 1
% cd ../../WEC-Sim/examples/RM3/
% wecSim % run WEC-Sim
% cd ../../../MPM/RM3_ckt/JS_G1/
% WEC_filename=sprintf('JS_G1_T%d_WEC',T);
% save(WEC_filename,"waves","output","simu"); % save the WEC-Sim results
% cd ../
% close all;

%% Clear all variables except simulation parameter T
clearvars -except T
%% equivalent circuit initialization 
loadfile=sprintf('wavedata/JS_G1_T%d_WEC.mat',T); 
WEC_Sim=load(loadfile); % fetching WEC-Sim wave data
%% simulation parameter
simu.duration= WEC_Sim.simu.endTime-WEC_Sim.simu.startTime; % duration of the simualtion
simu.t_ramp = WEC_Sim.simu.rampTime; %ramp function saturation time
simu.timestep=WEC_Sim.simu.dt; %ODE4 fixed time step
simu.t=0:simu.timestep:simu.duration;
%% wave characteristic
wave.type = WEC_Sim.waves.type;
wave.T = WEC_Sim.waves.T; % wave periods 
wave.H = WEC_Sim.waves.H; % wave heights corresponding to the above periods
wave.w = 2*pi/wave.T;
wave.Tref = h5read('hydro/rm3.h5','/simulation_parameters/T');
[wave.mode.value, wave.mode.indx]=min(abs(wave.Tref./wave.T-1));
%% Instantaneous Frequnecy Calculation
wave.factor_smt=10*wave.T/simu.timestep; % moving mean filter window size
wave.instf.f=inst_f([WEC_Sim.output.wave.time WEC_Sim.output.wave.elevation]); % calculating inst_f of eta
wave.instf.f=smt(wave.instf.f,wave.factor_smt); % applying filter
wave.instf.f=[wave.instf.f(1); wave.instf.f]'; % extrapolation for first time step

%% Fixed frequency simulation
% wave.instf.f=1/wave.T*ones(length(wave.instf.f)); %fixed frequency

%% creating wave index at each time step
wave.Tcomp=zeros(length(WEC_Sim.waves.freqRange),length(simu.t));
wave.indx=zeros(1,length(simu.t));
for ii=1:length(simu.t)
wave.Tcomp(:,ii)=abs(wave.Tref.*wave.instf.f(ii)-1);
[wave.instf.values,wave.indx(ii)]=min(wave.Tcomp(:,ii));
end
%% Hydro coefficients via eigen analysis
% PTO.Bpto=1200000*0;% WEC_Sim.pto.c
Tc_param=2; % Tc_param 1.original 7th DOF is relative heave between float and spar, 2. 7th DOF heave of float
hydro=Eigenmode_v3(Tc_param); 
%% Excitation Force
hydro.Fex.all=[WEC_Sim.output.bodies(1).forceExcitation';WEC_Sim.output.bodies(2).forceExcitation'];
for ii=1:length(simu.t)
    hydro.Phi72(:,:,ii)=hydro.Phi(:,:,wave.indx(ii)); 
    hydro.Fex2(:,ii)=squeeze(hydro.Phi72(:,:,ii))'*hydro.Tc'*hydro.Fex.all(:,ii);
end
Fex_1=timeseries(squeeze(hydro.Fex2(1,:))',simu.t');
Fex_2=timeseries(squeeze(hydro.Fex2(2,:))',simu.t');
%% hydrodynamic coefficients for PTO control optimization
PTO=cal_PTO(hydro,simu.t,wave);
hydro.Z_table = Z_table(hydro,wave);
% hydro.Z_table_RM3 = Z_table_RM3(hydro);

%% Impedance matching
Z_OPT = Z_match(hydro,wave,simu);
% Z_OPT_fixed = Z_match_fixedf(hydro,wave);
% Z_OPT_RM3 = Z_match_RM3(hydro,wave,simu);
% 
% filename=sprintf('Z_OPT_T%d',T);
% save(filename,"Z_OPT_RM3")

% disp(Z_OPT_RM3.fixed.K_pto)
% %% run and save
% out=sim("inst_T.slx");
% filename=sprintf('JS_G1/JS_G1_T%d_ckt',T);
% save(filename,"out","hydro")
%%  Linear Generator PTO-Sim  
%%Note you need to import the timeseries data from F_ex.mat into the current workspace 
% and then run this script.
ptosim = ptoSimClass('Direct Drive Linear Generator');
%% Linear Generator

ptosim.pmLinearGenerator.Rs = 4.58;                   % Winding resistance [ohm]
ptosim.pmLinearGenerator.Bfric = -100;                % Friction coefficient
ptosim.pmLinearGenerator.tau_p = 0.072;               % Magnet pole pitch [m]
ptosim.pmLinearGenerator.lambda_fd = 8;               % Flux linkage of the stator d winding due to flux produced by the rotor magnets [Wb-turns]
                                                      % (recognizing that the d-axis is always aligned with the rotor magnetic axis)                                                                                                                    
ptosim.pmLinearGenerator.Ls = 0.285;                  % Inductance of the coil [H]
ptosim.pmLinearGenerator.theta_d_0 = 0;
ptosim.pmLinearGenerator.lambda_sq_0 = 0;
ptosim.pmLinearGenerator.lambda_sd_0 = ptosim.pmLinearGenerator.lambda_fd;
ptosim.pmLinearGenerator.Rload = 0.5;                 % Load Resistance [ohm]

ptosim.pmLinearGenerator.fsw=100e3;
ptosim.pmLinearGenerator.BWi=2*pi*ptosim.pmLinearGenerator.fsw*0.01;



% %% plotting
% run("plotting_vs_WECSIm/plotting_7th_heaveoffloat.m")
% %% plot PTO params
% figure()
% plot(2*pi./wave.Tref,hydro.Z_table_RM3.Cpto_opt_reactive/1000000,'LineWidth',3)
% grid on
% xlabel('Frequency (rad/s)')
% ylabel('Stiffnees (MN/m)')
% xlim([0,2])
% ax = gca;
% ax.FontSize = 48;
% ax.XAxis.FontSize = 36;
% ax.YAxis.FontSize = 36;
% wdw = gcf;
% wdw.Position = [0, 661, 1920, 920];
% set(gca, 'LineWidth', 2);