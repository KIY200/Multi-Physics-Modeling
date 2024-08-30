function Z_OPT = Z_table_RM3(hydro)
Tref = h5read('hydro/rm3.h5','/simulation_parameters/T');
w = 2*pi./Tref; % w reference table

for ii=1:length(w) %% ii represent index in hydro dynamic coefficients(1-260).
    M1=squeeze(hydro.Mass_22(1,1,ii));
    M2=squeeze(hydro.Mass_22(2,2,ii));
    B1=squeeze(hydro.B_rad_22(1,1,ii));
    B2=squeeze(hydro.B_rad_22(2,2,ii));
    K1=squeeze(hydro.K_hs_22(1,1,ii));
    K2=squeeze(hydro.K_hs_22(2,2,ii));
    Kpto_stablelimit = -K1*K2/(K1 + K2);
    Z_OPT.Z1(ii) = 1i*w(ii)*(M1) + 1/(1i*w(ii))*K1 + B1;
    Z_OPT.Z2(ii) = 1i*w(ii)*(M2) + 1/(1i*w(ii))*K2 + B2;
    Z_OPT.Z_eq(ii) = Z_OPT.Z1(ii)*Z_OPT.Z2(ii)/(Z_OPT.Z1(ii)+Z_OPT.Z2(ii));
    Z_OPT.Cpto_opt_damping(ii) = abs(Z_OPT.Z_eq(ii));
    Z_OPT.Cpto_opt_reactive(ii) = real(Z_OPT.Z_eq(ii));
    Z_OPT.Kpto_opt_reactive(ii) = w(ii)*imag(Z_OPT.Z_eq(ii));

    if Z_OPT.Kpto_opt_reactive(ii) < Kpto_stablelimit
        % disp('Unstable stiffness...recalculating stiffness and damping')
        Z_OPT.Kpto_opt_reactive(ii) = 0.9*Kpto_stablelimit;
        Z_OPT.Cpto_opt_reactive(ii) = sqrt((imag(Z_OPT.Z_eq(ii)) - 1/w(ii)*Z_OPT.Kpto_opt_reactive(ii))^2 + real(Z_OPT.Z_eq(ii))^2);
    end
end
