function hydro = HD_param(Tc_param)
%% Constraint matrix formulation
switch Tc_param
    case 1
        CSRT.CGf = h5read('hydro/rm3.h5','/body1/properties/cg'); %Center of gravity, Body 1
        CSRT.CGs = h5read('hydro/rm3.h5','/body2/properties/cg'); %Center of gravity, Body 2
        CSRT.d = abs(CSRT.CGf(3)-CSRT.CGs(3));
    
        Tc = [diag([1 1 1 1 1 1]) [0;0;1;0;0;0];...
               diag([1,1,1,1,1,1]) zeros(6,1)];
        Tc(1,5)=CSRT.d;Tc(2,4)=CSRT.d;
    case 2
            CSRT.CGf = h5read('hydro/rm3.h5','/body1/properties/cg'); %Center of gravity, Body 1
        CSRT.CGs = h5read('hydro/rm3.h5','/body2/properties/cg'); %Center of gravity, Body 2
        CSRT.d = abs(CSRT.CGf(3)-CSRT.CGs(3));
    
        Tc = [diag([1 1 0 1 1 1]) [0;0;1;0;0;0];...
               diag([1,1,1,1,1,1]) zeros(6,1)];
        Tc(1,5)=CSRT.d;Tc(2,4)=CSRT.d;
end

    [hydro.F7,hydro.M7,hydro.K_hs7,hydro.B_rad7,hydro.wave] = const_hydro(Tc);