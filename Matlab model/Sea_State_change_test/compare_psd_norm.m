function compare_psd_norm(eta, fs, smooth_win)
    % Usage:
    %   compare_psd_norm(eta, fs)
    %   compare_psd_norm(eta, fs, smooth_win)
    if nargin<3, smooth_win = 50; end

    N = length(eta);
    durations = [N, 2^nextpow2(N)];
    labels = {'No zero–pad (Tn=N)', 'Zero–pad to next pow2'};

    fprintf('\nComparing PSD normalizations:\n');
    for k = 1:2
        Tn = durations(k);
        % FFT
        Y = fft(eta, Tn);

        % OLD normalization (missing fs)
        P2_old = (1/Tn)*abs(Y).^2;
        P1_old = P2_old(1:Tn/2+1);
        P1_old(2:end-1) = 2*P1_old(2:end-1);

        % NEW normalization (with fs)
        P2_new = (1/(fs*Tn))*abs(Y).^2;
        P1_new = P2_new(1:Tn/2+1);
        P1_new(2:end-1) = 2*P1_new(2:end-1);

        % frequency vector
        f = (0:(Tn/2))*(fs/Tn);

        % smooth
        S_old = movmean(P1_old, smooth_win);
        S_new = movmean(P1_new, smooth_win);

        % skip DC for moment m_-1
        idx = f>0;
        fpos = f(idx);
        Sold = S_old(idx);
        Snew = S_new(idx);

        % total variance = ∫S df = m0
        m0_old = trapz(fpos, Sold);
        m0_new = trapz(fpos, Snew);
        % peak
        peak_old = max(Sold);
        peak_new = max(Snew);

        fprintf('\n  %s:\n', labels{k});
        fprintf('    • ∫PSD_old df = %g (m^2)\n', m0_old);
        fprintf('    • ∫PSD_new df = %g (m^2)\n', m0_new);
        fprintf('    • peak PSD_old = %g (m^2/Hz)\n', peak_old);
        fprintf('    • peak PSD_new = %g (m^2/Hz)\n', peak_new);
    end
    plot(fpos,Sold,fpos,Snew)
end
