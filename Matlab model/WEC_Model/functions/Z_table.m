function Z_OPT = Z_table(hydro,wave)

w = 2*pi./wave.Tref; % w reference table

for ii=1:length(w)
    Z_OPT.Rf(ii) = 1./hydro.B_rad_22(1,1,ii);
    Z_OPT.Rs(ii) = 1./hydro.B_rad_22(2,2,ii);
    Z_OPT.X_Lf(ii) = 1./hydro.K_hs_22(1,1,ii)*1j.*w(ii);
    Z_OPT.X_Ls(ii) = 1./hydro.K_hs_22(2,2,ii)*1j.*w(ii);
    Z_OPT.X_Cf(ii) = 1./(hydro.Mass_22(1,1,ii)*1j.*w(ii));
    Z_OPT.X_Cs(ii) = 1./(hydro.Mass_22(1,1,ii)*1j.*w(ii));
    
    Z_OPT.Zf(ii) = 1./(1./Z_OPT.Rf(ii)+1./Z_OPT.X_Lf(ii)+1./Z_OPT.X_Cf(ii));
    Z_OPT.Zs(ii) = 1./(1./Z_OPT.Rs(ii)+1./Z_OPT.X_Ls(ii)+1./Z_OPT.X_Cs(ii));
    
    Z_OPT.Z_eq(ii) = Z_OPT.Zf(ii)+Z_OPT.Zs(ii);
    Z_OPT.Y_eq(ii) = 1./Z_OPT.Z_eq(ii);
    Z_OPT.Y_pto(ii) = conj(Z_OPT.Y_eq(ii));
    
    Z_OPT.R_pto(ii) = 1./real(Z_OPT.Y_pto(ii));
    Z_OPT.C_pto(ii) = abs(imag(Z_OPT.Y_pto(ii))./w(ii));
    Z_OPT.L_pto(ii) = 1./abs(imag(Z_OPT.Y_pto(ii)).*w(ii));
    
    Z_OPT.R_opt(ii) = 1./abs(Z_OPT.Y_pto(ii));
end