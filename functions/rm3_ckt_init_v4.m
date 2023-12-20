clc;clear;
%% equivalent circuit initialization 
for jj=1
% loadfile=sprintf('output/case_%d.mat',jj);
loadfile=sprintf('ECCE/input/case_%d.mat',jj);
% loadfile='ECCE_PTO';
% loadfile='ECCE/input/ECCE_reg_T8.mat';

WEC_Sim=load(loadfile);
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
%% Instantaneous Frequnecy Calculation
wave.factor_smt=10*wave.T/simu.timestep;
wave.instf.f=inst_f([WEC_Sim.output.wave.time WEC_Sim.output.wave.elevation]);
wave.instf.f=smt(wave.instf.f,wave.factor_smt);
wave.instf.f=[wave.instf.f(1); wave.instf.f]';
wave.Tcomp=zeros(length(WEC_Sim.waves.freqRange),length(simu.t));
wave.indx=zeros(1,length(simu.t));
%% fixed frequency simulation
wave.instf.f=1/wave.T*ones(length(wave.instf.f)); %fixed frequency test
for ii=1:length(simu.t)
wave.Tcomp(:,ii)=abs(wave.Tref.*wave.instf.f(ii)-1);
[wave.instf.values,wave.indx(ii)]=min(wave.Tcomp(:,ii));
end
%% Hydro coefficients
PTO.Bpto=1200000*0;%*WEC_Sim.pto.c
hydro=Eigenmode_v3(PTO.Bpto);
%% Excitation Force
hydro.Fex.all=[WEC_Sim.output.bodies(1).forceExcitation';WEC_Sim.output.bodies(2).forceExcitation'];
for ii=1:length(simu.t)
hydro.Phi72(:,:,ii)=hydro.Phi(:,:,wave.indx(ii)); 
    hydro.Fex2(:,ii)=squeeze(hydro.Phi72(:,:,ii))'*hydro.Tc'*hydro.Fex.all(:,ii);
end
    Fex_1=timeseries(squeeze(hydro.Fex2(1,:))',simu.t');
    Fex_2=timeseries(squeeze(hydro.Fex2(2,:))',simu.t');
%% exp2
for ii=1:length(simu.t)
% PTO.Bpto22(:,:,ii) = hydro.Bpto22(:,:,wave.indx(ii)); % PTO damping coefficient
PTO.Mass(:,:,ii) = hydro.Mass_22(:,:,wave.indx(ii));
PTO.K_hs(:,:,ii) = hydro.K_hs_22(:,:,wave.indx(ii));
PTO.B_rad22(:,:,ii) = hydro.B_rad_22(:,:,wave.indx(ii));
PTO.B22(:,:,ii) = hydro.B22(:,:,wave.indx(ii));
end
%%
PTO.Mass_b1 = squeeze(PTO.Mass(1,1,:));
PTO.Mass_b2 = squeeze(PTO.Mass(2,2,:));
PTO.K_hs_b1 = squeeze(PTO.K_hs(1,1,:));
PTO.K_hs_b2 = squeeze(PTO.K_hs(2,2,:));
PTO.B_rad_b1 = squeeze(PTO.B_rad22(1,1,:));
PTO.B_rad_b2 = squeeze(PTO.B_rad22(2,2,:));

PTO.R1=timeseries(1./PTO.B_rad_b1,simu.t');
PTO.R2=timeseries(1./PTO.B_rad_b2,simu.t');
PTO.L1=timeseries(1./PTO.K_hs_b1,simu.t');
PTO.L2=timeseries(1./PTO.K_hs_b2,simu.t');
PTO.C1=timeseries(PTO.Mass_b1,simu.t');
PTO.C2=timeseries(PTO.Mass_b2,simu.t');

%% Impedance matching
Z_OPT = Z_match(PTO,wave,simu);

Z_OPT_fixed = load('fixed_Z_case1.mat');
Z_OPT_fixed = Z_OPT_fixed.PTO;
% %% run and save
% out=sim("inst_T.slx");
% % cd inst_T/
% cd Fixed_T/
% % save(['case_',num2str(jj)],"out","hydro")
% save('ECCE_PTO_modified_reg_T8',"out","hydro")
% cd ..
end