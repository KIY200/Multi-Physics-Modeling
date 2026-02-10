function hydro = convh5(filename)
rho = 1000;
g = 9.81;

w = h5read(filename, '/simulation_parameters/w');
Add_mass =  h5read(filename, '/body1/hydro_coeffs/added_mass/all');
Rad_damping = h5read(filename, '/body1/hydro_coeffs/radiation_damping/all');
static_stiffness = rho*g*h5read(filename, '/body1/hydro_coeffs/linear_restoring_stiffness');
Fex_re = h5read(filename, '/body1/hydro_coeffs/excitation/re');
Fex_im = h5read(filename, '/body1/hydro_coeffs/excitation/im');

Add_mass =  h5read(filename, '/body3/hydro_coeffs/added_mass/all');
Rad_damping = h5read(filename, '/body3/hydro_coeffs/radiation_damping/all');
static_stiffness = rho*g*h5read(filename, '/body3/hydro_coeffs/linear_restoring_stiffness');
Fex_re = h5read(filename, '/body3/hydro_coeffs/excitation/re');
Fex_im = h5read(filename, '/body3/hydro_coeffs/excitation/im');

%denomalization and structurizing
hydro.w=w';

hydro.float_up.Add_mass = rho*squeeze(Add_mass);
hydro.float_up.Rad_damping = rho*hydro.w.*squeeze(Rad_damping);
hydro.float_up.static_stiffness=static_stiffness;
hydro.float_up.Fex_re = rho*g*Fex_re;
hydro.float_up.Fex_im = rho*g*Fex_im;

hydro.float_dn.Add_mass = rho*squeeze(Add_mass);
hydro.float_dn.Rad_damping = rho*hydro.w.*squeeze(Rad_damping);
hydro.float_dn.static_stiffness=static_stiffness;
hydro.float_dn.Fex_re = rho*g*Fex_re;
hydro.float_dn.Fex_im = rho*g*Fex_im;

end