function [Phi, eigen] = eigsolve_hydro(M7, K_hs7, wave_w)
% Compute dominant eigenmodes for each frequency.

    nfreq = size(M7, 1);
    ndof = size(M7, 2);

    eigen.V = zeros(nfreq, ndof, ndof);
    eigen.D = zeros(nfreq, ndof, ndof);

    for ii = 1:nfreq
        [eigen.V(ii,:,:), eigen.D(ii,:,:)] = eig(K_hs7, squeeze(M7(ii,:,:)));
    end

    eigen.E = zeros(nfreq, 1, ndof);
    for ii = 1:nfreq
        eigen.E(ii,:,:) = diag(squeeze(eigen.D(ii,:,:)));
    end

    eigen.E(abs(eigen.E) < 1e-3) = 0;
    eigen.E = squeeze(eigen.E);

    w_struc = sqrt(abs(eigen.E));
    Phi = zeros(nfreq, ndof, 2);

    for ii = 1:nfreq
        temp = abs(w_struc(ii,:) - wave_w(1,ii));
        [~, inx] = mink(temp, 2);
        Phi(ii,:,1) = abs(eigen.V(ii,:,inx(1)));
        Phi(ii,:,2) = abs(eigen.V(ii,:,inx(2)));
    end
end
