function smoothed_psd = smt(psd,window_size)



% Adjust this value to change the window size

% Apply moving median window for smoothing
smoothed_psd = movmedian(psd, window_size);

% Plot the original and smoothed PSD
% plot(frequencies, psd, 'b-', 'LineWidth', 1.5);
% hold on;
% plot(smoothed_psd, 'r-', 'LineWidth', 1.5);
% hold off;
% xlabel('Frequency');
% ylabel('Power Spectral Density');
% title('Smoothing Power Spectral Density');
% legend('Original PSD', 'Smoothed PSD');
% xlim([0 0.4]);
