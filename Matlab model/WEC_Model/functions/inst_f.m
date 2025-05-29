function inst_freq = inst_f(ts)
        % water elevation time-series data
t = ts(:,1);  % time vector
x = ts(:,2);  % water elevation


% Calculate the phase of the signal
phase = angle(hilbert(x));

% Calculate the instantaneous frequency
dt = t(2) - t(1);  % time step
inst_freq = diff(unwrap(phase)) / (2*pi*dt);

% % Plot the instantaneous frequency
% plot(t(2:end), inst_freq);
% xlabel('Time');
% ylabel('Instantaneous Frequency');
% title('Instantaneous Frequency from Envelope Function');