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
    % Expected layout from WAMIT export: nfreq x 1 x 6
    details.Fex_b1.re = permute(details.Fex_b1.re, [3 2 1]);
    details.Fex_b1.im = permute(details.Fex_b1.im, [3 2 1]);
    details.Fex_b2.re = permute(details.Fex_b2.re, [3 2 1]);
    details.Fex_b2.im = permute(details.Fex_b2.im, [3 2 1]);
    Fex_b1=complex(details.Fex_b1.re,details.Fex_b1.im);
    Fex_b2=complex(details.Fex_b2.re,details.Fex_b2.im);
    nfreq = size(Fex_b1, 3);
    details.Fex = zeros(nfreq,12,1);
    Fex7=zeros(nfreq,7,1);
    for ii=1:nfreq
        f1 = squeeze(Fex_b1(:,1,ii));
        f2 = squeeze(Fex_b2(:,1,ii));
        F = [f1; f2];
        details.Fex(ii,:,1) = F;
        Fex7(ii,:,1) = (Tc' * F).';
    end
    

    %%% Mass matrice
    details.M.m_a_f=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/added_mass/all', body1)); % added mass, float
    details.M.m_a_s=1000*h5read(filename, sprintf('/body%d/hydro_coeffs/added_mass/all', body2)); % added mass, spar
    % Expected layout: nfreq x 24 x 6 -> permute to 6 x 24 x nfreq
    details.M.m_a_f = permute(details.M.m_a_f, [3 2 1]);
    details.M.m_a_s = permute(details.M.m_a_s, [3 2 1]);
    
    details.M.mass_f = 1000*h5read(filename, sprintf('/body%d/properties/disp_vol', body1)); % Mass, float
    details.M.mass_s = 1000*h5read(filename, sprintf('/body%d/properties/disp_vol', body2)); % Mass, spar
    
    % moment of inertia
    details.M.MoI_f = [66.1686 65.3344 17.16];
    details.M.MoI_s = [253.6344  250.4558 12.746];
    
    details.M.M_rigid = blkdiag( ...
        diag([details.M.mass_f details.M.mass_f details.M.mass_f details.M.MoI_f]), ...
        diag([details.M.mass_s details.M.mass_s details.M.mass_s details.M.MoI_s]) ...
    );
    details.M.Mass = zeros(nfreq,12,12);
    details.M_add = zeros(nfreq,12,12);
    M7 = zeros(nfreq,7,7);
    M_add7 = zeros(nfreq,7,7);
    cols1 = (body1-1)*6 + (1:6);
    cols2 = (body2-1)*6 + (1:6);
    for ii=1:nfreq
        m_a_f = squeeze(details.M.m_a_f(:,:,ii));
        m_a_s = squeeze(details.M.m_a_s(:,:,ii));
        m_a_f = m_a_f(:, [cols1 cols2]);
        m_a_s = m_a_s(:, [cols1 cols2]);
        details.M_add(ii,:,:) = [m_a_f; m_a_s];
        details.M.Mass(ii,:,:) = details.M.M_rigid + squeeze(details.M_add(ii,:,:));
        M7(ii,:,:) = Tc' * squeeze(details.M.Mass(ii,:,:)) * Tc;
        M_add7(ii,:,:) = Tc' * squeeze(details.M_add(ii,:,:)) * Tc;
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
    % Expected layout: nfreq x 24 x 6 -> permute to 6 x 24 x nfreq
    details.B.nf = permute(details.B.nf, [3 2 1]);
    details.B.ns = permute(details.B.ns, [3 2 1]);
    
    details.B.B_rad = zeros(nfreq,12,12);
    B_rad7 = zeros(nfreq,7,7);
    for ii=1:nfreq
        B_f = squeeze(details.B.nf(:,:,ii));
        B_s = squeeze(details.B.ns(:,:,ii));
        B_f = B_f(:, [cols1 cols2]);
        B_s = B_s(:, [cols1 cols2]);
        details.B.B_rad(ii,:,:) = 1000 * wave.w(ii) * [B_f; B_s];
        B_rad7(ii,:,:) = Tc' * squeeze(details.B.B_rad(ii,:,:)) * Tc;
    end
