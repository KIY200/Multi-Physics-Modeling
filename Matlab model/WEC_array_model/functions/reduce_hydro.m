function hydro = reduce_hydro(M7, B_rad7, K_hs7, F7, Phi)
% Reduce full-order hydrodynamics to 2-mode representation.

    nfreq = size(M7, 1);
    Mass_22 = zeros(nfreq, 2, 2);
    B_rad_22 = zeros(nfreq, 2, 2);
    K_hs_22 = zeros(nfreq, 2, 2);
    F_ex_22 = zeros(nfreq, 1, 2);

    for ii = 1:nfreq
        Mass_22(ii,:,:) = squeeze(Phi(ii,:,:))' * squeeze(M7(ii,:,:)) * squeeze(Phi(ii,:,:));
        B_rad_22(ii,:,:) = squeeze(Phi(ii,:,:))' * squeeze(B_rad7(ii,:,:)) * squeeze(Phi(ii,:,:));
        K_hs_22(ii,:,:) = squeeze(Phi(ii,:,:))' * K_hs7 * squeeze(Phi(ii,:,:));
        F_ex_22(ii,:,:) = squeeze(F7(ii,:,:)) * squeeze(Phi(ii,:,:));
    end

    hydro.B_rad_22 = permute(B_rad_22, [2, 3, 1]);
    hydro.K_hs_22 = permute(K_hs_22, [2, 3, 1]);
    hydro.Mass_22 = permute(Mass_22, [2, 3, 1]);
    hydro.Phi = permute(Phi, [2, 3, 1]);
    hydro.F_ex_22 = permute(F_ex_22, [3, 2, 1]);
end
