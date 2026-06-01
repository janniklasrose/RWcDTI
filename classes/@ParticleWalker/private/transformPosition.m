function [position_LOCAL, position_rotated, ROT_reverse] = transformPosition(substrate, position)

%%% 1) find y-slice that we are in
y_slice_minmax = substrate.y_slice_minmax;
i_slice = find(position(2) >= y_slice_minmax(1, :) & position(2) < y_slice_minmax(2, :), 1); % first find
if isempty(i_slice)
    error('exec:leftdomain', 'where am i?');
end
% i_slice now holds index of slice we are in -> use to get transform angle
% --> TRANSFORM GLOBAL->LOCAL
y_slice = y_slice_minmax(1, i_slice);
if abs(y_slice) < substrate.dy/2 % i.e. slice [0, dy], NOT [-dy, 0] (because we check the first coordinate, i.e. 0)
    A = 0; % explicit zero to avoid problems with rounding error ???
else
    A = deg2rad(substrate.deg_rot_per_m_in_y)*y_slice; % if deg_rot_per_m_in_y is set to 0, no rotation is done
end
ROT_y = @(angle) [cos(angle), 0, sin(angle); 0, 1, 0; -sin(angle), 0, cos(angle)]; % identity matrix if A=0
position_rotated = (ROT_y(-A)*position.').'; % rotate negative angle
ROT_reverse = ROT_y(A); % rotate positive angle
position_SLICE = mod(position_rotated, [0, substrate.dy, 0]); % clip to plane

%%% 2) transform
xCoord = position_SLICE(1); % [-inf, +inf]
yCoord = position_SLICE(2);
zCoord = position_SLICE(3)-substrate.sinfunction(xCoord);
iZ = 1+floor(zCoord/substrate.dz);
ddzz = (iZ-1)*substrate.dz;
ddxx = (mod(iZ, 2))*substrate.dx/2;
position_LOCAL = [xCoord, yCoord, zCoord] - [ddxx, 0, ddzz];
position_LOCAL = mod(position_LOCAL, [substrate.dx, 0, 0]);
end

