classdef WEC_Sankey_App < matlab.apps.AppBase
    % Minimal App Designer-style app for running the WEC simulation
    % and displaying Sankey PNGs.

    properties (Access = public)
        UIFigure          matlab.ui.Figure
        Grid              matlab.ui.container.GridLayout
        ControlsPanel     matlab.ui.container.Panel
        HsLabel           matlab.ui.control.Label
        HsField           matlab.ui.control.NumericEditField
        TeLabel           matlab.ui.control.Label
        TeField           matlab.ui.control.NumericEditField
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
        IsInitialized = false;
    end

    methods (Access = private)
        function runSimulation(app)
            app.RunButton.Enable = 'off';
            app.StatusLabel.Text = 'Running simulation...';
            drawnow;

            Hs = app.HsField.Value;
            Tp = app.TeField.Value;

            assignin('base', 'Hs', Hs);
            assignin('base', 'Tp', Tp);

            try
                simOut = sim(app.ModelName);
                assignin('base', 'simOut', simOut);
                evalin('base', 'run(''build_sankey_postprocess.m'')');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
                app.RunButton.Enable = 'on';
                rethrow(ME);
            end

            sankey1 = fullfile(pwd, 'Sankey_WEC1.png');
            sankey2 = fullfile(pwd, 'Sankey_WEC2.png');

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
            app.StatusLabel.Text = 'Initializing...';
            drawnow;

            dlg = [];
            dlg = uiprogressdlg(app.UIFigure, ...
                'Title', 'Initializing', ...
                'Message', 'Loading parameters...', ...
                'Indeterminate', 'on');
            try
                evalin('base', 'run(''Init_Eqk_ckt_array_model.mlx'')');
            catch ME
                if ~isempty(dlg) && isvalid(dlg)
                    close(dlg);
                end
                app.StatusLabel.Text = ['Init error: ' ME.message];
                app.RunButton.Enable = 'on';
                app.InitButton.Enable = 'on';
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
        end

        function RunButtonPushed(app, ~, ~)
            runSimulation(app);
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'WEC Sankey App');
            app.UIFigure.Tag = 'WEC_Sankey_App_UIFigure';
            app.UIFigure.Position = [100 100 1600 900];

            app.Grid = uigridlayout(app.UIFigure, [1 2]);
            app.Grid.ColumnWidth = {250, '1x'};
            app.Grid.RowHeight = {'1x'};

            app.ControlsPanel = uipanel(app.Grid, 'Title', 'Inputs');
            app.ControlsPanel.Layout.Row = 1;
            app.ControlsPanel.Layout.Column = 1;

            controlsGrid = uigridlayout(app.ControlsPanel, [8 1]);
            controlsGrid.RowHeight = {30, 30, 30, 30, 30, 30, 40, '1x'};
            controlsGrid.ColumnWidth = {'1x'};

            app.HsLabel = uilabel(controlsGrid, 'Text', 'Wave Height Hs (m)');
            app.HsField = uieditfield(controlsGrid, 'numeric');
            app.HsField.Value = 0.2;

            app.TeLabel = uilabel(controlsGrid, 'Text', 'Wave Period Tp (s)');
            app.TeField = uieditfield(controlsGrid, 'numeric');
            app.TeField.Value = 2.0;

            app.InitButton = uibutton(controlsGrid, 'Text', 'Initialize');
            app.InitButton.ButtonPushedFcn = @(src, event) app.InitButtonPushed(src, event);

            app.ForceInitCheckBox = uicheckbox(controlsGrid, 'Text', 'Force Init');
            app.ForceInitCheckBox.Value = false;
            app.ForceInitCheckBox.Visible = 'off';

            app.RunButton = uibutton(controlsGrid, 'Text', 'Run Simulation');
            app.RunButton.ButtonPushedFcn = @(src, event) app.RunButtonPushed(src, event);

            app.StatusLabel = uilabel(controlsGrid, 'Text', 'Idle');

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
