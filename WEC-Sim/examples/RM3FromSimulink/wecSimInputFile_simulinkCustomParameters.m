% WEC-Sim Input File, written with custom Simulink parameters
% 25-Jan-2022 16:49:32

%% Simulation Class
simu = simulationClass(); 
simu.simMechanicsFile = 'RM3FromSimulink.slx'; 
simu.explorer = 'off'; 
simu.endTime = 400; 

%% Wave Class
waves = waveClass('regular'); 
waves.H = 2.5; 
waves.T = 8; 

%% Body Class
body(1) = bodyClass('hydroData/rm3.h5'); 
body(1).geometryFile = 'geometry/float.stl'; 
body(1).mass = 'equilibrium'; 
body(1).momOfInertia = [20907301 21306090.66 37085481.11]; 

%% Body Class
body(2) = bodyClass('hydroData/rm3.h5'); 
body(2).geometryFile = 'geometry/plate.stl'; 
body(2).mass = 'equilibrium'; 
body(2).momOfInertia = [94419614.57 94407091.24 28542224.82]; 

%% Constraint Class
constraint(1) = constraintClass('constraint1'); 
constraint(1).loc = [0 0 1]; 

%% PTO Class
pto(1) = ptoClass('pto1'); 
pto(1).c = 0*1200000; 
pto(1).loc = [0 0 0]; 
