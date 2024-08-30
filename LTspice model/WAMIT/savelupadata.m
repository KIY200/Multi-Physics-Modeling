%% Save LUPA data

load hydro_float
load hydro_spar_D1_14m.mat
%%
rho = 1000;
g = 9.81;
lupadata.w = hydro_float.w';
lupadata.T = 2*pi./lupadata.w;

lupadata.float.mass = 245.84;                    % Fall 2023
lupadata.float.stiffness = 7.7e3;
lupadata.float.damping = squeeze(hydro_float.B(3,3,:)).*lupadata.w*rho;
lupadata.float.addedmass = squeeze(hydro_float.A(3,3,:))*rho*g;
lupadata.float.F_ex_re = squeeze(hydro_float.ex_re(3,1,:))*rho*g;
lupadata.float.F_ex_im = squeeze(hydro_float.ex_im(3,1,:))*rho*g;

lupadata.spar.mass = 202.21;                     % Fall 2023
lupadata.spar.stiffness = 2.2e-4;               
lupadata.spar.damping = squeeze(hydro_spar.B(3,3,:)).*lupadata.w*rho;
lupadata.spar.addedmass = squeeze(hydro_spar.A(3,3,:))*rho*g;
lupadata.spar.F_ex_re = squeeze(hydro_spar.ex_re(3,1,:))*rho*g;
lupadata.spar.F_ex_im = squeeze(hydro_spar.ex_re(3,1,:))*rho*g;

save lupadata_spring2024_sparD1_14m lupadata