classdef BoundingBox < handle

    properties(GetAccess=public, SetAccess=private)
        Range(1, 6) double {mustBeIncreasingPairs}
    end

    methods % Constructor
        function [obj] = BoundingBox(range)
            % BoundingBox([xmin, xmax, ymin, ymax, zmin, zmax])
            % BoundingBox([xmin; xmax; ymin; ymax; zmin; zmax])
            % BoundingBox([xmin, ymin, zmin; xmax, ymax, zmax])

            % no argument specified, i.e. empty object
            if nargin() == 0
                return
            end

            % store the range
            obj.Range = range(:);

        end
    end

    methods % Other
        [bool] = containsPoint(obj, point)
    end

    properties(GetAccess=private, Dependent)
        DxDyDz
    end
    methods
        function [dxdydz] = get.DxDyDz(obj)
            dxdydz = obj.Range(2:2:end) - obj.Range(1:2:end);
        end
    end

    properties(Dependent)
        Volume
        SurfaceArea
    end
    methods
        function [volume] = get.Volume(obj)
            volume = prod(obj.DxDyDz);
        end
        function [area] = get.SurfaceArea(obj)
            idx = [1,2; 1,3; 2,3]; % xy, xz, yz
            area = 2*sum(prod(obj.DxDyDz(idx), 2));
        end
    end

end

function [] = mustBeIncreasingPairs(Range)
% Validates that the input range is increasing pairs

if any(Range(1:2:end) > Range(2:2:end)) % only disallow "strictly larger than"
    error('Range must be increasing pairs (min <= max)!');
end

end
