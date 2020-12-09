classdef Transform

    properties
        isIdentity = true
        dxdydz_bb(1, 3)
        y_slice_minmax
        deg_rot_per_L_in_y = 0
        z_amplitude = 0
        x_frequency = 1
    end

    methods
        [position_LOCAL, position_rotated, fn_RotReverse] = global2local(obj, position)
        [xyz] = local2global(obj, xyz, iX, iY, iZ)
    end

end
