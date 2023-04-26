function [M7,K7,Ma,K] = pre_main_const(Trans,Tc,M_b1,M_b2,b1_Ma,b2_Ma,b1_Res,b2_Res,k_pto)

% updating M7 and K7
M = [M_b1 zeros([6 6]);zeros([6 6]) Trans*M_b2];%12*12
Ma = [(squeeze(b1_Ma(1,1:6,:))) zeros([6 6]); zeros([6 6]) (squeeze(b2_Ma(1,7:12,:)))]; %12*12
M = M + Ma;
M7 = Tc'*M*Tc;  %total mass (moment of inertia, mass and added mass)
Ma7 = Tc'*Ma*Tc; % 7*7 added mass matrix only

K = [Trans*b1_Res zeros([6 6]);zeros([6 6]) Trans*b2_Res];
K7 = Tc'*K*Tc;
K7(7,7)=K7(7,7)+k_pto;

end