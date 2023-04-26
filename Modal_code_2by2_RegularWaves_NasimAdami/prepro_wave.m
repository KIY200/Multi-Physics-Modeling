function [time, eta,rampFunction] = prepro_wave(T,H,phi,duration,dt,rampTime)
% A function that is called once to generate the elevation time series of 
% the free surface with the given wave components. The number of wave 
% components are not limited and can be an output from a simple FFT
%  analysis of any measured time series. Details of input and outputs can 
% be found in the function.
%
% inputs:
% T : wave periods (vector)
% H : wave heights (vector)
% phi : initial wave phases (vector) 
% duration : simulation duration
% dt : time step
%
% output:
% time : timeseries (0, dt, 2dt, 3dt, ..., duration)
% eta :  free surface elevation timeseries
% rampFunction : a cos function to gradually ramp up the wave field

eta = zeros(duration/dt+1,1);
time = (0:dt:duration)';

for ii=1:length(T)
    eta = eta + H(ii)*0.5*exp(i*(2*pi./T(ii)*time+phi(ii)));
end


rampFunction = (1+cos(pi+pi*time/rampTime))/2;
rampFunction(time>rampTime) = 1;

eta = eta.*rampFunction;
figure

plot(time, real(eta))
xlabel('Time (s)')
ylabel('\eta (m)')

end
