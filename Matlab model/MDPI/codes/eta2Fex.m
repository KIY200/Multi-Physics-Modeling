function out = eta2Fex(eta, Fs, hydroFile, varargin)
%ETA2FEX  Compute excitation force via two-sided IRF convolution.
%
%   out = ETA2FEX(eta, Fs, hydroFile)
%   out = ETA2FEX(eta, Fs, hydroFile, 'IRFWindow', [-20 20], ...
%                 'Rho', 1025, 'g', 9.81, 'Index', [1 3], ...
%                 'RemoveMean', true)
%
% Inputs
%   eta       : wave elevation time series (Nx1 or 1xN) [m]
%   Fs        : sampling rate of eta [Hz] (e.g., 5)
%   hydroFile : path to .h5 hydro file (e.g., "hydro/rm3.h5")
%
% Name-Value options
%   'IRFWindow'   : [tmin tmax] seconds for two-sided IRF (default [-20 20])
%   'Rho'         : water density [kg/m^3] (default 1025)
%   'g'           : gravity [m/s^2] (default 9.81)
%   'Index'       : [ih idof] indices into f(:,ih,idof) (default [1 3])
%   'RemoveMean'  : logical, remove mean of eta (default true)
%
% Output struct 'out'
%   out.t, out.eta
%   out.tIRF, out.hFloat, out.hSpar
%   out.FexFloat, out.FexSpar

% -------------------- parse inputs --------------------
p = inputParser;
p.addRequired("eta", @(x) isnumeric(x) && isvector(x));
p.addRequired("Fs",  @(x) isnumeric(x) && isscalar(x) && x>0);
p.addRequired("hydroFile", @(x) isstring(x) || ischar(x));

p.addParameter("IRFWindow", [-20 20], @(x) isnumeric(x) && numel(x)==2 && x(2)>x(1));
p.addParameter("Rho", 1025, @(x) isnumeric(x) && isscalar(x) && x>0);
p.addParameter("g", 9.81,  @(x) isnumeric(x) && isscalar(x) && x>0);
p.addParameter("Index", [1 3], @(x) isnumeric(x) && numel(x)==2);
p.addParameter("RemoveMean", true, @(x) islogical(x) && isscalar(x));

p.parse(eta, Fs, hydroFile, varargin{:});
opt = p.Results;

dt = 1/opt.Fs;

% eta conditioning
x = opt.eta(:);
if opt.RemoveMean
    x = x - mean(x);
end
N = numel(x);
t = (0:N-1).' * dt;

% -------------------- load hydro + extract IRFs --------------------
hydro = h5tostruct(opt.hydroFile);

ih   = opt.Index(1);
idof = opt.Index(2);

getIRF = @(H) deal( ...
    H.Fex.IRF.t(:), ...
    (opt.Rho*opt.g) * squeeze(H.Fex.IRF.f(:,ih,idof)) );

[tF, hF] = getIRF(hydro.float);
[tS, hS] = getIRF(hydro.spar);

hF = hF(:); hS = hS(:);

% -------------------- resample to eta dt over two-sided window --------------------
tmin = opt.IRFWindow(1);
tmax = opt.IRFWindow(2);
tIRF = (tmin:dt:tmax).';

hF = interp1(tF, hF, tIRF, "linear", 0);
hS = interp1(tS, hS, tIRF, "linear", 0);

% zero-time index (robust)
[~, k0] = min(abs(tIRF));

% -------------------- convolution + align output to eta timestamps --------------------
Ff_full = dt * conv(x, hF, "full");
Fs_full = dt * conv(x, hS, "full");

% Align so that out.t corresponds to eta time stamps
Ff = Ff_full(k0 : k0+N-1);
Fs = Fs_full(k0 : k0+N-1);

% -------------------- pack --------------------
out = struct( ...
    "t", t, "eta", x, ...
    "Fs", opt.Fs, "dt", dt, ...
    "tIRF", tIRF, "hFloat", hF, "hSpar", hS, ...
    "FexFloat", Ff, "FexSpar", Fs, ...
    "meta", struct("hydroFile", string(opt.hydroFile), "IRFWindow", opt.IRFWindow, ...
                   "rho", opt.Rho, "g", opt.g, "Index", opt.Index, "RemoveMean", opt.RemoveMean) );
end
