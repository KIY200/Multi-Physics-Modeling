%% equivalent circuit initialization 
WEC_Sim=load('current.mat');
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
wave.Tcomp=abs(wave.Tref./wave.T-1);
wave.indx=find(wave.Tcomp==min(wave.Tcomp),1);
%% 
PTO.Bpto=WEC_Sim.pto.c;
hydro=Eigenmode_v2(PTO.Bpto);

%% Excitation Force
hydro.Phi72=squeeze(hydro.Phi(:,:,wave.indx));

% %%% regular wave
% if wave.type=="regular"
%     % Excitation coefficient 
%     hydro.Fex.f_re_all = 1000*h5read('hydro/rm3.h5','/body1/hydro_coeffs/excitation/re'); % real coeff, excitation, all freq, Body 1
%     hydro.Fex.f_im_all = 1000*h5read('hydro/rm3.h5','/body1/hydro_coeffs/excitation/im'); % imaginary coeff, excitation, all freq, Body 1
%     hydro.Fex.f_re = 9.81*0.5*squeeze(hydro.Fex.f_re_all(wave.indx,:,:)+hydro.Fex.f_re_all(wave.indx-1,:,:)); %real of excitation coeff. for wave.T, body 1
%     hydro.Fex.f_im = 9.81*0.5*squeeze(hydro.Fex.f_im_all(wave.indx,:,:)+hydro.Fex.f_im_all(wave.indx-1,:,:)); %imag of excitation coeff. for wave.T, body 1
%     hydro.Fex.s_re_all = 1000*h5read('hydro/rm3.h5','/body2/hydro_coeffs/excitation/re'); % real coeff, excitation, all freq, Body 2
%     hydro.Fex.s_im_all = 1000*h5read('hydro/rm3.h5','/body2/hydro_coeffs/excitation/im'); % imaginary coeff, excitation, all freq, Body 2
%     hydro.Fex.s_re = 9.81*0.5*squeeze(hydro.Fex.s_re_all(wave.indx,:,:)+hydro.Fex.s_re_all(wave.indx-1,:,:)); %real of excitation coeff. for wave.T, body 2
%     hydro.Fex.s_im = 9.81*0.5*squeeze(hydro.Fex.s_im_all(wave.indx,:,:)+hydro.Fex.s_im_all(wave.indx-1,:,:)); %imag of excitation coeff. for wave.T, body 2
%     
%     % ramp function
%     hydro.Ramp.fct = ones(1,size(simu.t,2));
%     hydro.Ramp.t_index = find(simu.t_ramp<=simu.t,1);
%     hydro.Ramp.fct(1,1:hydro.Ramp.t_index) = 0.5*(1+cos(pi+pi/simu.t_ramp.*simu.t(1:hydro.Ramp.t_index)));
%     
%     % Exictation Force timeseries
%     simu.wt = simu.t.*wave.w;
%     hydro.Fex.f = hydro.Ramp.fct.*real(0.5*(wave.H*exp(1i*simu.wt).*complex(hydro.Fex.f_re,hydro.Fex.f_im)));
%     hydro.Fex.s = hydro.Ramp.fct.*real(0.5*(wave.H*exp(1i*simu.wt).*complex(hydro.Fex.s_re,hydro.Fex.s_im)));
%     hydro.Fex.all = [hydro.Fex.f;hydro.Fex.s];
%     
%     % DOF reduction
%     hydro.Fex2 = hydro.Phi72'*hydro.Tc'*hydro.Fex.all;
%     Fex_f=timeseries(squeeze(hydro.Fex2(1,:))',simu.t');
%     Fex_s=timeseries(squeeze(hydro.Fex2(2,:))',simu.t');
% 
% %%% irregular wave
% else 
    hydro.Fex.all=[WEC_Sim.output.bodies(1).forceExcitation';WEC_Sim.output.bodies(2).forceExcitation'];
    hydro.Fex2=hydro.Phi72'*hydro.Tc'*hydro.Fex.all;
    Fex_1=timeseries(squeeze(hydro.Fex2(1,:))',simu.t');
    Fex_2=timeseries(squeeze(hydro.Fex2(2,:))',simu.t');
% end

%% PTO control
PTO.Rs=4.58;
PTO.Ls=0.258;
PTO.pp=87.266*0.5;
PTO.lambda=8;
PTO.fsw=10e3;
PTO.wi=2*pi*PTO.fsw*0.1;
PTO.Y_star=1.2e6;
PTO.Rload=0.5;

PTO.Bpto22 = squeeze(hydro.Bpto22(:,:,wave.indx)); % PTO damping coefficient

PTO.Mass = squeeze(hydro.Mass_22(:,:,wave.indx));
PTO.K_hs = squeeze(hydro.K_hs_22(:,:,wave.indx));
PTO.B_rad22 = squeeze(hydro.B_rad_22(:,:,wave.indx));
PTO.B22 = squeeze(hydro.B22(:,:,wave.indx));

% %%resistor coupling model
% PTO.R1 = 1/(PTO.B_rad22(1,1)+PTO.B_rad22(1,2)+PTO.Bpto22(1,1)+PTO.Bpto22(1,2));
% PTO.R2 = 1/(PTO.B_rad22(2,2)+PTO.B_rad22(2,1)+PTO.Bpto22(2,2)+PTO.Bpto22(2,1));

PTO.Mass_b1 = hydro.Mass_22(1,1,wave.indx);
PTO.Mass_b2 = hydro.Mass_22(2,2,wave.indx);
PTO.K_hs_b1 = hydro.K_hs_22(1,1,wave.indx);
PTO.K_hs_b2 = hydro.K_hs_22(2,2,wave.indx);
PTO.B_rad_b1 = hydro.B_rad_22(1,1,wave.indx);
PTO.B_rad_b2 = hydro.B_rad_22(2,2,wave.indx);

%% Impedance matching
PTO.Rf = 1/PTO.B_rad_b1;
PTO.Rs = 1/PTO.B_rad_b2;
PTO.X_Lf = 1/PTO.K_hs_b1*1j*wave.w;
PTO.X_Ls = 1/PTO.K_hs_b2*1j*wave.w;
PTO.X_Cf = 1/(PTO.Mass_b1*1j*wave.w);
PTO.X_Cs = 1/(PTO.Mass_b2*1j*wave.w);

PTO.Zf = 1/(1/PTO.Rf+1/PTO.X_Lf+1/PTO.X_Cf);
PTO.Zs = 1/(1/PTO.Rs+1/PTO.X_Ls+1/PTO.X_Cs);

PTO.Z_eq = PTO.Zf+PTO.Zs;
PTO.Y_eq = 1/PTO.Z_eq;
PTO.Y_pto = conj(PTO.Y_eq);

PTO.R_pto = 1/real(PTO.Y_pto);
PTO.C_pto = abs(imag(PTO.Y_pto)/wave.w);
PTO.L_pto = 1/abs(imag(PTO.Y_pto)*wave.w);

PTO.R_opt = 1/abs(PTO.Y_pto);