% Assume that 'results' is your table with columns:
%   DelayFactor, Fc1, Fc2, Case, NRMSE_Hilbert, NRMSE_PLL

% Get the unique cases in the dataset.
uniqueCases = unique(results.Case);

for i = 1:length(uniqueCases)
    c = uniqueCases(i);
    % Extract rows corresponding to the current case.
    subset = results(results.Case == c, :);
    
    % For PLL, compute the effective frequency:
    % For cases 1-3 use Fc1; for case 4 use Fc2.
    if c == 4
        effectiveFreq = subset.Fc2;
    else
        effectiveFreq = subset.Fc1;
    end
    
    % Create a new figure for this case.
    figure;
    
    % --- Subplot 1: PLL NRMSE vs. Effective Frequency ---
    subplot(1,2,1);
    scatter(effectiveFreq, subset.NRMSE_PLL, 50, 'filled');
    xlabel('Effective Frequency');
    ylabel('NRMSE (PLL)');
    title(sprintf('Case %d: PLL Trend', c));
    grid on;
    hold on;
    % Fit a second order polynomial (quadratic) for PLL
    p_PLL = polyfit(effectiveFreq, subset.NRMSE_PLL, 2);
    xFit_PLL = linspace(min(effectiveFreq), max(effectiveFreq), 100);
    yFit_PLL = polyval(p_PLL, xFit_PLL);
    plot(xFit_PLL, yFit_PLL, 'r-', 'LineWidth', 2);
    legend('Data Points', sprintf('Quadratic Fit: %.3fx^2 + %.3fx + %.3f', p_PLL(1), p_PLL(2), p_PLL(3)), 'Location', 'best');
    hold off;
    
    % --- Subplot 2: Hilbert NRMSE vs. Delay Factor ---
    subplot(1,2,2);
    scatter(subset.DelayFactor, subset.NRMSE_Hilbert, 50, 'filled');
    xlabel('Delay Factor');
    ylabel('NRMSE (Hilbert)');
    title(sprintf('Case %d: Hilbert Trend', c));
    grid on;
    hold on;
    % Fit a second order polynomial (quadratic) for Hilbert
    p_Hilbert = polyfit(subset.DelayFactor, subset.NRMSE_Hilbert, 2);
    xFit_Hilbert = linspace(min(subset.DelayFactor), max(subset.DelayFactor), 100);
    yFit_Hilbert = polyval(p_Hilbert, xFit_Hilbert);
    plot(xFit_Hilbert, yFit_Hilbert, 'r-', 'LineWidth', 2);
    legend('Data Points', sprintf('Quadratic Fit: %.3fx^2 + %.3fx + %.3f', p_Hilbert(1), p_Hilbert(2), p_Hilbert(3)), 'Location', 'best');
    hold off;
    
    % Optionally, adjust the figure position or save the figure as needed.
end
