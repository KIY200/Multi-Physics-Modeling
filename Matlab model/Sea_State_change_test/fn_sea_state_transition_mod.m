function [eta, t, phase_end] = fn_sea_state_transition_mod(...
    Hs_1, Tp_1, Hs_2, Tp_2, t_end, phase0)

    %--- parameters ---
    dt      = 0.1;                       % time step [s]
    w_start = 2*pi/15;                   % min rad/s
    w_end   = 2*pi/1;                    % max rad/s
    dw      = 2*pi/t_end;                % bin width
    w       = w_start:dw:w_end;          % [1×Nw]  

    Nt      = round(t_end/dt) + 1;       % number of time‐steps  
    t       = (0:Nt-1)*dt;               % time vector [1×Nt]

    if nargin<6
        phase0 = rand(size(w))*2*pi;     % random start phases  
    end
    phase = phase0;                      % initialize
    eta   = zeros(1, Nt);

    %--- loop over time ---
    for c = 1:Nt
        frac = (c-1)/(Nt-1);             % 0→1 interpolation

        % interpolate sea‐state
        Tp_c = Tp_1 + (Tp_2 - Tp_1)*frac;
        Hs_c = Hs_1 + (Hs_2 - Hs_1)*frac;

        % PM‐spectrum at this instant (rad/s)
        S_c = 5*pi^4 * Hs_c^2 / Tp_c^4 ...
              .* (1./w.^5) ...
              .* exp(-20*pi^4./(Tp_c^4 .* w.^4)) ...
              * dw;  

        % synthesize elevation using incremental phase
        eta(c) = sum( sqrt(2*S_c) .* sin( phase ) );

        % advance phase by w*dt
        phase = phase + w*dt;
    end

    % wrap final phase into [0,2π)
    phase_end = mod(phase, 2*pi);
end
