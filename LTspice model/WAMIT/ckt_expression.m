load("lupadata_spring2024_sparD1_14m.mat")
T=2;
H=0.2;
hydro=hydro(T,lupadata);
K_mooring = 520;


C_f = (hydro.float.M_a+hydro.float.m);
C_s = (hydro.spar.M_a+hydro.spar.m);

L_f = 1/hydro.float.K_hs;
L_s = 1/(hydro.spar.K_hs+K_mooring);

R_f = 1/hydro.float.rad_damp;
R_s = 1/hydro.spar.rad_damp;

R_pto = 1/(350+500);

Fex_f = H/2*(hydro.float.Fex_re); %+1i*hydro.float.Fex_im)*(cos+1i*sin());
Fex_s = H/2*(hydro.spar.Fex_re);% 1i*hydro.spar.Fex_im)*(cos+1i*sin);