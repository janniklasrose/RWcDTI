function [xyz] = local2global(obj, xyz, iX, iY, iZ)
% transform a position inside block with indices iX, iY, iZ

% translation offset
offset = [iX+mod(iZ, 2)/2, iY, iZ].*obj.dxdydz_bb;

% LOCAL
xy = zeros(size(xyz, 1), 2);
z_sine = sine(xyz(:, 1));
LOCAL = [xy, z_sine] + xyz;

% angle
y = obj.dxdydz_bb(2)*iY;
angle = deg2rad(obj.deg_rot_per_L_in_y);
theta = angle*y;

translated = LOCAL + offset;

xyz = rotate_y(translated, theta);

end
