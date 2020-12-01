classdef Transform

    properties
        dxdydz_bb(1, 3)
        deg_rot_per_m_in_y = 0
        y_slice_minmax
    end

    methods
        [position_LOCAL, position_rotated, fn_RotReverse] = transformPosition(obj, position)
    end

    methods
        function val = sine(obj, x)
            dx = obj.dxdydz_bb(1);
            dz = obj.dxdydz_bb(3);
            amplitude = 0.1*dz;
            val = amplitude*sin(4*pi*x/dx);
        end
        function val = TRANSFORM(obj, xyz, iX, iY, iZ)

            % translation offset
            offset = [iX+mod(iZ, 2)/2, iY, iZ].*obj.dxdydz_bb;

            % LOCAL
            xy = zeros(size(xyz, 1), 2);
            z_sine = obj.sine(xyz(:, 1));
            LOCAL = [xy, z_sine] + xyz;

            % angle
            y = obj.dxdydz_bb(2)*iY;
            angle = deg2rad(obj.deg_rot_per_m_in_y);
            theta = angle*y;

            translated = LOCAL + offset;

            val = obj.rotate_y(translated, theta);

        end
    end

    methods(Static)
        function [pos] = rotate_y(pos, theta)
            % perform a rotation around y using an angle

            % identity matrix if A=0
            rot = [cos(theta),0,sin(theta);
                   0,1,0;
                   -sin(theta),0,cos(theta)];
            pos = (rot*pos.').';

        end
    end

end
