%% Sankey Diagram
% 
% 
% Incident Wave Power
% 
% ├─→ Absorbed (WEC1)
% 
% │     └─→ PTO (WEC1)
% 
% │           ├─→ Delivered Power (WEC1)
% 
% │           └─→ Electrical Loss (WEC1)
% 
% ├─→ Absorbed (WEC2)
% 
% │     └─→ PTO (WEC2)
% 
% │           ├─→ Delivered Power (WEC2)
% 
% │           └─→ Electrical Loss (WEC2)
% 
% └─→ Not Absorbed (passes by / scattered)
% 
% The Sankey diagram illustrates the average power flow from the incident wave 
% field to the electrical delivery point. Incident wave power is partially absorbed 
% by the WEC due to hydrodynamic coupling and phase effects between excitation 
% force and body velocity. The absorbed power is converted by the PTO, after which 
% electrical transmission losses are incurred. The remaining incident wave power 
% passes the device without being absorbed.

if exist('simOut', 'var')
    data = simOut.logsout;
elseif exist('out', 'var')
    data = out.logsout;
else
    error('No sim output found. Provide simOut or out in workspace.');
end
output = struct();

for ii = 1:data.numElements
    elem = data.get(ii);                    % Simulink.SimulationData.Signal
    if isempty(elem.Name)
        continue;
    end
    sigName = matlab.lang.makeValidName(elem.Name);

    % elem.Values is usually a timeseries
    output.(sigName).ts = elem.Values;      % store full timeseries object
    % Optionally also store raw arrays:
    output.(sigName).t  = elem.Values.Time;
    output.(sigName).x  = elem.Values.Data;
end


rho=1000;
g=9.81;
Hs = get_signal(output, 'Hs');
wp = get_signal(output, 'wp');
Hs = mean(Hs, 'omitnan');
wp = mean(wp, 'omitnan');
Te = (2*pi/wp);

% Potential average wave power (available Power)
P_wave_input_avg = rho*g^2*Hs^2*Te/32/pi*LUPA_width;
if ~isfinite(P_wave_input_avg)
    P_wave_input_avg = 0;
end

% Average tranmitted power From Incident wave to WEC device (partially
% dissipated due to the lag between exictation force and WEC motion.)
Pin1_avg = safe_mean(get_signal(output, 'P_in_WEC1'));
Pin2_avg = safe_mean(get_signal(output, 'P_in_WEC2'));

% PTO generated power
PTO1_avg = safe_mean(get_signal(output, 'P_pto_WEC1'));
PTO2_avg = safe_mean(get_signal(output, 'P_pto_WEC2'));

% Local Transmission losses
Loss1_avg = -safe_mean(get_signal(output, 'P_loss_WEC1'));
Loss2_avg = -safe_mean(get_signal(output, 'P_loss_WEC2'));

%% --- 1) Build WEC1 Sankey (independent input) ---

% "Incident wave power available to WEC1"
P_inc_1 = max(P_wave_input_avg, 0);

% "Absorbed mechanical/hydrodynamic power into WEC1"
P_abs_1 = max(Pin1_avg, 0);

% Not absorbed (available but not captured)
P_not_1 = max(P_inc_1 - P_abs_1, 0);

% PTO electrical generated (from absorbed pathway)
P_pto_1  = max(PTO1_avg, 0);

% Electrical transmission loss (make sure Loss1_avg is already + for loss magnitude)
P_loss_1 = max(Loss1_avg, 0);

% Delivered electrical after losses
P_del_1 = max(P_pto_1 - P_loss_1, 0);

% Remaining absorbed power not converted to PTO electricity
% (often lumped as radiation/viscous/other hydro losses)
P_rad_1 = max(P_abs_1 - P_pto_1, 0);

%% --- 3) Node labels (match values) ---
% Labels are generated in Python.

%% --- 4) Edges and weights (MUST align row-by-row) ---
% Graph construction is handled in Python.

%% --- Build WEC2 Sankey ---

% "Incident wave power available to WEC2"
P_inc_2 = max(P_wave_input_avg, 0);

% "Absorbed mechanical/hydrodynamic power into WEC2"
P_abs_2 = max(Pin2_avg, 0);

% Not absorbed (available but not captured)
P_not_2 = max(P_inc_2 - P_abs_2, 0);

% PTO electrical generated (from absorbed pathway)
P_pto_2  = max(PTO2_avg, 0);

% Electrical transmission loss (make sure Loss2_avg is already + for loss magnitude)
P_loss_2 = max(Loss2_avg, 0);

% Delivered electrical after losses
P_del_2 = max(P_pto_2 - P_loss_2, 0);

% Remaining absorbed power not converted to PTO electricity
% (often lumped as radiation/viscous/other hydro losses)
P_rad_2 = max(P_abs_2 - P_pto_2, 0);

%% --- Node labels  ---
% Labels are generated in Python.

%% --- Edges and weights (MUST align row-by-row) ---
% Graph construction is handled in Python.

%% --- Export data for Python Sankey ---
sankey = struct();
sankey.units = 'W';
sankey.wec1 = struct( ...
    'P_inc', P_inc_1, ...
    'P_abs', P_abs_1, ...
    'P_not', P_not_1, ...
    'P_pto', P_pto_1, ...
    'P_rad', P_rad_1, ...
    'P_del', P_del_1, ...
    'P_loss', P_loss_1 ...
    );
sankey.wec2 = struct( ...
    'P_inc', P_inc_2, ...
    'P_abs', P_abs_2, ...
    'P_not', P_not_2, ...
    'P_pto', P_pto_2, ...
    'P_rad', P_rad_2, ...
    'P_del', P_del_2, ...
    'P_loss', P_loss_2 ...
    );

script_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(script_dir);
json_path = fullfile(project_dir, 'sankey_data.json');
fid = fopen(json_path, 'w');
if fid < 0
    error('Failed to open %s for writing.', json_path);
end
fwrite(fid, jsonencode(sankey), 'char');
fclose(fid);

% Run Python plotting script (creates Sankey_WEC1.png and Sankey_WEC2.png)
pe = pyenv;
python_exe = pe.Executable;
if strlength(python_exe) == 0
    python_exe = 'python3';
end
script_path = fullfile(script_dir, 'build_sankey_postprocess.py');
cmd = sprintf('"%s" "%s" "%s"', python_exe, script_path, json_path);
[status, cmdout] = system(cmd);
if status ~= 0
    warning('Python Sankey failed: %s', cmdout);
end

function x = get_signal(output, name)
    if isfield(output, name)
        x = output.(name).x;
        return;
    end
    error('Missing required signal in logsout: %s', name);
end

function m = safe_mean(x)
    m = mean(x, 'omitnan');
    if ~isfinite(m)
        m = 0;
    end
end
