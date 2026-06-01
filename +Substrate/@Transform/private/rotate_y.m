function [pos] = rotate_y(pos, theta)
% perform a rotation around y using an angle

% identity matrix if A=0
rot = [cos(theta),0,sin(theta);
       0,1,0;
       -sin(theta),0,cos(theta)];
pos = (rot*pos.').';

end
