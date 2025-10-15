function hydro = convh5_v2(filename, body_up, body_dn)
% CONVH5  Load & denormalize hydrodynamic data for two bodies.
% Input HDF5 layout assumed: [Nw x 24 x 6] for A, B, Re, Im
% K is always [6 x 6] (constant stiffness).
% Outputs: fields in [6 x 24 x Nw] or [6 x 6] for K.

    if nargin < 2, body_up = 1; end
    if nargin < 3, body_dn = 3; end

    rho = 1000;
    g   = 9.81;
    
    % Frequency vector (1 x Nw)
    w  = h5read(filename, '/simulation_parameters/w');
    w  = w(:).';
    Nw = numel(w);
    Vol = h5read(filename, '/body1/properties/disp_vol');
    % ---------- Upper body ----------
    base = sprintf('/body%d/hydro_coeffs', body_up);
    A  = h5read(filename, [base '/added_mass/all']);        % [Nw x 24 x 6]
    B  = h5read(filename, [base '/radiation_damping/all']); % [Nw x 24 x 6]
    Re = h5read(filename, [base '/excitation/re']);         % [Nw x 24 x 6]
    Im = h5read(filename, [base '/excitation/im']);         % [Nw x 24 x 6]
    K  = h5read(filename, [base '/linear_restoring_stiffness']); % [6 x 6]
   

    % Permute to [6 x 24 x Nw]
    A  = permute(A,  [3 2 1]);
    B  = permute(B,  [3 2 1]);
    Re = permute(Re, [3 2 1]);
    Im = permute(Im, [3 2 1]);
    
    float_up.dry_mass    = rho * Vol;
    float_up.Add_mass    = rho .* A;
    float_up.Rad_damping = rho .* (B .* reshape(w,1,1,[])); % scale by ω
    float_up.K           = rho * g .* K;                    % stays [6 x 6]
    float_up.Fex_re      = rho * g .* Re;
    float_up.Fex_im      = rho * g .* Im;

    % ---------- Lower body ----------
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
    
    float_dn.dry_mass    = rho * Vol;
    float_dn.Add_mass    = rho .* A;
    float_dn.Rad_damping = rho .* (B .* reshape(w,1,1,[]));
    float_dn.K           = rho * g .* K;   % [6 x 6]
    float_dn.Fex_re      = rho * g .* Re;
    float_dn.Fex_im      = rho * g .* Im;

    % Package
    hydro.w        = w;
    hydro.float_up = float_up;
    hydro.float_dn = float_dn;
end
