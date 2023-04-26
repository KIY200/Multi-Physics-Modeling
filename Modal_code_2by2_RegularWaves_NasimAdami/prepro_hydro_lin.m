function [d,M_b1,M_b2,b1_Ma,b2_Ma,b1_Res,b2_Res,b1_C_rad,b2_C_rad,b1_cg,b2_cg,b1_Ex_re,b1_Ex_im,b2_Ex_re,b2_Ex_im,w] = prepro_hydro_lin(T_wave)
% A function that is called once to load all the general and hydrodynamic
% coefficients from the h5 file (output of WAMIT in the form that is 
% created by bemio (WEC-Sim)).
%
% inputs:
% T_wave : wave periods (vector)
%
% output:
% d : Distance between the CGs of two bodies (abs)
% M_b1 : Mass matrix of body 1 (float)
% M_b2 : Mass matrix of body 2 (spar)
% b1_Ma : Infinity added mass matrix of body 1 (float)
% b2_Ma : Infinity added mass matrix of body 2 (spar)
% b1_Res : Hydrostatic rtestoring coefficients of body 1 (float)
% b2_Res : Hydrostatic rtestoring coefficients of body 2 (spar)
% b1_C_rad_all : Radiation damping coefficients of body 1 (float) for all frequencies
% b2_C_rad_all : Radiation damping coefficients of body 2 (spar) for all frequencies
% b1_cg : CG of body 1 (float)
% b2_cg : CG of body 2 (spar)
% b1_Ex_re : Real excitation coefficients of body 1 (float) for all input wave component frequencies 
% b1_Ex_im : Imaginary excitation coefficients of body 1 (float) for all input wave component frequencies
% b2_Ex_re : Real excitation coefficients of body 2 (spar) for all input wave component frequencies
% b2_Ex_im : Imaginary excitation coefficients of body 2 (spar) for all input wave component frequencies
% w : WAMIT analysis angular frequencies 




b1_mass = 1000*h5read('hydro\rm3.h5','/body1/properties/disp_vol'); %Mass, Body 1
b2_mass = 1000*h5read('hydro\rm3.h5','/body2/properties/disp_vol'); % Mass, Body 2

%center of gravity and bouyancy

b1_cb = h5read('hydro\rm3.h5','/body1/properties/cb'); %Center of bouyancy, Body 1
b2_cb = h5read('hydro\rm3.h5','/body2/properties/cb'); %Center of bouyancy, Body 2

b1_cg = h5read('hydro\rm3.h5','/body1/properties/cg'); %Center of gravity, Body 1
b2_cg = h5read('hydro\rm3.h5','/body2/properties/cg'); %Center of gravity, Body 2

%Center of gravity distance 

d = abs(b1_cg(3)-b2_cg(3));

% moment of inertia

b1_MoI = 1000*[20907301 21306090.66 37085481.11];
b2_MoI =1000* [94419614.57 94407091.24 28542224.82];

M_b1 = zeros(6,6);
M_b1(1,1)=b1_mass;M_b1(2,2)=b1_mass;M_b1(3,3)=b1_mass;
M_b1(4,4)=b1_MoI(1);M_b1(5,5)=b1_MoI(2);M_b1(6,6)=b1_MoI(3);

M_b2 = zeros(6,6);
M_b2(1,1)=b2_mass;M_b2(2,2)=b2_mass;M_b2(3,3)=b2_mass;
M_b2(4,4)=b2_MoI(1);M_b2(5,5)=b2_MoI(2);M_b2(6,6)=b2_MoI(3);

%general simulation parameter 
w = h5read('hydro\rm3.h5','/simulation_parameters/w'); % Angular frequencies (from WAMIT)
T = 2*pi./w;

%find the index for frequancy interpolation
% for ii=1:length(T_wave)
%     index1(ii) = find(T<T_wave(ii),1); %finding the closest index to the wave period
% end

% Excitation coefficient 

b1_Ex_re_all = 1000*h5read('hydro\rm3.h5','/body1/hydro_coeffs/excitation/re'); % real coeff, excitation, all freq, Body 1
b1_Ex_im_all = 1000*h5read('hydro\rm3.h5','/body1/hydro_coeffs/excitation/im'); % imaginary coeff, excitation, all freq, Body 1

%%% plotting excitation coeffs's abs values (from WAMIT) for float in 6DOF

figure

plot(T,(squeeze(b1_Ex_re_all(:,:,1))))
hold on
plot(T,abs(squeeze(b1_Ex_re_all(:,:,2))))
plot(T,abs(squeeze(b1_Ex_re_all(:,:,3))))
plot(T,abs(squeeze(b1_Ex_re_all(:,:,4))))
plot(T,abs(squeeze(b1_Ex_re_all(:,:,5))))
plot(T,abs(squeeze(b1_Ex_re_all(:,:,6))))

for ii=1:length(T_wave)
    b1_Ex_re(ii,:,:) = 9.81*interp1(T,b1_Ex_re_all,T_wave(ii),'spline');
    
    b1_Ex_im(ii,:,:) = 9.81*interp1(T,b1_Ex_im_all,T_wave(ii),'spline');
   
end

b1_Ex_re = b1_Ex_re';
b1_Ex_im = b1_Ex_im';

b2_Ex_re_all =1000*h5read('hydro\rm3.h5','/body2/hydro_coeffs/excitation/re'); % real coeff, excitation, all freq, Body 2
b2_Ex_im_all =1000*h5read('hydro\rm3.h5','/body2/hydro_coeffs/excitation/im'); % imaginary coeff, excitation, all freq, Body 2

%%% plotting excitation coeffs's abs values (from WAMIT) for spar in 6DOF

figure

plot(T,abs(squeeze(b2_Ex_re_all(:,:,1))))
hold on
plot(T,abs(squeeze(b2_Ex_re_all(:,:,2))))
plot(T,abs(squeeze(b2_Ex_re_all(:,:,3))))
plot(T,abs(squeeze(b2_Ex_re_all(:,:,4))))
plot(T,abs(squeeze(b2_Ex_re_all(:,:,5))))
plot(T,abs(squeeze(b2_Ex_re_all(:,:,6))))





for ii=1:length(T_wave)
    b2_Ex_re(ii,:,:) = 9.81*interp1(T,b2_Ex_re_all,T_wave(ii),'spline');
    
    b2_Ex_im(ii,:,:) = 9.81*interp1(T,b2_Ex_im_all,T_wave(ii),'spline');
   
end

b2_Ex_re = b2_Ex_re';
b2_Ex_im = b2_Ex_im';

%added mass
b1_Ma_all = 1000*h5read('hydro\rm3.h5','/body1/hydro_coeffs/added_mass/all'); % infty added mass, Body 1
b2_Ma_all = 1000*h5read('hydro\rm3.h5','/body2/hydro_coeffs/added_mass/all'); % infty added mass, Body 2


for ii=1:length(T_wave)
    b1_Ma(ii,:,:) = interp1(T,b1_Ma_all,T_wave(ii),'spline'); %radiation damping for wave.T, body 1
    b2_Ma(ii,:,:) = interp1(T,b2_Ma_all,T_wave(ii),'spline'); %radiation damping for wave.T, body 1
end

% Linear restoring coefficient
b1_Res = 1000*9.806*h5read('hydro\rm3.h5','/body1/hydro_coeffs/linear_restoring_stiffness'); % Linear restoring coefficient, Body 1
b2_Res = 1000*9.806*h5read('hydro\rm3.h5','/body2/hydro_coeffs/linear_restoring_stiffness'); % Linear restoring coefficient, Body 2

% Radiation damping coefficients

b1_C_rad_all = 2*pi/T_wave*1000*h5read('hydro\rm3.h5','/body1/hydro_coeffs/radiation_damping/all'); % radiation for all frequencies
b2_C_rad_all = 2*pi/T_wave*1000*h5read('hydro\rm3.h5','/body2/hydro_coeffs/radiation_damping/all'); % radiation for all frequencies

for ii=1:length(T_wave)
    b1_C_rad(ii,:,:) = interp1(T,b1_C_rad_all,T_wave(ii),'spline'); %radiation damping for wave.T, body 1
    b2_C_rad(ii,:,:) = interp1(T,b2_C_rad_all,T_wave(ii),'spline'); %radiation damping for wave.T, body 1
end
end
