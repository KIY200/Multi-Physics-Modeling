 % general purpose code to generate 2 by 2 matrices for mass, stiffness,
 % damping, and excitation coefficients for RM3 system using Eigen analysis

clear all
clc


% Loading the hydrodynamic coefficients of the system 
[d,M_b1,M_b2,b1_Ma_all,b2_Ma_all,b1_Res,b2_Res,b1_C_rad_all,b2_C_rad_all,b1_cg,b2_cg,...
b1_Ex_re_all,b2_Ex_re_all,b1_Ex_im_all,b2_Ex_im_all,w] = prepro_hydro_const();


%initial constraint matrix (linear)
 Tc = zeros([12 7]);
Tc(7,1)=1; Tc(8,2)=1;Tc(9,3)=1;Tc(10,4)=1;Tc(11,5)=1;
Tc(12,6)=1; Tc(1,1)=1;Tc(1,5)=d;Tc(2,2)=1;Tc(2,4)=d;
Tc(3,3)=0;Tc(3,5)=0;Tc(3,7)=1;Tc(4,4)=1;Tc(5,5)=1;Tc(6,6)=1; 

%constant transformation matrix, assuming unity due to small rotations
Trans = diag(ones([6 1]));

[M7,K7,M12] = pre_main_const(Trans,Tc,M_b1,M_b2,b1_Res,b2_Res,w,b1_Ma_all,b2_Ma_all);

%Modal analysis

for ii=1 : length(w)

[V_e,D_e] = eig(K7,M7(:,:,ii));

for jj=1:7
    D_vectore(jj,1)=D_e(jj,jj);
end

T_e = 2*pi./sqrt(D_vectore);

target = ones(size(T_e))*2*pi/w(ii);
    temp = abs(target - T_e);
    [B,I] = mink(temp,2,'ComparisonMethod','abs');

    %here I is the 2 most closest eigen values to the incoming wave
    %frequency

    v_phi(:,:,ii) = [V_e(:,I(1)) V_e(:,I(2))];

M2(:,:,ii) = v_phi(:,:,ii)'*M7(:,:,ii)*v_phi(:,:,ii);
K2(:,:,ii) = v_phi(:,:,ii)'*K7*v_phi(:,:,ii);

% excitation coefficient matrix Real part 

    temp_ex_b1_re = squeeze(b1_Ex_re_all(ii,:,:));
    temp_ex_b2_re = squeeze(b2_Ex_re_all(ii,:,:));
    temp_ex_re = [temp_ex_b1_re;temp_ex_b2_re];
    Ex_re_12(:,:,ii) = temp_ex_re; % 12by12 Real Excitation coefficient matrix for all  frequencies
    Ex_re_7(:,:,ii)=Tc'*Ex_re_12(:,:,ii); % 7by7 Real Excitation coefficient matrix for all  frequencies
    Ex_re_2(:,:,ii) = v_phi(:,:,ii)'*squeeze(Ex_re_7(:,:,ii)); % 2by2 Real Excitation coefficient matrix for all  frequencies


% excitation coefficient matrix Imag part 

    temp_ex_b1_im = squeeze(b1_Ex_im_all(ii,:,:));
    temp_ex_b2_im = squeeze(b2_Ex_im_all(ii,:,:));
    temp_ex_im = [temp_ex_b1_im;temp_ex_b2_im];
    Ex_im_12(:,:,ii) = temp_ex_im; % 12by12 Real Excitation coefficient matrix for all  frequencies
    Ex_im_7(:,:,ii)=Tc'*Ex_im_12(:,:,ii); % 7by7 Real Excitation coefficient matrix for all frequencies
    Ex_im_2(:,:,ii) = v_phi(:,:,ii)'*squeeze(Ex_im_7(:,:,ii)); % 2by2 Real Excitation coefficient matrix for all frequencies


% Radiation damping matrix 

    temp_rd = [(squeeze(b1_C_rad_all(ii,1:6,:))) zeros([6 6]); zeros([6 6]) (squeeze(b2_C_rad_all(ii,7:12,:)))];
    C_12(:,:,ii) = temp_rd; % 12by12 Damping matrix for all  frequencies
    C_7(:,:,ii)=Tc'*C_12(:,:,ii)*Tc; % 7by7 Damping matrix for all frequencies
    C_2(:,:,ii) = v_phi(:,:,ii)'*squeeze(C_7(:,:,ii))*v_phi(:,:,ii); % 2by2 Damping matrix for all frequencies

end
%%% uncomet if you want to have the results in Excel foramt
% C = reshape(M_2,[],size(M_2,3),1);
% xlswrite('Mass.xlsx',C)
% C = reshape(Ex_re_2,[],size(Ex_re_2,3),1);
% xlswrite('Ex_re.xlsx',C)
% C = reshape(Ex_im_2,[],size(Ex_im_2,3),1);
% xlswrite('Ex_im.xlsx',C)
% C = reshape(C_2,[],size(C_2,3),1);
% xlswrite('Rad_C.xlsx',C)