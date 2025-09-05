function PSD = compute_psd_from_eta(eta, fs, smooth_win)
    if nargin<3, smooth_win = 50; end

    %--- FFT & PSD setup ---
    N   = length(eta);
    Tn  = 2^nextpow2(N);
    Y   = fft(eta, Tn);

    % Corrected periodogram normalization
    P2  = (1/(fs*Tn)) * abs(Y).^2;

    % One‐sided spectrum
    P1  = P2(1:Tn/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);

    % Frequency axis (Hz) and smoothing
    f_all = (0:(Tn/2)) * (fs/Tn);
    S_all = movmean(P1, smooth_win);

    %--- restrict to [1/15, 1] Hz (keep this band) ---
    f_low  = 1/15;
    f_high = 1;
    idx    = (f_all >= f_low) & (f_all <= f_high);
    f      = f_all(idx);
    S      = S_all(idx);

    %--- spectral moments over the [1/15,1] Hz band ---
    m_neg1 = trapz(f, S ./ f);       % ∫[S(f)/f] df
    m0     = trapz(f, S);            % ∫ S(f)    df
    m1     = trapz(f, f .* S);       % ∫ f S(f)  df
    m2     = trapz(f, (f.^2) .* S);  % ∫ f^2 S(f) df

    %--- compute characteristic periods ---
    PSD.T_energy = m_neg1 / m0;      
    PSD.T_mean   = m0     / m1;      
    PSD.T_zero   = sqrt(m0 / m2);    

    %--- return full struct ---
    PSD.f     = f;
    PSD.S     = S;
    PSD.mneg1 = m_neg1;
    PSD.m0    = m0;
    PSD.m1    = m1;
    PSD.m2    = m2;
end
