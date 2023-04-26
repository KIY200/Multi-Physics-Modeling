function [M_7,K7,M] = pre_main_const(Trans,Tc,M_b1,M_b2,b1_Res,b2_Res,w,b1_Ma_all,b2_Ma_all)

% updating M7 and K7 if rotation is included 
M = [Trans*M_b1 zeros([6 6]);zeros([6 6]) Trans*M_b2];%12*12

for ii = 1:length(w)
    temp_Ma = [(squeeze(b1_Ma_all(ii,1:6,:))) zeros([6 6]); zeros([6 6]) (squeeze(b2_Ma_all(ii,7:12,:)))]; %12*12
    Ma_12(:,:,ii) = temp_Ma; % 12by12 added mass matrix for all frequencies
    M_12(:,:,ii) = temp_Ma+M; % 12by12 total mass matrix 
    M_7(:,:,ii)=Tc'*M_12(:,:,ii)*Tc; % 7by7 total mass matrix for all frequencies
   
end


K = [Trans*b1_Res zeros([6 6]);zeros([6 6]) Trans*b2_Res]; % 12 by 12 stiffness matrix
K7 = Tc'*K*Tc; % 7 by 7 stiffness matrix

end