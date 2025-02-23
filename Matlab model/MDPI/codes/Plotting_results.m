% Define the number of cases
numCases = 4;

% Loop through each case
for ii = 1:numCases
    % Load the data for the current case
    filename = sprintf('Output/case%d.mat', ii);
    data = load(filename);
    
    % Extract variables from the loaded data
    t = data.out.tout;
    TrueData = data.out.True.Data;
    HilbertData = data.out.Hilbert.Data;
    f_est_PLL = data.out.PLL.f_est_PLL.data;
    
    % Ensure the data vectors are of the same length
    minLength = min([length(TrueData(:,1)), length(HilbertData), length(f_est_PLL)]);
    TrueData = TrueData(1:minLength, 1);
    HilbertData = HilbertData(1:minLength);
    f_est_PLL = f_est_PLL(1:minLength);
    
    % Calculate RMSE for Hilbert estimate
    rmse_Hilbert = sqrt(mean((TrueData - HilbertData).^2));
    
    % Calculate RMSE for PLL estimate
    rmse_PLL = sqrt(mean((TrueData - f_est_PLL).^2));
    
    % Range Normalization
    range_TrueData = max(TrueData) - min(TrueData);
    nrmse_Hilbert = rmse_Hilbert / range_TrueData;
    nrmse_PLL = rmse_PLL / range_TrueData;
    
    % Display NRMSE values
    fprintf('Case %d:\n', ii);
    fprintf('  NRMSE (Hilbert): %.4f\n', nrmse_Hilbert);
    fprintf('  NRMSE (PLL): %.4f\n\n', nrmse_PLL);
    
    % Create a tiled layout for subplots with shared x-axis
    fig = figure;
    tlo = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % First subplot
    ax1 = nexttile;
    customPlot(t, TrueData, 1, HilbertData, f_est_PLL);
    legend('True', 'HT', 'PLL','Orientation', 'horizontal','Location', 'northoutside','Interpreter', 'latex');
    xlabel('Time (s)','Interpreter', 'latex','FontSize',28);
    ylabel('Frequency (Hz)','Interpreter', 'latex','FontSize',28);
    xlim([102, 300]);
    
    % Second subplot
    ax2 = nexttile;
    customPlot(t, data.out.True.Data(:,2), 1);
    xlabel('Time (s)','Interpreter', 'latex','FontSize',28);
    ylabel('Eta (m)','Interpreter', 'latex','FontSize',28);
    xlim([102, 300]);
    
    % Link the x-axes of both subplots
    linkaxes([ax1, ax2], 'x');
    % Set LaTeX font for axes and align y-axis labels
      % Set LaTeX font for axes and align y-axis labels properly in tiled layout
    set([ax1, ax2], 'TickLabelInterpreter', 'latex', 'YAxisLocation', 'left');
    % Define the output directory and ensure it exists
    outputDir = 'Output/Figures';
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Define the base filename for saving
    baseFileName = sprintf('Case%d', ii);
    
    % Save the figure as a .fig file
    savefig(fig, fullfile(outputDir, [baseFileName, '.fig']));
    
    % Save the figure as a .png file
    saveas(fig, fullfile(outputDir, [baseFileName, '.svg']));
    
    % Close the figure to free up system resources
    close(fig);
end
