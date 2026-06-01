classdef Transform

    properties
        isIdentity = true
        dxdydz_bb(1, 3)
        y_slice_minmax
        deg_rot_per_L_in_y = 0
        z_amplitude = 0
        x_frequency = 1
        shift_block = true
    end

    methods
        [position_LOCAL, fn_TransformInverse, fn_Rot, fn_RotReverse] = global2local(obj, position)
        [xyz] = local2global(obj, xyz, iX, iY, iZ)
    end

end
