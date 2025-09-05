function hydro = h5tostruct(filename)
        % Case: Input is a cell array with at least two filenames
        h5BodyName = '/body1';

        % Simulation parameters for the first file
        hydro.T = h5read(filename, '/simulation_parameters/T');
        hydro.w = h5read(filename, '/simulation_parameters/w');

        % Float data from the first file
        hydro.float.A_m =  reverseDimensionOrder(h5read(filename, [h5BodyName '/hydro_coeffs/added_mass/all']));
        hydro.float.R_damp = reverseDimensionOrder(h5read(filename, [h5BodyName '/hydro_coeffs/radiation_damping/all']));
        hydro.float.K_hs = reverseDimensionOrder(h5read(filename, [h5BodyName '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.float.M = 1000* h5read(filename,[h5BodyName '/properties/disp_vol']);
       
end
