function hydro = h5tostruct(filename)
    if iscell(filename) && length(filename) >= 2
        % Case: Input is a cell array with at least two filenames
        h5BodyName = '/body1';

        % Simulation parameters for the first file
        hydro.T = h5read(filename{1}, '/simulation_parameters/T');
        hydro.w = h5read(filename{1}, '/simulation_parameters/w');

        % Float data from the first file
        hydro.float.A_m =  reverseDimensionOrder(h5read(filename{1}, [h5BodyName '/hydro_coeffs/added_mass/all']));
        hydro.float.R_damp = reverseDimensionOrder(h5read(filename{1}, [h5BodyName '/hydro_coeffs/radiation_damping/all']));
        hydro.float.K_hs = reverseDimensionOrder(h5read(filename{1}, [h5BodyName '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.float.M = 1000* h5read(filename{1},[h5BodyName '/properties/disp_vol']);
        % Spar data from the second file
        hydro.spar.A_m =  reverseDimensionOrder(h5read(filename{2}, [h5BodyName '/hydro_coeffs/added_mass/all']));
        hydro.spar.R_damp = reverseDimensionOrder(h5read(filename{2}, [h5BodyName '/hydro_coeffs/radiation_damping/all']));
        hydro.spar.K_hs = reverseDimensionOrder(h5read(filename{2}, [h5BodyName '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.spar.M = 1000* h5read(filename{2},[h5BodyName '/properties/disp_vol']);


        

    elseif ischar(filename) || isstring(filename)
        % Case: Input is a single filename (string or character array)
        h5BodyName1 = '/body1';
        h5BodyName2 = '/body2';
        
        % Simulation parameters for the single file
        hydro.T = h5read(filename, '/simulation_parameters/T');
        hydro.w = h5read(filename, '/simulation_parameters/w');
        
        % Float data from the single file
        hydro.float.A_m = reverseDimensionOrder(h5read(filename, [h5BodyName1 '/hydro_coeffs/added_mass/all']));
        hydro.float.R_damp = reverseDimensionOrder(h5read(filename, [h5BodyName1 '/hydro_coeffs/radiation_damping/all']));
        hydro.float.K_hs = reverseDimensionOrder(h5read(filename, [h5BodyName1 '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.float.M = 1000* h5read(filename,[h5BodyName1 '/properties/disp_vol']);
        % Spar data from the same single file
        hydro.spar.A_m = reverseDimensionOrder(h5read(filename, [h5BodyName2 '/hydro_coeffs/added_mass/all']));
        hydro.spar.R_damp = reverseDimensionOrder(h5read(filename, [h5BodyName2 '/hydro_coeffs/radiation_damping/all']));
        hydro.spar.K_hs = reverseDimensionOrder(h5read(filename, [h5BodyName2 '/hydro_coeffs/linear_restoring_stiffness']));
        hydro.spar.M = 1000* h5read(filename,[h5BodyName2 '/properties/disp_vol']);
    else
        error('Input must be either a string or a cell array of strings with at least two filenames.');
    end
end
