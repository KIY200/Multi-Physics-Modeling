% Debug helper for const_hydro sizing issues.
% Usage:
%   debug_const_hydro('hydro/2WEC_Spacing_4p00m.h5', [1 2])

function debug_const_hydro(filename, bodyPair)
if nargin < 2
    bodyPair = [1 2];
end

body1 = bodyPair(1);
body2 = bodyPair(2);

fprintf('File: %s\n', filename);
fprintf('Body pair: [%d %d]\n', body1, body2);

ex_re_1 = h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/re', body1));
ex_im_1 = h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/im', body1));
ex_re_2 = h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/re', body2));
ex_im_2 = h5read(filename, sprintf('/body%d/hydro_coeffs/excitation/im', body2));

fprintf('Excitation body%d re size: %s\n', body1, mat2str(size(ex_re_1)));
fprintf('Excitation body%d im size: %s\n', body1, mat2str(size(ex_im_1)));
fprintf('Excitation body%d re size: %s\n', body2, mat2str(size(ex_re_2)));
fprintf('Excitation body%d im size: %s\n', body2, mat2str(size(ex_im_2)));

am_1 = h5read(filename, sprintf('/body%d/hydro_coeffs/added_mass/all', body1));
am_2 = h5read(filename, sprintf('/body%d/hydro_coeffs/added_mass/all', body2));
fprintf('Added mass body%d size: %s\n', body1, mat2str(size(am_1)));
fprintf('Added mass body%d size: %s\n', body2, mat2str(size(am_2)));

rd_1 = h5read(filename, sprintf('/body%d/hydro_coeffs/radiation_damping/all', body1));
rd_2 = h5read(filename, sprintf('/body%d/hydro_coeffs/radiation_damping/all', body2));
fprintf('Rad damping body%d size: %s\n', body1, mat2str(size(rd_1)));
fprintf('Rad damping body%d size: %s\n', body2, mat2str(size(rd_2)));

T = h5read(filename, '/simulation_parameters/T');
fprintf('Wave T size: %s\n', mat2str(size(T)));
fprintf('Wave T sample: %g %g %g ...\n', T(1), T(min(2,end)), T(min(3,end)));

% Show expected column indices for this body pair
cols1 = (body1-1)*6 + (1:6);
cols2 = (body2-1)*6 + (1:6);
fprintf('Column indices: body%d -> %s, body%d -> %s\n', body1, mat2str(cols1), body2, mat2str(cols2));
end
