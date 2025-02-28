function [float_mass, ...
    float_added_mass,...
    float_damping, ...
    float_stiffness, ...
    spar_mass, ...
    spar_added_mass,...
    spar_damping, ...
    spar_stiffness] = fn_get_lupa_params(w,lupadata)

[~,ix_w] = min((lupadata.w-w).^2); 

float_mass = lupadata.float.mass;
float_added_mass = lupadata.float.addedmass(ix_w);
float_damping = lupadata.float.damping(ix_w);
float_stiffness = lupadata.float.stiffness;

spar_mass = lupadata.spar.mass;
spar_added_mass = lupadata.spar.addedmass(ix_w);
spar_damping = lupadata.spar.damping(ix_w);
spar_stiffness = lupadata.spar.stiffness;