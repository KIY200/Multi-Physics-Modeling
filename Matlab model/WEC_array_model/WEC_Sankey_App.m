classdef WEC_Sankey_App < matlab.apps.AppBase
    % Minimal App Designer-style app for running the WEC simulation
    % and displaying Sankey PNGs.

    properties (Access = public)
        UIFigure          matlab.ui.Figure
        Grid              matlab.ui.container.GridLayout
        ControlsPanel     matlab.ui.container.Panel
        ControlsContentPanel matlab.ui.container.Panel
        ControlsGrid     matlab.ui.container.GridLayout
        HsLabel           matlab.ui.control.Label
        HsField           matlab.ui.control.NumericEditField
        TeLabel           matlab.ui.control.Label
        TeField           matlab.ui.control.NumericEditField
        ModelLabel        matlab.ui.control.Label
        ModelDropDown     matlab.ui.control.DropDown
        DampingLabel      matlab.ui.control.Label
        DampingField      matlab.ui.control.NumericEditField
        IrregularCheckBox matlab.ui.control.CheckBox
        GammaLabel        matlab.ui.control.Label
        GammaField        matlab.ui.control.NumericEditField
        SpacingLabel      matlab.ui.control.Label
        SpacingDropDown   matlab.ui.control.DropDown
        AutoReinitCheckBox matlab.ui.control.CheckBox
        InitStatusLabel   matlab.ui.control.Label
        InitStatusLamp    matlab.ui.control.Lamp
        InitButton        matlab.ui.control.Button
        ForceInitCheckBox matlab.ui.control.CheckBox
        RunButton         matlab.ui.control.Button
        StatusLabel       matlab.ui.control.Label
        PlotsPanel        matlab.ui.container.Panel
        PlotsGrid         matlab.ui.container.GridLayout
        Sankey1Image      matlab.ui.control.Image
        Sankey2Image      matlab.ui.control.Image
    end

    properties (Access = private)
        ModelName = 'LUPA_Array_Eqk_circuit_w_PTO_DC_link_v2';
        TwoBodyModelName = 'two_body_LUPA_Array_Eqk_circuit_w_PTO_DC_link_v2';
        InitFileName = 'Init_Eqk_ckt_array_model.mlx';
        InitFileNameTwoBody = 'Init_Eqk_ckt_array_model_2body.mlx';
        IsInitialized = false;
        LastInitSpacing = '';
    end

    methods (Access = private)
        function runSimulation(app)
            model = app.ModelName;
            if strcmp(app.ModelDropDown.Value, 'Two-body')
                model = app.TwoBodyModelName;
            end

            app.RunButton.Enable = 'off';
            app.StatusLabel.Text = 'Running simulation...';
            drawnow;

            Hs = app.HsField.Value;
            Tp = app.TeField.Value;
            rx = app.DampingField.Value;

            assignin('base', 'Hs', Hs);
            assignin('base', 'Tp', Tp);
            assignin('base', 'rx', rx);
            assignin('base', 'Gamma', app.GammaField.Value);
            assignin('base', 'UseIrregularWave', app.IrregularCheckBox.Value);

            try
                simOut = sim(model);
                assignin('base', 'simOut', simOut);
                evalin('base', 'run(fullfile(pwd,''functions'',''build_sankey_postprocess.m''))');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
                app.RunButton.Enable = 'on';
                rethrow(ME);
            end

            sankey1 = fullfile(pwd, 'figures', 'Sankey_WEC1.png');
            sankey2 = fullfile(pwd, 'figures', 'Sankey_WEC2.png');

            if isfile(sankey1)
                app.Sankey1Image.ImageSource = imread(sankey1);
            end
            if isfile(sankey2)
                app.Sankey2Image.ImageSource = imread(sankey2);
            end

            app.StatusLabel.Text = 'Done.';
            app.RunButton.Enable = 'on';
        end
    end

    methods (Access = private)
        function InitButtonPushed(app, ~, ~)
            if app.IsInitialized && ~app.ForceInitCheckBox.Value
                app.StatusLabel.Text = 'Already initialized (cached).';
                return;
            end

            app.RunButton.Enable = 'off';
            app.InitButton.Enable = 'off';
            app.InitStatusLamp.Color = [1 1 0];
            app.StatusLabel.Text = 'Initializing...';
            drawnow;

            dlg = [];
            dlg = uiprogressdlg(app.UIFigure, ...
                'Title', 'Initializing', ...
                'Message', 'Loading parameters...', ...
                'Indeterminate', 'on');
            try
                assignin('base', 'HydroFile', app.SpacingDropDown.Value);
                evalin('base', 'addpath(fullfile(pwd,''functions''))');
                init_file = app.InitFileName;
                if strcmp(app.ModelDropDown.Value, 'Two-body')
                    init_file = app.InitFileNameTwoBody;
                end
                evalin('base', sprintf('run(''%s'')', init_file));
            catch ME
                if ~isempty(dlg) && isvalid(dlg)
                    close(dlg);
                end
                app.StatusLabel.Text = ['Init error: ' ME.message];
                app.RunButton.Enable = 'on';
                app.InitButton.Enable = 'on';
                app.InitStatusLamp.Color = [1 0 0];
                rethrow(ME);
            end
            if ~isempty(dlg) && isvalid(dlg)
                close(dlg);
            end

            app.StatusLabel.Text = 'Initialized.';
            app.RunButton.Enable = 'on';
            app.InitButton.Enable = 'on';
            app.IsInitialized = true;
            app.ForceInitCheckBox.Value = false;
            app.LastInitSpacing = app.SpacingDropDown.Value;
            app.InitStatusLamp.Color = [0.2 0.8 0.2];
        end

        function SpacingDropDownChanged(app, ~, ~)
            if app.AutoReinitCheckBox.Value
                app.InitButtonPushed([], []);
            else
                app.IsInitialized = false;
                app.InitStatusLamp.Color = [1 1 0];
                app.StatusLabel.Text = 'Spacing changed; reinitialize required.';
            end
        end

        function RunButtonPushed(app, ~, ~)
            runSimulation(app);
        end

        function updateControlsPanelSize(app)
            if isempty(app.ControlsContentPanel) || ~isvalid(app.ControlsContentPanel)
                return;
            end
            inner = app.ControlsPanel.InnerPosition;
            pos = app.ControlsContentPanel.Position;
            height = pos(4);
            if height <= inner(4)
                height = inner(4) + 1;
            end
            app.ControlsContentPanel.Position = [0 0 inner(3) height];
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'WEC Sankey App');
            app.UIFigure.Tag = 'WEC_Sankey_App_UIFigure';
            app.UIFigure.Position = [100 100 1600 900];
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = @(src, event) app.updateControlsPanelSize();

            app.Grid = uigridlayout(app.UIFigure, [1 2]);
            app.Grid.ColumnWidth = {250, '1x'};
            app.Grid.RowHeight = {'1x'};

            app.ControlsPanel = uipanel(app.Grid, 'Title', 'Inputs');
            app.ControlsPanel.Layout.Row = 1;
            app.ControlsPanel.Layout.Column = 1;
            app.ControlsPanel.Scrollable = 'on';
            app.ControlsPanel.AutoResizeChildren = 'off';

            total_rows = 17;
            row_height = 30;
            row_spacing = 6;
            padding = [10 10 10 10];
            total_height = total_rows * row_height + (total_rows - 1) * row_spacing + padding(2) + padding(4);

            app.ControlsContentPanel = uipanel(app.ControlsPanel);
            app.ControlsContentPanel.Units = 'pixels';
            app.ControlsContentPanel.Position = [0 0 app.ControlsPanel.InnerPosition(3) total_height];
            app.ControlsContentPanel.BorderType = 'none';

            app.ControlsGrid = uigridlayout(app.ControlsContentPanel, [17 1]);
            app.ControlsGrid.RowHeight = repmat({row_height}, 1, total_rows);
            app.ControlsGrid.ColumnWidth = {'1x'};
            app.ControlsGrid.RowSpacing = row_spacing;
            app.ControlsGrid.Padding = padding;

            app.HsLabel = uilabel(app.ControlsGrid, 'Text', 'Wave Height Hs (m)');
            app.HsField = uieditfield(app.ControlsGrid, 'numeric');
            app.HsField.Value = 0.2;

            app.TeLabel = uilabel(app.ControlsGrid, 'Text', 'Wave Period Tp (s)');
            app.TeField = uieditfield(app.ControlsGrid, 'numeric');
            app.TeField.Value = 2.0;

            app.ModelLabel = uilabel(app.ControlsGrid, 'Text', 'Model');
            app.ModelDropDown = uidropdown(app.ControlsGrid);
            app.ModelDropDown.Items = {'One-body (heave)', 'Two-body'};
            app.ModelDropDown.Value = 'One-body (heave)';

            app.DampingLabel = uilabel(app.ControlsGrid, 'Text', 'PTO Damping rx');
            app.DampingField = uieditfield(app.ControlsGrid, 'numeric');
            app.DampingField.Value = 75;

            app.IrregularCheckBox = uicheckbox(app.ControlsGrid, 'Text', 'Irregular Wave (JONSWAP placeholder)');
            app.IrregularCheckBox.Value = false;

            app.GammaLabel = uilabel(app.ControlsGrid, 'Text', 'JONSWAP Gamma (placeholder)');
            app.GammaField = uieditfield(app.ControlsGrid, 'numeric');
            app.GammaField.Value = 3.3;
            app.GammaField.Enable = 'off';

            app.SpacingLabel = uilabel(app.ControlsGrid, 'Text', 'WEC Spacing (Hydro File)');
            app.SpacingDropDown = uidropdown(app.ControlsGrid);
            app.SpacingDropDown.Items = { ...
                '4.00 m', '4.25 m', '4.50 m', '5.00 m', '5.25 m', '5.50 m', ...
                '5.75 m', '6.00 m', '6.25 m', '6.50 m', '6.75 m', '7.00 m' ...
                };
            app.SpacingDropDown.ItemsData = { ...
                'hydro/2WEC_Spacing_4p00m.h5', ...
                'hydro/2WEC_Spacing_4p25m.h5', ...
                'hydro/2WEC_Spacing_4p50m.h5', ...
                'hydro/2WEC_Spacing_5p00m.h5', ...
                'hydro/2WEC_Spacing_5p25m.h5', ...
                'hydro/2WEC_Spacing_5p50m.h5', ...
                'hydro/2WEC_Spacing_5p75m.h5', ...
                'hydro/2WEC_Spacing_6p00m.h5', ...
                'hydro/2WEC_Spacing_6p25m.h5', ...
                'hydro/2WEC_Spacing_6p50m.h5', ...
                'hydro/2WEC_Spacing_6p75m.h5', ...
                'hydro/2WEC_Spacing_7p00m.h5' ...
                };
            app.SpacingDropDown.Value = 'hydro/2WEC_Spacing_4p00m.h5';
            app.SpacingDropDown.ValueChangedFcn = @(src, event) app.SpacingDropDownChanged(src, event);

            app.AutoReinitCheckBox = uicheckbox(app.ControlsGrid, 'Text', 'Auto Reinitialize on Spacing Change');
            app.AutoReinitCheckBox.Value = false;

            app.InitButton = uibutton(app.ControlsGrid, 'Text', 'Initialize');
            app.InitButton.ButtonPushedFcn = @(src, event) app.InitButtonPushed(src, event);

            app.ForceInitCheckBox = uicheckbox(app.ControlsGrid, 'Text', 'Force Init');
            app.ForceInitCheckBox.Value = false;
            app.ForceInitCheckBox.Visible = 'off';

            app.RunButton = uibutton(app.ControlsGrid, 'Text', 'Run Simulation');
            app.RunButton.ButtonPushedFcn = @(src, event) app.RunButtonPushed(src, event);

            app.InitStatusLabel = uilabel(app.ControlsGrid, 'Text', 'Init Status');
            app.InitStatusLamp = uilamp(app.ControlsGrid);
            app.InitStatusLamp.Color = [1 0 0];

            app.StatusLabel = uilabel(app.ControlsGrid, 'Text', 'Idle');

            app.PlotsPanel = uipanel(app.Grid, 'Title', 'Sankey Results');
            app.PlotsPanel.Layout.Row = 1;
            app.PlotsPanel.Layout.Column = 2;

            app.PlotsGrid = uigridlayout(app.PlotsPanel, [2 1]);
            app.PlotsGrid.RowHeight = {'1x', '1x'};
            app.PlotsGrid.ColumnWidth = {'1x'};

            app.Sankey1Image = uiimage(app.PlotsGrid);
            app.Sankey1Image.ScaleMethod = 'fit';
            app.Sankey2Image = uiimage(app.PlotsGrid);
            app.Sankey2Image.ScaleMethod = 'fit';
        end
    end

    methods (Access = public)
        function app = WEC_Sankey_App
            existing = findall(0, 'Type', 'figure', 'Tag', 'WEC_Sankey_App_UIFigure');
            if ~isempty(existing)
                delete(existing);
            end
            createComponents(app);
        end
    end
end
