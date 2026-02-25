function hydro = Eigenmode_v3(filename)
%% Constraint matrix formulation
        CSRT.WEC1.CGf = [0,0,0.02]; %Center of gravity, Body 1
        CSRT.WEC1.CGs = [0,0,-1.345]; %Center of gravity, Body 2
        CSRT.WEC2.CGf = [0,0,0.02]; %Center of gravity, Body 1
        CSRT.WEC2.CGs = [0,0,-1.345]; %Center of gravity, Body 2
        CSRT.WEC1.d = abs(CSRT.WEC1.CGf(3)-CSRT.WEC1.CGs(3));
        CSRT.WEC2.d = abs(CSRT.WEC2.CGf(3)-CSRT.WEC2.CGs(3));
    
        Tc_WEC1 = [diag([1 1 0 1 1 1]) [0;0;1;0;0;0];...
               diag([1,1,1,1,1,1]) zeros(6,1)];
        Tc_WEC1(1,5)=CSRT.WEC1.d;
        Tc_WEC1(2,4)=CSRT.WEC1.d;

        Tc_WEC2 = [diag([1 1 0 1 1 1]) [0;0;1;0;0;0];...
               diag([1,1,1,1,1,1]) zeros(6,1)];
        Tc_WEC2(1,5)=CSRT.WEC2.d;
        Tc_WEC2(2,4)=CSRT.WEC2.d;

    [F7_WEC1,M7_WEC1,K_hs7_WEC1,B_rad7_WEC1,wave_WEC1] = const_hydro(filename, Tc_WEC1, [1 2]);
    [Phi, eigen] = eigsolve_hydro(M7_WEC1, K_hs7_WEC1, wave_WEC1.w);
    hydro.WEC1 = reduce_hydro(M7_WEC1, B_rad7_WEC1, K_hs7_WEC1, F7_WEC1, Phi);
    hydro.WEC1.eigen = eigen;
    hydro.WEC1.wave = wave_WEC1;
    hydro.WEC1.F7 = F7_WEC1;

    [F7_WEC2,M7_WEC2,K_hs7_WEC2,B_rad7_WEC2,wave_WEC2] = const_hydro(filename, Tc_WEC2, [3 4]);
    [Phi, eigen] = eigsolve_hydro(M7_WEC2, K_hs7_WEC2, wave_WEC2.w);
    hydro.WEC2 = reduce_hydro(M7_WEC2, B_rad7_WEC2, K_hs7_WEC2, F7_WEC2, Phi);
    hydro.WEC2.eigen = eigen;
    hydro.WEC2.wave = wave_WEC2;
    hydro.WEC2.F7 = F7_WEC2;

    hydro.Tc.WEC1 = Tc_WEC1;
    hydro.Tc.WEC2 = Tc_WEC2;

end
