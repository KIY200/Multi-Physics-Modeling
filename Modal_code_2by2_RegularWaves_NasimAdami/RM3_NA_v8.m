function [dx] = RM3_NA_v8(F_ex2,M2,K2,C_r2,x_old,v_old)
%The main computation function that provides the rates of change in x and v at each time step 
%
% inputs:
% F_ex2 : 2 by 1 Excitation force coeff in Eigen domain
% M2 : 2 by 2 total  mass matrix in Eigen domain
% K2 : 2 by 2 hydrostatic restoring (stiffness) matrix in Eigen domain
% C_r2 : 2 by 2 radiation damping coeff matrix in Eigen domain 
% x_old : 2 by 1 displacements from the previous time step in Eigen domian
% v_old : 2 by 1 velocities from the previous time step in Eigen domian
%
% outputs:
% dx : 4 by 1 matrix of rates of change, first 2 components for displacement and the rest for velocities


% A_4 is the left hand side coefficients for state space (dx , dv) 
A_4 = [diag(ones([2 1])) zeros([2 2]);zeros([2 2]) M2];

% B_4 is the right hand side terms from the previous time step (dx ,f)

B_4 = [v_old;F_ex2-K2*x_old-C_r2*v_old]; 

dx = A_4\B_4;

end