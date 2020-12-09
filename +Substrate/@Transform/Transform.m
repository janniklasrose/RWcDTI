classdef Transform

    properties
        isIdentity = true
        dxdydz_bb(1, 3)
        deg_rot_per_L_in_y = 0
        y_slice_minmax
        z_amplitude = 0.1
        x_frequency = 2
    end

    methods
        [position_LOCAL, position_rotated, fn_RotReverse] = global2local(obj, position)
        [xyz] = local2global(obj, xyz, iX, iY, iZ)
    end

end
