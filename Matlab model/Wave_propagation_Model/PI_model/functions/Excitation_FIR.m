<<<<<<< Updated upstream
function [IRF_t,FIR_causal,FIR_non_causal,Fex_comp] = Excitation_FIR(Hydro_coef_location)

Fex_re = h5read('hydro/floatspar.h5','/body1/hydro_coeffs/excitation/re');
Fex_re = squeeze(Fex_re(:,1,3));
Fex_im = h5read('hydro/floatspar.h5','/body1/hydro_coeffs/excitation/im');
Fex_im = squeeze(Fex_im(:,1,3));
Fex_comp = 9.81*1000*complex(Fex_re,Fex_im);
=======
function [IRF_t,FIR_causal,FIR_non_causal] = Excitation_FIR(Hydro_coef_location)

% Fex_re = 1000*h5read('hydro/floatspar.h5','/body1/hydro_coeffs/excitation/re');
% Fex_re = squeeze(Fex_re(:,1,3));
% Fex_im = 1000*h5read('hydro/floatspar.h5','/body1/hydro_coeffs/excitation/im');
% Fex_im = squeeze(Fex_im(:,1,3));
% Fex_comp = complex(Fex_re,Fex_im);
>>>>>>> Stashed changes

IRF_Fex = 1000*9.81*h5read(Hydro_coef_location,'/body1/hydro_coeffs/excitation/impulse_response_fun/f');
IRF_Fex = squeeze(IRF_Fex(:,1,3));
IRF_t = h5read(Hydro_coef_location,'/body1/hydro_coeffs/excitation/impulse_response_fun/t');
indx_zero_t = find(IRF_t==0);
FIR_causal = IRF_Fex(indx_zero_t:end);
FIR_non_causal=IRF_Fex(1:indx_zero_t-1);
%plot(IRF_t,IRF_Fex)
end