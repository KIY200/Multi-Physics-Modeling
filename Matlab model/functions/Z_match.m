function Z_OPT = Z_match(hydro,wave,simu)

wave.instf.w = 2*pi*wave.instf.f; % load instantaneous frequency of input wave
Y_PTO = zeros(size(simu.t)); % initalize the control of PTO Impedance 

% Y_PTO = Y_eq^* = 1/R_eq - B_eq * 1i
% Y_PTO = 1/R_pto + (C_pto*w - 1/(L_pto*w))*1i
% imag(Y_PTO) = C_pto*w -1/(L_pto*w)

for ii=1:length(simu.t)
    Y_PTO(ii) = hydro.Z_table.Y_pto(wave.indx(ii)); % fetch the complex conjugate of hydrodynamic coeff at each time step according to inst_f
    if imag(Y_PTO(ii))<0 % when the Y_PTO is capacitance dominant
        Z_OPT.C(ii) = abs(imag(Y_PTO(ii))./wave.instf.w(ii));
        Z_OPT.L(ii) = 0;
        Z_OPT.R(ii)=1./real(Y_PTO(ii));
    elseif imag(Y_PTO(ii))>0 % when the Y_PTO is inductance dominant
        Z_OPT.C(ii) = 0;
        Z_OPT.L(ii) = 1./abs(imag(Y_PTO(ii)).*wave.instf.w(ii));
        Z_OPT.R(ii)=1./real(Y_PTO(ii));
    else % when the Y_PTO is pure resistive
        Z_OPT.C(ii) = abs(imag(Y_PTO(ii))./wave.instf.w(ii));
        Z_OPT.L(ii) = 1./abs(imag(Y_PTO(ii)).*wave.instf.w(ii));
        Z_OPT.R(ii)=1./real(Y_PTO(ii));
    end
end
Z_OPT.C = timeseries(Z_OPT.C',simu.t');
Z_OPT.L = timeseries(Z_OPT.L',simu.t');
Z_OPT.R = timeseries(Z_OPT.R',simu.t');
Z_OPT.R_opt=timeseries(1./abs(Y_PTO'),simu.t');
Z_OPT.K_pto = timeseries((imag(Y_PTO).*wave.instf.w)',simu.t');
Z_OPT.B_pto = timeseries((real(Y_PTO))',simu.t');
Z_OPT.B_opt = timeseries((abs(Y_PTO))',simu.t');