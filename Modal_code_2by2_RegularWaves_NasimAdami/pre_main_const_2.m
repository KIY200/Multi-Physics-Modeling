function [F_ex,C_r,C_r_temp,F_ex12] = pre_main_const_2(Trans,Tc,H,T_wave,phi,rampFunction,b1_Ex_re,b2_Ex_re,b1_Ex_im,b2_Ex_im,b1_C_rad,b2_C_rad,time,c_pto)
 F_ex = zeros([7 1]);

Ex_re = [Trans*b1_Ex_re;Trans*b2_Ex_re]; % real part of ex coeff 12by1
Ex_im = [Trans*b1_Ex_im;Trans*b2_Ex_im]; % imag part of ex coeff 12by1
Ex_re_7 = (Tc')*Ex_re; % real part of ex coeff 7by1
Ex_im_7 = (Tc')*Ex_im; % real part of ex coeff 7by1

    F_ex =  real(0.5*(H*exp(i*(2*pi./T_wave*time'+phi)).*complex(Ex_re_7,Ex_im_7))).*rampFunction';% calculating 7by1 F_ex

    F_ex12 =  real(0.5*(H*exp(i*(2*pi./T_wave*time'+phi)).*complex(Ex_re,Ex_im))).*rampFunction'; % calculating 12by1 F_ex 



    C_r_temp =[(squeeze(b1_C_rad(1,1:6,:))) zeros([6 6]); zeros([6 6]) (squeeze(b2_C_rad(1,7:12,:)))]; % 12 * 12 rad damping coeff matrix for single frequancy wave



      C_r = Tc'*C_r_temp*Tc; % 7*7 rad damping coeff matrix for a single frequency wave
   
      C_r(7,7)=C_r(7,7)+c_pto; % pto damping could be added here

end