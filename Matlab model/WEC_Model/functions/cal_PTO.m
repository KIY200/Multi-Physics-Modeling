function [PTO,Z_OPT]=cal_PTO(hydro,time,wave)

simu.t=time;

for ii=1:length(simu.t)
PTO.Mass(:,:,ii) = hydro.Mass_22(:,:,wave.indx(ii));
PTO.K_hs(:,:,ii) = hydro.K_hs_22(:,:,wave.indx(ii));
PTO.B_rad22(:,:,ii) = hydro.B_rad_22(:,:,wave.indx(ii));
end

PTO.Mass_b1 = squeeze(PTO.Mass(1,1,:));
PTO.Mass_b2 = squeeze(PTO.Mass(2,2,:));
PTO.K_hs_b1 = squeeze(PTO.K_hs(1,1,:));
PTO.K_hs_b2 = squeeze(PTO.K_hs(2,2,:));
PTO.B_rad_b1 = squeeze(PTO.B_rad22(1,1,:));
PTO.B_rad_b2 = squeeze(PTO.B_rad22(2,2,:));

PTO.R1=timeseries(1./PTO.B_rad_b1,simu.t');
PTO.R2=timeseries(1./PTO.B_rad_b2,simu.t');
PTO.L1=timeseries(1./PTO.K_hs_b1,simu.t');
PTO.L2=timeseries(1./PTO.K_hs_b2,simu.t');
PTO.C1=timeseries(PTO.Mass_b1,simu.t');
PTO.C2=timeseries(PTO.Mass_b2,simu.t');

