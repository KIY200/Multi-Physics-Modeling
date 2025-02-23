function Z_OPT_RM3 = Z_match_RM3(hydro,wave,simu)

wave.instf.w = 2*pi*wave.instf.f; % load instantaneous frequency of input wave
K_pto = zeros(size(simu.t)); % initalize the control of PTO Impedance 
B_pto = zeros(size(simu.t));
B_opt = zeros(size(simu.t));
for ii=1:length(simu.t)
   K_pto(ii)=hydro.Z_table_RM3.Cpto_opt_reactive(wave.indx(ii));
   B_pto(ii)=hydro.Z_table_RM3.Bpto_opt_reactive(wave.indx(ii));
   B_opt(ii)=hydro.Z_table_RM3.Bpto_opt_damping(wave.indx(ii));
end

Z_OPT_RM3.instf.K_pto = timeseries((K_pto)',simu.t');
Z_OPT_RM3.instf.B_pto = timeseries((B_pto)',simu.t');
Z_OPT_RM3.instf.B_opt = timeseries((B_opt)',simu.t');
Z_OPT_RM3.fixed.K_pto = hydro.Z_table_RM3.Cpto_opt_reactive(wave.mode.indx);
Z_OPT_RM3.fixed.B_pto = hydro.Z_table_RM3.Bpto_opt_reactive(wave.mode.indx);
Z_OPT_RM3.fixed.B_opt = hydro.Z_table_RM3.Bpto_opt_damping(wave.mode.indx);