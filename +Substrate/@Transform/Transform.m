classdef Transform
    % Transform maps positions between global substrate and local block frames.
    %
    % For full substrates the transform is the identity. For block substrates
    % it applies slice-wise y-axis rotations, optional sinusoidal displacement
    % in z, and optional staggered block shifts.

    properties
        isIdentity(1, 1) logical = true
        dxdydz_bb(1, 3) double {mustBeReal, mustBeFinite, mustBePositive} = [1, 1, 1]
        y_slice_minmax(2, :) double {mustBeReal, mustBeFinite, mustBeIncreasingRows}
        deg_rot_per_L_in_y(1, 1) double {mustBeReal, mustBeFinite} = 0
        z_amplitude(1, 1) double {mustBeReal, mustBeFinite} = 0
        x_frequency(1, 1) double {mustBeReal, mustBeFinite, mustBeNonnegative} = 1
        shift_block(1, 1) logical = true
    end

    methods
        [position_LOCAL, fn_TransformInverse, fn_Rot, fn_RotReverse] = global2local(obj, position)
        [xyz] = local2global(obj, xyz, iX, iY, iZ)
    end

end

function [] = mustBeIncreasingRows(value)
% Validate columns containing [min; max] row pairs.

if isempty(value)
    return
end

if any(value(1, :) > value(2, :))
    error('Transform:y_slice_minmax:invalid', ...
          'Each y_slice_minmax column must satisfy min <= max');
end

end
