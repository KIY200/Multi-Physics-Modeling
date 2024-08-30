function hydro = hydro(wave_T,lupadata)

wave.T = wave_T;
wave.f = 1/wave.T;

wave.Tcomp=abs(lupadata.T.*wave.f-1);
[wave.value,wave.indx]=min(wave.Tcomp);

hydro.float.Fex_re=lupadata.float.F_ex_re(wave.indx);
hydro.float.Fex_im=lupadata.float.F_ex_im(wave.indx);
hydro.float.M_a=lupadata.float.addedmass(wave.indx);
hydro.float.m=lupadata.float.mass;
hydro.float.rad_damp=lupadata.float.damping(wave.indx);
hydro.float.K_hs = lupadata.float.stiffness;

hydro.spar.Fex_re=lupadata.spar.F_ex_re(wave.indx);
hydro.spar.Fex_im=lupadata.spar.F_ex_im(wave.indx);
hydro.spar.M_a=lupadata.spar.addedmass(wave.indx);
hydro.spar.m=lupadata.spar.mass;
hydro.spar.rad_damp=lupadata.spar.damping(wave.indx);
hydro.spar.K_hs = lupadata.spar.stiffness;
