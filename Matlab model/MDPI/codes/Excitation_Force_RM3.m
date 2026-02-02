clc;clear;
load("NorthSea_Tp_7_clean.mat");

rho = 1025; g = 9.81;

%% eta @ 5 Hz
Fs = 5;  dt = 1/Fs;
x  = S(1).filteredTimeSeries(:);
x  = x - mean(x);                 % recommended
N  = numel(x);
t  = (0:N-1).' * dt;

%% hydro + helper to get IRF(t) and h(t)
hydro = h5tostruct("hydro/rm3.h5");
getIRF = @(H) deal(H.Fex.IRF.t(:), (rho*g)*squeeze(H.Fex.IRF.f(:,1,3)));

[tF,hF] = getIRF(hydro.float);
[tS,hS] = getIRF(hydro.spar);

%% resample IRFs onto dt=0.2s (keep two-sided support)
tIRF = (-20:dt:20).';                         % <- your stated support
hF   = interp1(tF, hF(:), tIRF, "linear", 0);
hS   = interp1(tS, hS(:), tIRF, "linear", 0);

% index where tIRF == 0 (robust)
[~,k0] = min(abs(tIRF - 0));

%% two-sided convolution + alignment to eta timestamps
Ff_full = dt * conv(x, hF, "full");
Fs_full = dt * conv(x, hS, "full");

Ff = Ff_full(k0 : k0+N-1);
Fs = Fs_full(k0 : k0+N-1);

%% pack
out = struct( ...
  "t", t, "eta", x, ...
  "tIRF", tIRF, "hFloat", hF, "hSpar", hS, ...
  "FexFloat", Ff, "FexSpar", Fs );
