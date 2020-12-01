classdef Substrate < handle

    properties % optional
        voxel Geometry.BoundingBox = Geometry.BoundingBox([-inf, +inf, -inf, +inf, -inf, +inf]) % MRI voxel
    end

    properties(SetAccess=private) % set in the constructor
        dxdydz(1, 3)
        myocytes(1, :) Geometry.Polyhedron
    end

    properties
        transit_model = 'constant'
        kappa = 0
        D_e = 0
        D_i = 0
    end

    properties(Access=private)
        type
        transform
    end

    methods
        function obj = Substrate(dxdydz, myocytes, type, varargin)

            obj.dxdydz = dxdydz;
            obj.myocytes = myocytes;

            obj.type = type;
            validatestring(type, {'block', 'full'});
            switch type
                case 'block'
                    p = inputParser;
                    addRequired(p, 'y_slice_minmax');
                    addParameter(p, 'deg_rot_per_m_in_y', 0);
                    parse(p, varargin{:});

                    obj.transform = Substrate.Transform;
                    obj.transform.dxdydz_bb = dxdydz;
                    obj.transform.y_slice_minmax = p.Results.y_slice_minmax;
                    obj.transform.deg_rot_per_m_in_y = p.Results.deg_rot_per_m_in_y;

                case 'full'
                    error('not implemented yet');
                    %TODO: ensure .transform is an identity transform!!
            end

            obj.buildCache(); % requires .dxdydz and .myocytes to be set

        end
    end

    methods
        [myoIndex] = findMyocyte(obj, position, refFrame)
        [needsChecks] = needsChecking(obj, position, step_xyz, refFrame)
        [varargout] = transformPosition(obj, position)
        [intersectInfo] = intersectMyocytes(obj, position, dxdydz, refFrame)
    end

    properties(SetAccess=private) % cache
        myocyte_bbrange
        block_bb
    end
    methods
        function buildCache(obj)
            % build the cache

            % ranges of myocyte bounding boxes
            tmp_bbs = [obj.myocytes.BoundingBox];
            obj.myocyte_bbrange = [tmp_bbs.Range];

            % bounding box of dxdydz block
            cuboid = [zeros(1, 3); obj.dxdydz(:)']; % flattened gives xx,yy,zz
            obj.block_bb = Geometry.Polyhedron('cuboid', cuboid(:));

        end
    end
end
