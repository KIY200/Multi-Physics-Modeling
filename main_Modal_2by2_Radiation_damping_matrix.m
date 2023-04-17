 %For more general information please read the README file

clear all
clc
wave.T = 8; 
%%
% Loading the hydrodynamic coefficients of the system 
[d,M_b1,M_b2,b1_Ma_all,b2_Ma_all,b1_Res,b2_Res,b1_C_rad_all,b2_C_rad_all,b1_cg,b2_cg,...
b1_Ex_re_all,b2_Ex_re_all,b1_Ex_im_all,b2_Ex_im_all,w] = prepro_hydro_con();


%initial constraint matrix (linear)
 Tc = zeros([12 7]);
Tc(7,1)=1; Tc(8,2)=1;Tc(9,3)=1;Tc(10,4)=1;Tc(11,5)=1;
Tc(12,6)=1; Tc(1,1)=1;Tc(1,5)=d;Tc(2,2)=1;Tc(2,4)=d;
Tc(3,3)=0;Tc(3,5)=0;Tc(3,7)=1;Tc(4,4)=1;Tc(5,5)=1;Tc(6,6)=1; 

%constant transformation matrix
Trans = diag(ones([6 1]));

[M7,K7,M12] = pre_main_const(Trans,Tc,M_b1,M_b2,b1_Res,b2_Res);

%Modal analysis

[V_e,D_e] = eig(K7,M7);

for ii=1:7
    D_vectore(ii,1)=D_e(ii,ii);
end

T_e = 2*pi./sqrt(D_vectore);

target = ones(size(T_e))*wave.T;
    temp = abs(target - T_e);
    [B,I] = mink(temp,2,'ComparisonMethod','abs');
    %here I is the 2 most closest eigen values to the incoming wave

    v_phi = [V_e(:,I(1)) V_e(:,I(2))];
M2 = v_phi'*M7*v_phi;
K2 = v_phi'*K7*v_phi;

% excitation coefficient matrix Real part 
for ii = 1:length(w)
    temp_ex_b1_re = squeeze(b1_Ex_re_all(ii,:,:));
    temp_ex_b2_re = squeeze(b2_Ex_re_all(ii,:,:));
    temp_ex_re = [temp_ex_b1_re;temp_ex_b2_re];
    Ex_re_12(:,:,ii) = temp_ex_re; %12by12 Real Excitation coefficient matrix for all each frequency
    Ex_re_7(:,:,ii)=Tc'*Ex_re_12(:,:,ii); %7by7 Real Excitation coefficient matrix for all each frequency
    Ex_re_2(:,:,ii) = v_phi'*squeeze(Ex_re_7(:,:,ii)); %2by2 Real Excitation coefficient matrix for all each frequency
end

% excitation coefficient matrix Imag part 
for ii = 1:length(w)
    temp_ex_b1_im = squeeze(b1_Ex_im_all(ii,:,:));
    temp_ex_b2_im = squeeze(b2_Ex_im_all(ii,:,:));
    temp_ex_im = [temp_ex_b1_im;temp_ex_b2_im];
    Ex_im_12(:,:,ii) = temp_ex_im; %12by12 Real Excitation coefficient matrix for all each frequency
    Ex_im_7(:,:,ii)=Tc'*Ex_im_12(:,:,ii); %7by7 Real Excitation coefficient matrix for all each frequency
    Ex_im_2(:,:,ii) = v_phi'*squeeze(Ex_im_7(:,:,ii)); %2by2 Real Excitation coefficient matrix for all each frequency
end

% Radiation damping matrix 
for ii = 1:length(w)
    temp_rd = [(squeeze(b1_C_rad_all(ii,1:6,:))) zeros([6 6]); zeros([6 6]) (squeeze(b2_C_rad_all(ii,7:12,:)))];
    C_12(:,:,ii) = temp_rd; %12by12 Damping matrix for all each frequency
    C_7(:,:,ii)=Tc'*C_12(:,:,ii)*Tc; %7by7 Damping matrix for all each frequency
    C_2(:,:,ii) = v_phi'*squeeze(C_7(:,:,ii))*v_phi; %2by2 Damping matrix for all each frequency
end

% added mass matrix 
for ii = 1:length(w)
    temp_Ma = [(squeeze(b1_Ma_all(ii,1:6,:))) zeros([6 6]); zeros([6 6]) (squeeze(b2_Ma_all(ii,7:12,:)))]; %12*12
    Ma_12(:,:,ii) = temp_Ma; %12by12 added mass matrix for all each frequency
    M_12(:,:,ii) = temp_Ma+M12;
    Ma_7(:,:,ii)=Tc'*Ma_12(:,:,ii)*Tc; %7by7 added mass matrix for all each frequency
    M_7(:,:,ii)=Tc'*Ma_12(:,:,ii)*Tc+M7;
    Ma_2(:,:,ii) = v_phi'*squeeze(Ma_7(:,:,ii))*v_phi; %2by2 Added mass matrix for all each frequency
    M_2(:,:,ii) = v_phi'*squeeze(Ma_7(:,:,ii))*v_phi+M2;
end
% save('coef22_v_Nasim.mat',"C_2","M2","K2","v_phi","Tc")
% C = reshape(M_2,[],size(M_2,3),1);
% xlswrite('Mass.xlsx',C)
% C = reshape(Ex_re_2,[],size(Ex_re_2,3),1);
% xlswrite('Ex_re.xlsx',C)
% C = reshape(Ex_im_2,[],size(Ex_im_2,3),1);
% xlswrite('Ex_im.xlsx',C)
% C = reshape(C_2,[],size(C_2,3),1);
% xlswrite('Rad_C.xlsx',C)