function Z_OPT = Z_EX_match(PTO,wave,simu)

wave.instf.w = 2*pi*wave.instf.f';

Z_OPT.Rf = 1./PTO.B_rad_b1;
Z_OPT.Rs = 1./PTO.B_rad_b2;
Z_OPT.X_Lf = 1./PTO.K_hs_b1*1j.*wave.instf.w;
Z_OPT.X_Ls = 1./PTO.K_hs_b2*1j.*wave.instf.w;
Z_OPT.X_Cf = 1./(PTO.Mass_b1*1j.*wave.instf.w);
Z_OPT.X_Cs = 1./(PTO.Mass_b2*1j.*wave.instf.w);

Z_OPT.Zf = 1./(1./Z_OPT.Rf+1./Z_OPT.X_Lf+1./Z_OPT.X_Cf);
Z_OPT.Zs = 1./(1./Z_OPT.Rs+1./Z_OPT.X_Ls+1./Z_OPT.X_Cs);

Z_OPT.Feq = (Fex_1.Data./Z_OPT.Zf-Fex_2.data./Z_OPT.Zs)/(Z_OPT.Zf+Z_OPT.Zs);


Z_OPT.Z_eq = Z_OPT.Zf+Z_OPT.Zs;
Z_OPT.Y_eq = 1./Z_OPT.Z_eq;
Z_OPT.Y_pto = conj(Z_OPT.Y_eq);

Z_OPT.R_pto = 1./real(Z_OPT.Y_pto);
Z_OPT.C_pto = abs(imag(Z_OPT.Y_pto)./wave.instf.w);
Z_OPT.L_pto = 1./abs(imag(Z_OPT.Y_pto).*wave.instf.w);

Z_OPT.R_opt = 1./abs(Z_OPT.Y_pto);

Z_OPT.R=timeseries(1./real(Z_OPT.Y_pto),simu.t');
Z_OPT.L=timeseries(1./abs(imag(Z_OPT.Y_pto).*wave.instf.w),simu.t');
Z_OPT.C=timeseries(abs(imag(Z_OPT.Y_pto)./wave.instf.w),simu.t');

Z_OPT.R_opt=timeseries(1./abs(Z_OPT.Y_pto),simu.t');
