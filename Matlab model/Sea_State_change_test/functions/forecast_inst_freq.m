function instantaneous_values = forecast_inst_freq_full(t, eta, window_size)
% FORECAST_INST_FREQ_FULL  Instantaneous frequency via centered ST-HT 
% and full-signal Hilbert for edge regions
%
%   instantaneous_values.inst_freq – Nx1 vector of estimated frequency (Hz)
%
%   Uses the centered short-time Hilbert‐transform for all points
%   where a full window exists, and falls back to the full-signal
%   analytic-signal estimate at the start/end where the centered window
%   would run off the data.

N      = length(t);
half_w = floor(window_size/2);
inst_freq = nan(N,1);

% 1) Compute full‐signal analytic phase & derivative
x_full      = hilbert(eta);
phase_full  = unwrap(angle(x_full));
dphi_full   = gradient(phase_full, t);
inst_full   = dphi_full / (2*pi);

% 2) Centered ST-HT where full window is available
for ii = half_w+1 : N-half_w
    idx        = (ii-half_w):(ii+half_w);
    window_t   = t(idx);
    window_eta = eta(idx);

    x_a   = hilbert(window_eta);
    phase = angle(x_a);
    dphi_dt = gradient(unwrap(phase), window_t);

    inst_freq(ii) = dphi_dt(half_w+1) / (2*pi);
end

% 3) Fill start/end with full‐signal estimate
inst_freq(1:half_w)         = inst_full(1:half_w);
inst_freq(N-half_w+1:N)     = inst_full(N-half_w+1:N);

instantaneous_values.inst_freq = inst_freq;
end

