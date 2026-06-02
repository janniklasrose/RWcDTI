function [pos_global] = local2global(obj, pos_local, iX, iY, iZ)
%LOCAL2GLOBAL Transform a local block position into global coordinates.
%   pos_global = local2global(obj, pos_local, iX, iY, iZ) reverses
%   the block offset, sinusoidal displacement, and y-axis rotation for the
%   block identified by one-based indices iX, iY, and iZ.

% Change block index to be zero-based
[iX, iY, iZ] = deal(iX-1, iY-1, iZ-1);

% translation offset
if obj.shift_block
    shift = mod(iZ+1, 2)/2;
else
    shift = 0;
end
offset = [iX + shift, iY, iZ].*obj.dxdydz_bb;

% Compute position in the rotated plane
position_rotated = pos_local + offset;
position_rotated(3) = position_rotated(3) + sine(obj, position_rotated(1));

% Invert rotation
y = obj.dxdydz_bb(2)*iY;
angle = deg2rad(obj.deg_rot_per_L_in_y);
theta = angle*y;

pos_global = rotate_y(position_rotated, theta);

end
