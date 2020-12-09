classdef Polyhedron < handle

    properties(SetAccess=private, GetAccess=public)
        Vertices(:, 3) double {mustBeReal, mustBeFinite};
        Faces(:, 3) uint16 {mustBeInteger, mustBeFinite, mustBePositive};
        %           ^ uint8 too small (nF_max=255)
        BoundingBox(1, 1) Geometry.BoundingBox;
    end

    properties(Dependent=true)
        nVertices;
        VerticesT;
        nFaces;
        FacesT;
    end
    methods
        function [VerticesT] = get.VerticesT(obj)
            VerticesT = obj.Vertices.';
        end
        function [FacesT] = get.FacesT(obj)
            FacesT = obj.Faces.';
        end
        function [nVertices] = get.nVertices(obj)
            nVertices = size(obj.Vertices, 1);
        end
        function [nFaces] = get.nFaces(obj)
            nFaces = size(obj.Faces, 1);
        end
    end

    properties(Dependent)
        Volume
        SurfaceArea
    end
    methods
        function [volume] = get.Volume(obj)
            % See: https://stackoverflow.com/q/1838401
            % Shift origin to the mesh "centroid" to create better-quality tetrahedrons
            vertices = obj.Vertices - mean(obj.Vertices, 1);
            % compute volume of each tetrahedron
            volumes = zeros(obj.nFaces, 1);
            for iFace = 1:obj.nFaces
                % formed by vertices and "centroid"
                tetra = vertices(obj.Faces(iFace, :), :);
                % volume of tetrahedron
                volumes(iFace) = det(tetra) / 6;
            end
            volume = abs(sum(volumes)); % absolute value to allow both cw and ccw
        end
        function [area] = get.SurfaceArea(obj)
            % See: https://en.wikipedia.org/wiki/Triangle#Using_coordinates
            areas = zeros(obj.nFaces, 1);
            for iFace = 1:obj.nFaces
                xyz = obj.Vertices(obj.Faces(iFace, :), :);
                x = xyz(:, 1).';
                y = xyz(:, 2).';
                z = xyz(:, 3).';
                ons = [1, 1, 1];
                areas(iFace) = 0.5*sqrt(det([x; y; ons])^2 + det([y; z; ons])^2 + det([z; x; ons])^2);
            end
            area = sum(areas);
        end
    end

    methods
        function [obj] = Polyhedron(varargin)
            % Polyhedron(vertices, faces)
            % Polyhedron('cuboid', [xmin, xmax, ymin, ymax, zmin, zmax])

            % no argument specified, i.e. empty object
            if nargin() == 0
                return
            end

            % handle different arguments
            if strcmp(varargin{1}, 'cuboid')
                rangespec = varargin{2}(1:6);
                rangespec = rangespec(:)'; % make row!
                faces = [1,3,4; 1,4,2; 5,6,8; 5,8,7; 2,4,8; 2,8,6;
                         1,5,7; 1,7,3; 1,2,6; 1,6,5; 3,7,8; 3,8,4];
                vertices = [0,0,0;1,0,0;0,1,0;1,1,0;0,0,1;1,0,1;0,1,1;1,1,1];
                vertices = vertices - 0.5; % centre around 0 with [-0.5, +0.5]
                origin = (rangespec(2:2:end) + rangespec(1:2:end))/2;
                range = rangespec(2:2:end) - rangespec(1:2:end); % size [1, 3]
                vertices = vertices.*range + origin;
            else
                vertices = varargin{1};
                faces = varargin{2};
            end
            obj.Vertices = vertices;
            obj.Faces = faces;

            % compute bounding box
            minXYZ = min(obj.Vertices, [], 1); 
            maxXYZ = max(obj.Vertices, [], 1);
            bbX = [minXYZ(1), maxXYZ(1)];
            bbY = [minXYZ(2), maxXYZ(2)];
            bbZ = [minXYZ(3), maxXYZ(3)];
            obj.BoundingBox = Geometry.BoundingBox([bbX, bbY, bbZ]);

        end
    end
    
    properties(Dependent)
        Bytes
    end
    methods
        function [bytes] = get.Bytes(obj)
            bytes = obj.sizeof();
        end
        function [sizeof] = sizeof(obj)
            sizeof = 0;
            for name = {'Vertices', 'Faces'}
                property = obj.(name{:}); %#ok<NASGU> % ignore warning, used in `whos`
                whos_out = whos('property');
                sizeof = sizeof + whos_out.bytes;
            end
        end
    end

    methods
        [bool] = containsPoint(obj, point);
        [intersectInfo] = intersection(obj, orig, dir);
    end

end
