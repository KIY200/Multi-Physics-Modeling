%% 1) Setup
fs    = 10;         % dummy sampling (for plotting in Hz later)
f_min = 0.05; f_max = 0.25;
f     = linspace(f_min, f_max, 300);
w     = 2*pi * f;

%% 2) Objective for 4th-order AP (two biquads)
% x = [w1, z1, w2, z2]
costFun = @(x) phaseCost(x, w);

% initial guess: centers spaced at 0.1 and 0.2 Hz, ζ=0.1
x0 = [2*pi*0.10, 0.1, 2*pi*0.20, 0.1];

opts = optimset('Display','iter','TolX',1e-4,'TolFun',1e-4);
x_opt = fminsearch(costFun, x0, opts);
w1  = x_opt(1);  z1 = x_opt(2);
w2  = x_opt(3);  z2 = x_opt(4);

%% 3) Build the two all-pass sections
A1 = tf([1, -2*z1*w1,  w1^2], [1,  2*z1*w1,  w1^2]);
A2 = tf([1, -2*z2*w2,  w2^2], [1,  2*z2*w2,  w2^2]);
Atot = series(A1, A2);

%% 4) Plot and check
figure;
bodeplot(Atot,{2*pi*f_min,2*pi*f_max},'r');
grid on;
title('Cascaded 4\textsuperscript{th}-Order All-Pass — Phase≈−90°');
% overlay ideal −90°
hold on;
freqs = linspace(2*pi*f_min,2*pi*f_max,200);
semilogx(freqs/(2*pi), -90*ones(size(freqs)),'k--');
legend('All-Pass','Ideal −90°','Location','Best');

%% --- cost function nested below ---
function J = phaseCost(x, w)
    w1 = x(1); z1 = x(2);
    w2 = x(3); z2 = x(4);
    % build APs
    A1 = (1j*w).^2 - 2*z1*w1*(1j*w) + w1^2;
    A1 = A1 ./ ( (1j*w).^2 + 2*z1*w1*(1j*w) + w1^2 );
    A2 = (1j*w).^2 - 2*z2*w2*(1j*w) + w2^2;
    A2 = A2 ./ ( (1j*w).^2 + 2*z2*w2*(1j*w) + w2^2 );
    At = A1 .* A2;
    % extract phase in degrees, unwrap, then error from −90°
    phi = unwrap(angle(At))*180/pi;
    err = phi + 90;                 % want phi≈−90
    J   = sum(err.^2);
end
