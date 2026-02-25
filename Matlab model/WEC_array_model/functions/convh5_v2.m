function hydro = convh5_v2(filename, body_up, body_dn)
% CONVH5  Load & denormalize hydrodynamic data for two bodies.
% Input HDF5 layout assumed: [Nw x 24 x 6] for A, B, Re, Im
% K is always [6 x 6] (constant stiffness).
% Outputs: fields in [6 x 24 x Nw] or [6 x 6] for K.

    if nargin < 2
        body_up = 1;
    elseif isnumeric(body_up) && numel(body_up) == 2 && nargin < 3
        body_dn = body_up(2);
        body_up = body_up(1);
    end
    if nargin < 3, body_dn = 3; end

    rho = 1000;
    g   = 9.81;
    
    % Frequency vector (1 x Nw)
    w  = h5read(filename, '/simulation_parameters/w');
    w  = w(:).';
    Nw = numel(w);

    if isnumeric(body_up) && nargin == 1 && ismatrix(body_up) %#ok<ISMAT>
        % This branch is never reached; keep signature compatibility.
    end

    if isnumeric(body_up) && size(body_up,1) == 2 && size(body_up,2) == 2 && nargin < 3
        pairs = body_up;
        hydro.w = w;
        hydro.WEC1 = load_pair(filename, pairs(1,1), pairs(1,2), w, rho, g);
        hydro.WEC2 = load_pair(filename, pairs(2,1), pairs(2,2), w, rho, g);
        % lean: no upstream/downstream aliases
    else
        % Single pair (backward compatible)
        hydro.w = w;
        pair = load_pair(filename, body_up, body_dn, w, rho, g);
        hydro.float = pair.float;
        hydro.spar = pair.spar;
        hydro.f = pair.f;
        hydro.s = pair.s;
        % lean: no float_up/float_dn aliases
    end
end

function pair = load_pair(filename, body_up, body_dn, w, rho, g)
    Vol_up = h5read(filename, sprintf('/body%d/properties/disp_vol', body_up));
    Vol_dn = h5read(filename, sprintf('/body%d/properties/disp_vol', body_dn));
    base = sprintf('/body%d/hydro_coeffs', body_up);
    A  = h5read(filename, [base '/added_mass/all']);        % [Nw x 24 x 6]
    B  = h5read(filename, [base '/radiation_damping/all']); % [Nw x 24 x 6]
    Re = h5read(filename, [base '/excitation/re']);         % [Nw x 24 x 6]
    Im = h5read(filename, [base '/excitation/im']);         % [Nw x 24 x 6]
    K  = h5read(filename, [base '/linear_restoring_stiffness']); % [6 x 6]

    A  = permute(A,  [3 2 1]);
    B  = permute(B,  [3 2 1]);
    Re = permute(Re, [3 2 1]);
    Im = permute(Im, [3 2 1]);

    float_body.dry_mass    = rho * Vol_up;
    float_body.Add_mass    = rho .* A;
    float_body.Rad_damping = rho .* (B .* reshape(w,1,1,[])); % scale by ω
    float_body.K           = rho * g .* K;
    float_body.Fex_re      = rho * g .* Re;
    float_body.Fex_im      = rho * g .* Im;

    base = sprintf('/body%d/hydro_coeffs', body_dn);
    A  = h5read(filename, [base '/added_mass/all']);
    B  = h5read(filename, [base '/radiation_damping/all']);
    Re = h5read(filename, [base '/excitation/re']);
    Im = h5read(filename, [base '/excitation/im']);
    K  = h5read(filename, [base '/linear_restoring_stiffness']);

    A  = permute(A,  [3 2 1]);
    B  = permute(B,  [3 2 1]);
    Re = permute(Re, [3 2 1]);
    Im = permute(Im, [3 2 1]);

    spar_body.dry_mass    = rho * Vol_dn;
    spar_body.Add_mass    = rho .* A;
    spar_body.Rad_damping = rho .* (B .* reshape(w,1,1,[]));
    spar_body.K           = rho * g .* K;
    spar_body.Fex_re      = rho * g .* Re;
    spar_body.Fex_im      = rho * g .* Im;

    pair.float = float_body;
    pair.spar = spar_body;
    pair.f = float_body;
    pair.s = spar_body;
end
