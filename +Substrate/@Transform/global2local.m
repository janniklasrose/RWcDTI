function [position_LOCAL, position_rotated, fn_RotReverse] = global2local(obj, position)
% transform position from global to local

% handle identity case first
if obj.isIdentity
    % skip transform
    [position_LOCAL, position_rotated] = deal(position);
    fn_RotReverse = @(pos) pos;
    return
end

deg_rot_per_L_in_y = obj.deg_rot_per_L_in_y;
y_slice_minmax = obj.y_slice_minmax;
dx = obj.dxdydz_bb(1);
dy = obj.dxdydz_bb(2);
dz = obj.dxdydz_bb(3);

% find y-slice that we are in -> use to get transform angle
y_slice = find_yslice(position(2), y_slice_minmax);

% get rotation angle A based on slice/block we are in
if abs(y_slice) < dy/2 % i.e. slice [0, dy], NOT [-dy, 0] (because we check the first coordinate, i.e. 0)
    A = 0; % explicit zero to avoid problems with rounding error
else
    % if deg_rot_per_m_in_y is set to 0, no rotation is done
    A = deg2rad(deg_rot_per_L_in_y)*y_slice;
end

% --> TRANSFORM GLOBAL->LOCAL
position_rotated = rotate_y(position, -A); % rotate negative angle
fn_RotReverse = @(pos) rotate_y(pos, A); % rotate positive angle
position_SLICE = mod(position_rotated, [0, dy, 0]); % clip to plane

%%% 2) transform
xCoord = position_SLICE(1); % [-inf, +inf]
yCoord = position_SLICE(2);
zCoord = position_SLICE(3) - sine(obj, xCoord);
iZ = 1+floor(zCoord/dz);
ddzz = (iZ-1)*dz;
ddxx = (mod(iZ, 2))*dx/2;
position_LOCAL = [xCoord, yCoord, zCoord] - [ddxx, 0, ddzz];
position_LOCAL = mod(position_LOCAL, [dx, 0, 0]);

end

function [y_slice] = find_yslice(pos_y, y_slice_minmax)
% find yslice

i_slice = find(pos_y >= y_slice_minmax(1, :) & pos_y < y_slice_minmax(2, :), 1); % first find
if isempty(i_slice)
    error('Transform:global2local:where', 'Corresponding slice not found');
end
% i_slice now holds index of slice we are in
y_slice = y_slice_minmax(1, i_slice);

end
