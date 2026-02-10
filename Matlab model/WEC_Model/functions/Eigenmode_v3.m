function hydro = Eigenmode_v3(Tc_param)
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

    [F7,M7,K_hs7,B_rad7,wave] = const_hydro(Tc);
    %% Solving Eigen value problem
    
    % M_f*x''+K_hs_f*x = 0
    % M_f*(-w^2)*e^jwt*phi + K_hs_f*e^jwt*phi = 0
    % M_f*(-w^2)*phi + K_hs_f*phi = 0
    % M_f^-1 * K_hs_f*phi = w^2*phi
    % let w^2 = lambda, M_f^-1 * K_hs_f = A
    % A[]*phi = lambda*phi <- eigenvalue details.M.
    
    eigen.V = zeros(260,7,7);
    eigen.D = zeros(260,7,7);
    
    for ii=1:260
    [eigen.V(ii,:,:),eigen.D(ii,:,:)] = eig(K_hs7,squeeze(M7(ii,:,:)));
    end
    
    eigen.E = zeros(260,1,7);
    
    for ii =1:260
    eigen.E(ii,:,:)=diag(squeeze(eigen.D(ii,:,:)));
    end
    
    eigen.E(abs(eigen.E)<1e-3)=0;
    eigen.E=squeeze(eigen.E);
    
    %% Determine dominant eigenmode
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
        Phi(ii,:,1) = abs(eigen.V(ii,:,I(ii,1)));
        Phi(ii,:,2) = abs(eigen.V(ii,:,I(ii,2)));
    end

    %%% DOF reduction
    Mass_22=zeros(260,2,2);
    B_rad_22=zeros(260,2,2);
    K_hs_22=zeros(260,2,2);
    F_ex_22=zeros(260,1,2);
    % B22=zeros(260,2,2);
%     Bpto22=zeros(260,2,2);

    for ii=1:260
        Mass_22(ii,:,:) = squeeze(Phi(ii,:,:))'*squeeze(M7(ii,:,:))*squeeze(Phi(ii,:,:));
        B_rad_22(ii,:,:) = squeeze(Phi(ii,:,:))'*squeeze(B_rad7(ii,:,:))*squeeze(Phi(ii,:,:));
        K_hs_22(ii,:,:) = squeeze(Phi(ii,:,:))'*K_hs7*squeeze(Phi(ii,:,:));
        F_ex_22(ii,:,:) = squeeze(F7(ii,:,:))*squeeze(Phi(ii,:,:));
        % B22(ii,:,:)=squeeze(Phi(ii,:,:))'*squeeze(B(ii,:,:))*squeeze(Phi(ii,:,:));
%         Bpto22(ii,:,:)=squeeze(Phi(ii,:,:))'*squeeze(Bpto7(ii,:,:))*squeeze(Phi(ii,:,:));
    end

    % hydro.B22=permute(B22,[2,3,1]);
    hydro.B_rad_22=permute(B_rad_22,[2,3,1]);
    hydro.K_hs_22=permute(K_hs_22,[2,3,1]);
    hydro.Mass_22=permute(Mass_22,[2,3,1]);
    hydro.Phi = permute(Phi,[2,3,1]);
    hydro.F_ex_22=permute(F_ex_22,[3,2,1]);
% for ii=27:31
%     hydro.Phi(:,:,ii)=[squeeze(hydro.Phi(:,2,ii)) squeeze(hydro.Phi(:,1,ii))];
% end
    hydro.Tc = Tc;

end

