function [pos] = rotate_y(pos, theta)
%ROTATE_Y Rotate positions around the y-axis by theta radians.

% identity matrix if A=0
rot = [cos(theta),0,sin(theta);
       0,1,0;
       -sin(theta),0,cos(theta)];
pos = (rot*pos.').';

end
