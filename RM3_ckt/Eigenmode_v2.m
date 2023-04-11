function hydro = Eigenmode_v2(Bpto)
    %%% wave characteristic
    wave.T = h5read('hydro/rm3.h5','/simulation_parameters/T'); % wave periods 
    wave.H = 2; % wave heights corresponding to the above periods
    wave.w = 2*pi./wave.T;
    
    %%% Constraint matrix
    details.CSRT.CGf = h5read('hydro/rm3.h5','/body1/properties/cg'); %Center of gravity, Body 1
    details.CSRT.CGs = h5read('hydro/rm3.h5','/body2/properties/cg'); %Center of gravity, Body 2
    
    details.CSRT.d = abs(details.CSRT.CGf(3)-details.CSRT.CGs(3));
    
    Tc = [diag([1 1 1 1 1 1]) [0;0;1;0;0;0];...
           diag([1,1,1,1,1,1]) zeros(6,1)];
    Tc(1,5)=details.CSRT.d;Tc(2,4)=details.CSRT.d;
    
    %%% Mass matrice
    details.M.m_a_f=1000*h5read('hydro/rm3.h5','/body1/hydro_coeffs/added_mass/all'); % added mass, float
    details.M.m_a_s=1000*h5read('hydro/rm3.h5','/body2/hydro_coeffs/added_mass/all'); % added mass, spar
    
    details.M.mass_f = 1000*h5read('hydro/rm3.h5','/body1/properties/disp_vol'); % Mass, float
    details.M.mass_s = 1000*h5read('hydro/rm3.h5','/body2/properties/disp_vol'); % Mass, spar
    
    % moment of inertia
    details.M.MoI_f = [20907301 21306090.66 37085481.11]*1000;
    details.M.MoI_s = [94419614.57 94407091.24 28542224.82]*1000;
    
    details.M.m_f = [diag([details.M.mass_f details.M.mass_f details.M.mass_f details.M.MoI_f]);zeros(6,6)];
    details.M.m_s = [zeros(6,6);diag([details.M.mass_s details.M.mass_s details.M.mass_s details.M.MoI_s])];
    
    details.M.M_f = zeros(260,12,6);
    details.M.M_s = zeros(260,12,6);
    details.M.Mass = zeros(260,12,12);
    M7 = zeros(260,7,7);
    
    for ii=1:260
    details.M.M_f(ii,:,:) = details.M.m_f+squeeze(details.M.m_a_f(ii,:,:));
    details.M.M_s(ii,:,:) = details.M.m_s+squeeze(details.M.m_a_s(ii,:,:));
    details.M.Mass(ii,:,:) = [squeeze(details.M.M_f(ii,1:6,:)) zeros(6,6);zeros(6,6) squeeze(details.M.M_s(ii,7:12,:))];
    M7(ii,:,:) = Tc'*squeeze(details.M.Mass(ii,:,:))*Tc;
    end
    
    
    %%% K matrice(Restoring Force Coefficients)
    
    details.K.f = 1000*9.81*h5read('hydro/rm3.h5','/body1/hydro_coeffs/linear_restoring_stiffness'); % Linear restoring coefficient, Body 1
    details.K.s = 1000*9.81*h5read('hydro/rm3.h5','/body2/hydro_coeffs/linear_restoring_stiffness'); % Linear restoring coefficient, Body 2
    details.K.K_hs = [details.K.f zeros(size(details.K.f));zeros(size(details.K.s)) details.K.s];
    K_hs7 = Tc'*details.K.K_hs*Tc;
    
    %%% B matrice(Radiation Damping Coeffcients)
    
    details.B.nf = h5read('hydro/rm3.h5','/body1/hydro_coeffs/radiation_damping/all');
    details.B.ns = h5read('hydro/rm3.h5','/body2/hydro_coeffs/radiation_damping/all');
    
    
    details.B.B_f = zeros(260,12,6);
    details.B.B_s = zeros(260,12,6);
    details.B.B_rad = zeros(260,12,12);
    B_rad7 = zeros(260,7,7);
    
    
    
    Bpto7 = zeros(260,7,7);
    Bpto7(:,7,7)=Bpto;
    for ii=1:260
    details.B.B_f(ii,:,:) = 1000*wave.w(ii)*details.B.nf(ii,:,:); % radiation for all frequencies
    details.B.B_s(ii,:,:) = 1000*wave.w(ii)*details.B.ns(ii,:,:); % radiation for all frequencies
    % details.B.B_rad(ii,:,:) = [squeeze(details.B.B_f(ii,:,:)) squeeze(details.B.B_s(ii,:,:))];
    details.B.B_rad(ii,:,:) = ...
    [squeeze(details.B.B_f(ii,1:6,:)) zeros(6,6); ... 
     zeros(6,6)    squeeze(details.B.B_s(ii,7:12,:))];
    B_rad7(ii,:,:) = Tc'*squeeze(details.B.B_rad(ii,:,:))*Tc;
    end
    B = B_rad7+Bpto7;
    %%% solving Eigen value problem
    
    % M_f*x''+K_hs_f*x = 0
    % M_f*(-w^2)*e^jwt*phi + K_hs_f*e^jwt*phi = 0
    % M_f*(-w^2)*phi + K_hs_f*phi = 0
    % M_f^-1 * K_hs_f*phi = w^2*phi
    % let w^2 = lambda, M_f^-1 * K_hs_f = A
    % A[]*phi = lambda*phi <- eigenvalue probledetails.M.
    
    eigen.V = zeros(260,7,7);
    eigen.D = zeros(260,7,7);
    
    % A = zeros(12,12,260);
    % for ii=1:260
    % A(:,:,ii) = squeeze((Mass(ii,:,:)))^(-1)*K_hs;
    % end
    
    for ii=1:260
    [eigen.V(ii,:,:),eigen.D(ii,:,:)] = eig(K_hs7,squeeze(M7(ii,:,:)));
    end
    
    eigen.E = zeros(260,1,7);
    
    for ii =1:260
    eigen.E(ii,:,:)=diag(squeeze(eigen.D(ii,:,:)));
    end
    
    eigen.E(abs(eigen.E)<1e-16)=0;
    eigen.E=squeeze(eigen.E);
    
    %%% Determine dominant eigenmode
    w_struc = sqrt(abs(eigen.E));
    % E_max = zeros(260,2);
    value=[];
    temp=zeros(260,7);
    I=[];
    for ii=1:260
        temp(ii,:)=abs(w_struc(ii,:)-wave.w(1,ii));
        [val,inx]=mink(temp(ii,:),2);
        I=cat(1,I,inx);
        value=cat(1,value,val);
    end
    Phi =zeros(260,7,2);
    for ii=1:260
        Phi(ii,:,1) = eigen.V(ii,:,I(ii,1));
        Phi(ii,:,2) = eigen.V(ii,:,I(ii,2));
    end
    %%% DOF reduction
    Mass_22=zeros(260,2,2);
    B_rad_22=zeros(260,2,2);
    K_hs_22=zeros(260,2,2);
    B22=zeros(260,2,2);
    Bpto22=zeros(260,2,2);
    for ii=1:260
        Mass_22(ii,:,:) = squeeze(Phi(ii,:,:))'*squeeze(M7(ii,:,:))*squeeze(Phi(ii,:,:));
        B_rad_22(ii,:,:) = squeeze(Phi(ii,:,:))'*squeeze(B_rad7(ii,:,:))*squeeze(Phi(ii,:,:));
        K_hs_22(ii,:,:) = squeeze(Phi(ii,:,:))'*K_hs7*squeeze(Phi(ii,:,:));
        B22(ii,:,:)=squeeze(Phi(ii,:,:))'*squeeze(B(ii,:,:))*squeeze(Phi(ii,:,:));
        Bpto22(ii,:,:)=squeeze(Phi(ii,:,:))'*squeeze(Bpto7(ii,:,:))*squeeze(Phi(ii,:,:));
    end
    hydro.B22=permute(B22,[2,3,1]);
    hydro.B_rad_22=permute(B_rad_22,[2,3,1]);
    hydro.K_hs_22=permute(K_hs_22,[2,3,1]);
    hydro.Mass_22=permute(Mass_22,[2,3,1]);
    hydro.Phi = permute(Phi,[2,3,1]);
    hydro.Bpto22 = permute(Bpto22,[2,3,1]);
    hydro.Tc = Tc;
    % save('22_Yong.mat',"B_rad_22","Mass_22","K_hs_22","Phi","Tc")
    % eigen_V=permute(eigen.V,[2,3,1]);
    % eigen_D=permute(eigen.D,[2,3,1]);
    % % details.B.B_rad=permute(details.B.B_rad,[2,3,1]);
    % % dig_M=squeeze(eigen.V(50,:,:))*squeeze(M7(50,:,:));
    % % dig_M(abs(dig_M)<1e2)=0;
    % % B7_p=permute(B7_p,[2,3,1]);
    % B_rad7 = permute(B_rad7,[2,3,1]);

end


