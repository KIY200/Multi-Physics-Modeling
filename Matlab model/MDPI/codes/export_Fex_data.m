load("NorthSea_Tp_7_clean.mat");

for ii = 1:numel(S)
    name = sprintf("seed%d",ii);
    out.(name) = eta2Fex(S(ii).filteredTimeSeries, 5, "hydro/rm3.h5", ...
        "IRFWindow", [-20 20], ...
        "Index", [1 3], ...
        "RemoveMean", true);
end

save("Fex_Northsea_Tp_7.mat","out")
