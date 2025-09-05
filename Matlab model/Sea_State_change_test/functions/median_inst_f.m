function instantaneous_values = median_inst_f(t,eta,window_size,median_window)

mag = [abs(hilbert(eta(1:window_size))); zeros(length(t)-window_size,1)];
phase = [angle(hilbert(eta(1:window_size))); zeros(length(t)-window_size,1)];
inst_freq = gradient(unwrap(phase),t)/(2*pi);

for ii = window_size+1:length(t)
        temp_hilbert = hilbert(eta(ii-window_size+1:ii));
        % x_a_hist(:,ii) = temp_hilbert;
        temp_mag = abs(temp_hilbert);
        temp_phase = angle(temp_hilbert);
        temp_inst_f = gradient(unwrap(temp_phase(end-median_window:end)),t(ii-median_window:ii))/(2*pi);
        mag(ii) = median(temp_mag(end-median_window:end));
        phase(ii) = temp_phase(end);
        inst_freq(ii)= median(temp_inst_f);
end

instantaneous_values.inst_freq=inst_freq;
