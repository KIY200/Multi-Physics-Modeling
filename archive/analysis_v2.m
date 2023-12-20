%% RM3 Model Analysis

%% run WEC-Sim
clc; clear; close all;

addpath(genpath('WEC-Sim'))

%%%Call WEC-Sim initialization
cd('WEC-Sim/examples/RM3/')

%Run WEC-Sim model
t_start=tic;
wecSim
t_end=toc(t_start);
output.ElapsedTime=t_end;

%Save output as mat file
cd ../../../Results

if waves.type == "regular"
    filename_WEC = sprintf('out_WEC_Sim_T_%d',waves.T);
else 
    filename_WEC = sprintf('out_WEC_Sim_ir_T_%d',waves.T);
end
save(filename_WEC,'output')
save('current','output','simu','waves','pto')
cd ../

%% run equivalent ckt simulation
clc;clear;close all;
WEC_Sim=load('results/current');

%%%Call equivalent circuit initialization
run('RM3_ckt/Branches/rm3_ckt_init_3.m')

%%%Run equivalent circuit model
t_start=tic;
out_ckt=sim('RM3_ckt/Branches/rm3_ckt_DD_gen_v2.slx');
t_end=toc(t_start);
out_ckt.Elapsed_time=t_end;

%%%Save output as a mat file
cd Results/
if wave.type=="regular"
    filename_ckt = sprintf('out_ckt_T_%d',wave.T);
else
    filename_ckt = sprintf('out_ckt_ir_T_%d',wave.T);
end
save(filename_ckt,"out_ckt","hydro")
cd ../