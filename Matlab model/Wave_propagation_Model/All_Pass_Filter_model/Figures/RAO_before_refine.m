% Load the .fig file
fig = openfig('RAO_before_refine.fig');

% Find all line objects in the figure
lines = findall(fig, 'Type', 'line');

% Extract X and Y data for Line 1 and Line 4
x1 = get(lines(1), 'XData');
y1 = get(lines(1), 'YData');

x4 = get(lines(4), 'XData');
y4 = get(lines(4), 'YData');

% Interpolate Line 1’s Y data at Line 4’s X points
y1_interp = interp1(x1, y1, x4, 'linear');

% Compute absolute error
error = abs(y4 - y1_interp);

% Average error (mean absolute error)
average_error = mean(error);

% Display the result
fprintf('Average absolute error between Line 1 and Line 4: %.6f\n', average_error);
