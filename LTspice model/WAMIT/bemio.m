hydro_float = struct();

hydro_float = readWAMIT(hydro_float,'float.out',[]);
hydro_float = radiationIRF(hydro_float,60,[],[],[],[]);
hydro_float = radiationIRFSS(hydro_float,[],[]);
hydro_float = excitationIRF(hydro_float,157,[],[],[],[]);
writeBEMIOH5(hydro_float)
plotBEMIO(hydro_float)

hydro_spar = struct();

hydro_spar = readWAMIT(hydro_spar,'spar.out',[]);
hydro_spar = radiationIRF(hydro_spar,60,[],[],[],[]);
hydro_spar = radiationIRFSS(hydro_spar,[],[]);
hydro_spar = excitationIRF(hydro_spar,157,[],[],[],[]);
writeBEMIOH5(hydro_spar)
plotBEMIO(hydro_spar)

save hydro_float hydro_float
save hydro_spar hydro_spar