clc; clear;
%% --- Setup once ---
location = 'hydro/floatspar.h5';
[IRF_t, FIR_causal, FIR_non_causal, Fex1_freq] = Excitation_FIR(location);
IRF_combined = [FIR_non_causal; FIR_causal];

load('lupadata_spring2024_sparD1_14m.mat');

A_const = 0.1;            
freqs    = 0.1:0.05:1.0;  % [Hz] sweep

% Preallocate
peak_ts   = zeros(size(freqs));
peak_abk  = zeros(size(freqs));
peak_conv = zeros(size(freqs));

for idx = 1:numel(freqs)
    f    = freqs(idx);
    w    = 2*pi*f;
    T    = 1/f;
    t    = linspace(0, 10*T, 1000).';  % uniform time
    dt   = t(2)-t(1);
    
    % wave series + derivatives
    eta   = A_const*sin(w*t + pi/2);
    deta  = A_const*w*cos(w*t + pi/2);
    ddeta = -A_const*w^2*sin(w*t + pi/2);
    
    % Exact from WAMIT
    [~, ix] = min((lupadata.w - w).^2);
    F_ex_w  = Fex1_freq(ix);
    F_ts    = real(A_const * abs(F_ex_w) * exp(1i*w*t));
    
    % ABK approx
    [~, m_add, B_rad, K_hs, ~, ~, ~, ~] = fn_get_lupa_params(w, lupadata);
    F_abk   = m_add*ddeta + B_rad*deta + K_hs*eta;
    
    % IRF convolution
    t_irf      = IRF_t(1):dt:IRF_t(end);
    irf        = interp1(IRF_t, IRF_combined, t_irf, 'linear', 0);
    F_conv_f   = conv(eta, irf)*dt;
    t_conv_f   = (t(1)+t_irf(1)):dt:(t(end)+t_irf(end));
    mask       = t_conv_f>=0 & t_conv_f<=10*T;
    F_conv     = F_conv_f(mask);
    
    % record peaks
    peak_ts(idx)   = max(abs(F_ts));
    peak_abk(idx)  = max(abs(F_abk));
    peak_conv(idx) = max(abs(F_conv));
end

%% Plot absolute peaks vs frequency
figure;
plot(freqs, peak_ts,   '-o','LineWidth',1.5); hold on
plot(freqs, peak_abk,  '-s','LineWidth',1.5);
plot(freqs, peak_conv, '-^','LineWidth',1.5);
hold off; grid on;
xlabel('Frequency (Hz)');
ylabel('Peak $F_{ex}$ (N)','Interpreter','latex');
legend('WAMIT','ABK Approx','IRF Conv','Location','best');
title('Peak Excitation Force vs Frequency');

%% Report in a table
T = table(freqs.', peak_ts.', peak_abk.', peak_conv.', ...
    'VariableNames', {'Frequency_Hz','Peak_WAMIT_N','Peak_ABK_N','Peak_Conv_N'});
disp(T);

