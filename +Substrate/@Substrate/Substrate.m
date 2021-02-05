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
        dim = 'xyz'
    end

    properties(Access=private)
        type
        transform
    end

    methods
        function obj = Substrate(dxdydz, myocytes, type, varargin)

            obj.dxdydz = dxdydz;

            % store myocytes (convert first if necessary)
            if ~isa(myocytes, 'Geometry.Polyhedron')
                myos = repmat(Geometry.Polyhedron, size(myocytes));
                for i = 1:numel(myocytes)
                    myo = myocytes(i); % probably plain-old-struct
                    myos(i) = Geometry.Polyhedron(myo.Vertices, myo.Faces);
                end
                obj.myocytes = myos;
            else
                obj.myocytes = myocytes;
            end

            validatestring(type, {'block', 'full'});
            obj.type = type;
            obj.transform = Substrate.Transform; % identity transform by default
            if strcmp(type, 'block')
                obj.transform.isIdentity = false; % disable identity
                obj.transform.dxdydz_bb = dxdydz;
                % parse the inputs
                p = inputParser;
                addRequired(p, 'y_slice_minmax');
                p.KeepUnmatched = true; % pass other arguments as struct
                parse(p, varargin{:});
                obj.transform.y_slice_minmax = p.Results.y_slice_minmax;
                params = fieldnames(p.Unmatched);
                for i = 1:numel(params)
                    name = params{i};
                    try %#ok<TRYNC> % no need to catch, we will simply try
                        obj.transform.(name) = p.Unmatched.(name);
                    end
                end
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
