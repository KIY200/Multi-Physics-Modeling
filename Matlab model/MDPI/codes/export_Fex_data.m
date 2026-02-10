clear;clc;
addpath("functions/")
period = input("Enter Tp period (e.g., 7, 8, 9): ");

inFile  = sprintf("NorthSea_Tp_%d.mat", period);
outFile = sprintf("Fex_Northsea_Tp_%d.mat", period);

data = load(inFile); % expects variable named Tp_<period>
varName = sprintf("Tp_%d", period);

if isfield(data, varName)
    raw = data.(varName);
else
    % fallback: if there is exactly one variable in the MAT-file, use it
    f = fieldnames(data);
    if numel(f) ~= 1
        error("Expected variable '%s' in %s, or a single variable MAT-file.", varName, inFile);
    end
    raw = data.(f{1});
end

if istable(raw)
    S = table2struct(raw);
elseif isstruct(raw)
    S = raw;
else
    error("Unsupported data type in %s. Expected table or struct.", inFile);
end

out = struct();
for ii = 1:numel(S)
    name = sprintf("seed%d", ii);
    ts = S(ii).filteredTimeSeries;
    out.(name) = eta2Fex(ts, 5, "hydro/rm3.h5", ...
        "IRFWindow", [-20 20], ...
        "Index", [1 3], ...
        "RemoveMean", true, ...
        "PeakPeriod", period);

    if ii == 1
        out.common.hydro = out.(name).hydro;
        if isfield(out.(name), "heave")
            out.common.heave = out.(name).heave;
        end
        out.common.meta = out.(name).meta;
        out.common.IRF = struct( ...
            "tIRF", out.(name).tIRF, ...
            "hFloat", out.(name).hFloat, ...
            "hSpar", out.(name).hSpar);
        out.common.Fs = out.(name).Fs;
        out.common.dt = out.(name).dt;
    end

    toRemove = {"hydro","heave","meta","tIRF","hFloat","hSpar","Fs","dt"};
    f = fieldnames(out.(name));
    f = cellstr(f);
    toRemove = cellstr(toRemove);
    out.(name) = rmfield(out.(name), f(ismember(f, toRemove)));
end

save(outFile, "out");
