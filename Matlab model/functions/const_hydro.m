function [Fex7,M7,K_hs7,B_rad7,wave] = const_hydro(Tc)

    %%% wave characteristic
    wave.T = h5read('hydro/rm3.h5','/simulation_parameters/T'); % wave periods 
    wave.H = 2; % wave heights corresponding to the above periods
    wave.w = 2*pi./wave.T;

    %%% Excitation Force Coefficients
    details.Fex_b1.re=1000*h5read('hydro/rm3.h5','/body1/hydro_coeffs/excitation/re');
    details.Fex_b1.im=1000*h5read('hydro/rm3.h5','/body1/hydro_coeffs/excitation/im');
    details.Fex_b2.re=1000*h5read('hydro/rm3.h5','/body2/hydro_coeffs/excitation/re');
    details.Fex_b2.im=1000*h5read('hydro/rm3.h5','/body2/hydro_coeffs/excitation/im');
    Fex_b1=complex(details.Fex_b1.re,details.Fex_b1.im);
    Fex_b2=complex(details.Fex_b1.re,details.Fex_b1.im);
    Fex7=zeros(260,7,1);
    for ii=1:260 
    details.Fex(ii,:,:) = [squeeze(Fex_b1(ii,:,:)); squeeze(Fex_b2(ii,:,:))];
    Fex7(ii,:,:) = squeeze(details.Fex(ii,:,:))*Tc;
    end
    

    %%% Mass matrice
    details.M.m_a_f=1000*h5read('hydro/rm3.h5','/body1/hydro_coeffs/added_mass/all'); % added mass, float
    details.M.m_a_s=1000*h5read('hydro/rm3.h5','/body2/hydro_coeffs/added_mass/all'); % added mass, spar
    
    details.M.mass_f = 1000*h5read('hydro/rm3.h5','/body1/properties/disp_vol'); % Mass, float
    details.M.mass_s = 1000*h5read('hydro/rm3.h5','/body2/properties/disp_vol'); % Mass, spar
    
    % moment of inertia
    details.M.MoI_f = [20907301 21306090.66 37085481.11]*1000;
    details.M.MoI_s = [94419614.57 94407091.24 28542224.82]*1000;
    
    details.M.m_f = [diag([details.M.mass_f details.M.mass_f details.M.mass_f details.M.MoI_f]);zeros(6,6)];
    details.M.m_s = [zeros(6,6);diag([details.M.mass_s details.M.mass_s details.M.mass_s details.M.MoI_s])];
    details.M.M_f = zeros(260,12,6);
    details.M.M_s = zeros(260,12,6);
    details.M.Mass = zeros(260,12,12);
    M7 = zeros(260,7,7);
    
    for ii=1:260
    details.M.M_f(ii,:,:) = details.M.m_f+squeeze(details.M.m_a_f(ii,:,:));
    details.M.M_s(ii,:,:) = details.M.m_s+squeeze(details.M.m_a_s(ii,:,:));
    details.M.Mass(ii,:,:) = [squeeze(details.M.M_f(ii,1:6,:)) zeros(6,6);zeros(6,6) squeeze(details.M.M_s(ii,7:12,:))];
    M7(ii,:,:) = Tc'*squeeze(details.M.Mass(ii,:,:))*Tc;
    end

     %%% K matrice(Restoring Force Coefficients)
    
    details.K.f = 1000*9.81*h5read('hydro/rm3.h5','/body1/hydro_coeffs/linear_restoring_stiffness'); % Linear restoring coefficient, Body 1
    details.K.s = 1000*9.81*h5read('hydro/rm3.h5','/body2/hydro_coeffs/linear_restoring_stiffness'); % Linear restoring coefficient, Body 2
    details.K.K_hs = [details.K.f zeros(size(details.K.f));zeros(size(details.K.s)) details.K.s];
    K_hs7 = Tc'*details.K.K_hs*Tc;

    %%% B matrice(Radiation Damping Coeffcients)
    
    details.B.nf = h5read('hydro/rm3.h5','/body1/hydro_coeffs/radiation_damping/all');
    details.B.ns = h5read('hydro/rm3.h5','/body2/hydro_coeffs/radiation_damping/all');
    
    details.B.B_f = zeros(260,12,6);
    details.B.B_s = zeros(260,12,6);
    details.B.B_rad = zeros(260,12,12);
    
    B_rad7 = zeros(260,7,7);
    
    for ii=1:260
    details.B.B_f(ii,:,:) = 1000*wave.w(ii)*details.B.nf(ii,:,:); % radiation for all frequencies
    details.B.B_s(ii,:,:) = 1000*wave.w(ii)*details.B.ns(ii,:,:); % radiation for all frequencies
    % details.B.B_rad(ii,:,:) = [squeeze(details.B.B_f(ii,:,:)) squeeze(details.B.B_s(ii,:,:))];
    details.B.B_rad(ii,:,:) = ...
    [squeeze(details.B.B_f(ii,1:6,:)) zeros(6,6); ... 
     zeros(6,6)    squeeze(details.B.B_s(ii,7:12,:))];
    B_rad7(ii,:,:) = Tc'*squeeze(details.B.B_rad(ii,:,:))*Tc;
    end