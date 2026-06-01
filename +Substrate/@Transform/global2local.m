function [position_LOCAL, fn_TransformInverse, fn_Rot, fn_RotReverse] = global2local(obj, position)
% transform position from global to local

% handle identity case first
if obj.isIdentity
    % skip transform
    A = 0;
    fn_Rot = @(pos) rotate_y(pos, -A);
    fn_RotReverse = fn_Rot;
    position_LOCAL = position;
    fn_TransformInverse = @(pos) pos;
    return
end

deg_rot_per_L_in_y = obj.deg_rot_per_L_in_y;
y_slice_minmax = obj.y_slice_minmax;
dx = obj.dxdydz_bb(1);
dy = obj.dxdydz_bb(2);
dz = obj.dxdydz_bb(3);

% get rotation angle A based on slice/block we are in
y_slice = find_yslice(position(2), y_slice_minmax);
if abs(y_slice) < dy/2 % i.e. slice [0, dy], NOT [-dy, 0] (because we check the first coordinate, i.e. 0)
    A = 0; % explicit zero to avoid problems with rounding error
else
    % if deg_rot_per_m_in_y is set to 0, no rotation is done
    A = deg2rad(deg_rot_per_L_in_y)*y_slice;
end

% Rotate position
fn_Rot = @(pos) rotate_y(pos, -A); % rotate negative angle
fn_RotReverse = @(pos) rotate_y(pos, +A); % rotate positive angle
position_rotated = fn_Rot(position);
position_SLICE = mod(position_rotated, [0, dy, 0]); % clip to plane

% Apply sin(x) displacement in z'
xCoord = position_SLICE(1); % [-inf, +inf]
yCoord = position_SLICE(2);
zCoord = position_SLICE(3) - sine(obj, xCoord);

% Compute iY and iZ
iY = 1+floor(position_rotated(2)/dy);
iZ = 1+floor(zCoord/dz);

% Shift axis half block to the right if iZ is odd and compute iX
if obj.shift_block
    xCoord = xCoord - (mod(iZ, 2))*dx/2;
end
iX = 1+floor(xCoord/dx); % Compute iX like before with iY & iZ

% Compute offset from rotated frame
ddxx = (iX-1)*dx;
ddzz = (iZ-1)*dz;

% Subtract offset from rotated axis and find local position
position_LOCAL = [xCoord, yCoord, zCoord] - [ddxx, 0, ddzz];

% Calculate inverse transform
fn_TransformInverse = @(pos) obj.local2global(pos, iX, iY, iZ);

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
