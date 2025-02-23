function Z_OPT_fixed = Z_match_fixedf(hydro,wave)


% Y_PTO = Y_eq^* = 1/R_eq - B_eq * 1i
% Y_PTO = 1/R_pto + (C_pto*w - 1/(L_pto*w))*1i
% imag(Y_PTO) = C_pto*w -1/(L_pto*w)
% imag(Y_PTO) = -kpto = C_pto*w -1/(L_pto*w)
% => kpto=1/(L_pto*w)-C_pto*w;
% Y_eq+Y_pto = 2 real(Y_eq) + 0
% Imag(Y_eq)+imag(Y_pto) = 0
% Image(Y_pto)=-imag(Y_eq)

Y_PTO = hydro.Z_table.Y_pto(wave.mode.indx);
if imag(Y_PTO)<0
    Z_OPT_fixed.R = 1./real(Y_PTO);
    Z_OPT_fixed.L = 0;
    Z_OPT_fixed.C = abs(imag(Y_PTO)./wave.w);
elseif imag(Y_PTO)>0
    Z_OPT_fixed.R = 1./real(Y_PTO);
    Z_OPT_fixed.L = 1./abs(imag(Y_PTO).*wave.w);
    Z_OPT_fixed.C = 0;
else
    Z_OPT_fixed.R = 1./real(Y_PTO);
    Z_OPT_fixed.L = 0;
    Z_OPT_fixed.C = 0;
end
Z_OPT_fixed.R_opt = 1./abs(Y_PTO);
Z_OPT_fixed.K_pto = imag(Y_PTO).*wave.w;
Z_OPT_fixed.B_pto = real(Y_PTO);
Z_OPT_fixed.B_opt = abs(Y_PTO);