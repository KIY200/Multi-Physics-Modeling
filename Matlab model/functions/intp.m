function interpolated_data = intp(timeseries_data,timeseries_time,interpol_ts)
% Sample time-series data with non-identical time steps
t_series = timeseries_time;  % Time points
data = timeseries_data;  % Corresponding data points

% Desired time points for interpolation
t_interpolation = 0:interpol_ts:1200;  % Adjust the step size according to your needs

% Perform interpolation
interpolated_data = interp1(t_series, data, t_interpolation,"nearest","extrap");

% Plot the original and interpolated data
% subplot(2,1,1);
% plot(t_series, data, 'o-', 'LineWidth', 1.5);
% xlabel('Time');
% ylabel('Data');
% title('Original Data');

% subplot(2,1,2);
plot(t_interpolation, interpolated_data, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Frequency (Hz)');