function [Fex7,M7,K_hs7,B_rad7,wave] = const_hydro(filename, Tc, bodyPair)

    if nargin < 3 || isempty(bodyPair)
        bodyPair = [1 2];
    end
    body1 = bodyPair(1);
    body2 = bodyPair(2);

    %%% wave characteristic
    wave.T = h5read(filename,'/simulation_parameters/T'); % wave periods 
    wave.w = 2*pi./wave.T;

    %%% Excitation Force Coefficients
    details.Fex_b1.re=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/re', body1));
    details.Fex_b1.im=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/im', body1));
    details.Fex_b2.re=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/re', body2));
    details.Fex_b2.im=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/im', body2));
    Fex_b1=complex(details.Fex_b1.re,details.Fex_b1.im);
    Fex_b2=complex(details.Fex_b2.re,details.Fex_b2.im);
    nfreq = size(Fex_b1, 1);
    Fex7=zeros(nfreq,7,1);
    for ii=1:nfreq
    details.Fex(ii,:,:) = [squeeze(Fex_b1(ii,:,:)); squeeze(Fex_b2(ii,:,:))];
    Fex7(ii,:,:) = squeeze(details.Fex(ii,:,:))*Tc;
    end
    

    %%% Mass matrice
    details.M.m_a_f=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/added_mass/all', body1)); % added mass, float
    details.M.m_a_s=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/added_mass/all', body2)); % added mass, spar
    
    details.M.mass_f = 1000*h5read(filename, sprintf('/body%d/properties/disp_vol', body1)); % Mass, float
    details.M.mass_s = 1000*h5read(filename, sprintf('/body%d/properties/disp_vol', body2)); % Mass, spar
    
    % moment of inertia
    details.M.MoI_f = [20907301 21306090.66 37085481.11]*1000;
    details.M.MoI_s = [94419614.57 94407091.24 28542224.82]*1000;
    
    details.M.m_f = [diag([details.M.mass_f details.M.mass_f details.M.mass_f details.M.MoI_f]);zeros(6,6)];
    details.M.m_s = [zeros(6,6);diag([details.M.mass_s details.M.mass_s details.M.mass_s details.M.MoI_s])];
    details.M.M_f = zeros(nfreq,12,6);
    details.M.M_s = zeros(nfreq,12,6);
    details.M.Mass = zeros(nfreq,12,12);
    details.M_add7 = zeros(nfreq,12,12);
    M7 = zeros(nfreq,7,7);
    M_add7 = zeros(nfreq,7,7);
    for ii=1:nfreq
    details.M.M_f(ii,:,:) = details.M.m_f+squeeze(details.M.m_a_f(ii,:,:));
    details.M.M_s(ii,:,:) = details.M.m_s+squeeze(details.M.m_a_s(ii,:,:));
    details.M.Mass(ii,:,:) = [squeeze(details.M.M_f(ii,1:6,:)) zeros(6,6);zeros(6,6) squeeze(details.M.M_s(ii,7:12,:))];
    details.M_add(ii,:,:) = [squeeze(details.M.m_a_f(ii,1:6,:)) zeros(6,6);zeros(6,6) squeeze(details.M.m_a_s(ii,7:12,:))];
    M7(ii,:,:) = Tc'*squeeze(details.M.Mass(ii,:,:))*Tc;
    M_add7(ii,:,:) = Tc'*squeeze(details.M_add(ii,:,:))*Tc;
    end
    wave.M_add7=M_add7;
     %%% K matrice(Restoring Force Coefficients)
    
    details.K.f = 1000*9.81*h5read(filename, sprintf('/body%d/hydro_coeffs/linear_restoring_stiffness', body1)); % Linear restoring coefficient, Body 1
    details.K.s = 1000*9.81*h5read(filename, sprintf('/body%d/hydro_coeffs/linear_restoring_stiffness', body2)); % Linear restoring coefficient, Body 2
    details.K.K_hs = [details.K.f zeros(size(details.K.f));zeros(size(details.K.s)) details.K.s];
    K_hs7 = Tc'*details.K.K_hs*Tc;

    %%% B matrice(Radiation Damping Coeffcients)
    
    details.B.nf = h5read(filename, sprintf('/body%d/hydro_coeffs/radiation_damping/all', body1));
    details.B.ns = h5read(filename, sprintf('/body%d/hydro_coeffs/radiation_damping/all', body2));
    
    details.B.B_f = zeros(nfreq,12,6);
    details.B.B_s = zeros(nfreq,12,6);
    details.B.B_rad = zeros(nfreq,12,12);
    
    B_rad7 = zeros(nfreq,7,7);
    
    for ii=1:nfreq
    details.B.B_f(ii,:,:) = 1000*wave.w(ii)*details.B.nf(ii,:,:); % radiation for all frequencies
    details.B.B_s(ii,:,:) = 1000*wave.w(ii)*details.B.ns(ii,:,:); % radiation for all frequencies
    % details.B.B_rad(ii,:,:) = [squeeze(details.B.B_f(ii,:,:)) squeeze(details.B.B_s(ii,:,:))];
    details.B.B_rad(ii,:,:) = ...
    [squeeze(details.B.B_f(ii,1:6,:)) zeros(6,6); ... 
     zeros(6,6)    squeeze(details.B.B_s(ii,7:12,:))];
    B_rad7(ii,:,:) = Tc'*squeeze(details.B.B_rad(ii,:,:))*Tc;
    end
