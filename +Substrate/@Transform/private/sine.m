function val = sine(obj, x)
% apply a sinusoidal displacement

dx = obj.dxdydz_bb(1);
dz = obj.dxdydz_bb(3);
amplitude = obj.z_amplitude*dz;
val = amplitude*sin(obj.x_frequency * 2*pi*x/dx);

end
