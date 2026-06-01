classdef Polyhedron < Geometry.BaseObject
    %POLYHEDRON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess=private, GetAccess=public)
        Vertices(:, 3) double {mustBeReal, mustBeFinite} = zeros(0, 3);
        Faces(:, 3) uint16 {mustBeInteger, mustBeFinite, mustBePositive} = zeros(0, 3); % uint8 too small (nF_max=255)
        BoundingBox(1, 1) Geometry.BoundingBox = Geometry.BoundingBox();
        VolumeAreaRatio_chached;
    end
    
    properties
        Color(1, 3) {mustBeFinite, mustBeNonnegative} = [0, 0, 0];
        Length(1, 1) {mustBeFinite};
        Index(1, 1);
    end
    
    properties(Dependent=true)
        nVertices;
        VerticesT;
        nFaces;
        FacesT;
        SurfaceArea;
        Volume;
    end
    methods
        function [VerticesT] = get.VerticesT(this)
            VerticesT = this.Vertices.';
        end
        function [FacesT] = get.FacesT(this)
            FacesT = this.Faces.';
        end
        function [nVertices] = get.nVertices(this)
            nVertices = size(this.Vertices, 1);
        end
        function [nFaces] = get.nFaces(this)
            nFaces = size(this.Faces, 1);
        end
        function [SurfaceArea] = get.SurfaceArea(this)
            % See: https://en.wikipedia.org/wiki/Triangle#Using_coordinates
            
            areas = zeros(this.nFaces, 1);
            for iFace = 1:this.nFaces
                xyz = this.Vertices(this.Faces(iFace, :), :);
                x = xyz(:, 1).';
                y = xyz(:, 2).';
                z = xyz(:, 3).';
                ons = [1, 1, 1];
                areas(iFace) = 0.5*sqrt(det([x; y; ons])^2 + det([y; z; ons])^2 + det([z; x; ons])^2);
            end
            SurfaceArea = sum(areas);
        end
        function [Volume] = get.Volume(this)
            % See: http://stackoverflow.com/questions/1838401/general-formula-to-calculate-polyhedron-volume
            
            % Shift origin to the mesh "centroid" to create better-quality tetrahedrons
            vertices = this.Vertices - mean(this.Vertices, 1);
            % compute volume of each tetrahedron
            volumes = zeros(this.nFaces, 1);
            for iFace = 1:this.nFaces
                % formed by vertices and "centroid"
                tetra = vertices(this.Faces(iFace, :), :);
                % volume of tetrahedron
                volumes(iFace) = det(tetra) / 6;
            end
            Volume = abs(sum(volumes)); % absolute value to allow both cw and ccw
        end
    end
    
    methods
        function [this] = Polyhedron(varargin)
            % [this] = Geometry.Polyhedron(vertices, faces)
            % [this] = Geometry.Polyhedron('cube', [xmin,xmax,ymin,ymax,zmin,zmax])
            
            this = this@Geometry.BaseObject();
            if nargin() == 0
                return;
            end
            
            if isequal(varargin{1}, 'cuboid') && isequal(size(varargin{2}), [1,6])
                rangespec = varargin{2};
                faces = [1,3,4;1,4,2;5,6,8;5,8,7;2,4,8;2,8,6;1,5,7;1,7,3;1,2,6;1,6,5;3,7,8;3,8,4];
                vertices = [0,0,0;1,0,0;0,1,0;1,1,0;0,0,1;1,0,1;0,1,1;1,1,1];
                vertices = vertices - 0.5; % centre around 0 with range [-0.5,+0.5]
                origin = (rangespec(2:2:end)+rangespec(1:2:end))/2;
                range  = rangespec(2:2:end)-rangespec(1:2:end); % size: [1,3]
                vertices = vertices.*range + origin;
            else
                vertices = varargin{1};
                faces = varargin{2};
            end
            this.Vertices = vertices;
            this.Faces    = faces;
            
            minXYZ = min(this.Vertices, [], 1); 
            maxXYZ = max(this.Vertices, [], 1);
            bbX = [minXYZ(1), maxXYZ(1)];
            bbY = [minXYZ(2), maxXYZ(2)];
            bbZ = [minXYZ(3), maxXYZ(3)];
            this.BoundingBox = Geometry.BoundingBox([bbX, bbY, bbZ]);
            this.VolumeAreaRatio_chached = this.Volume / this.SurfaceArea;
        end
        function [sizeof] = sizeof(this)
            sizeof = 0;
            for name = {'Vertices', 'Faces'}
                property = this.(name{:});
                whos_out = whos('property');
                sizeof = sizeof + whos_out.bytes;
            end
        end
        [h] = plot(this, varargin)
    end
    
    methods
        [bool] = containsPoint(this, point);
        [intersectInfo] = intersection(this, orig, dir);
    end
    
    methods(Static=true, Access=public)
        function [] = MAKE(varargin)
            
            if nargin() == 0 % default
                varargin = {'crossMex'}; % all
            end
            
            folder = mfilename('fullpath');
            [folder,~,~] = fileparts(folder);
            source_path = fullfile(folder, 'private', 'src');
            object_path = fullfile(folder, 'private');
            
            for iArg = 1:numel(varargin)
                arg = varargin{iArg};
                switch arg
                    case 'crossMex'
                        source_files = {fullfile(source_path, 'crossMex.c')};
                        binary_name = 'crossMex';
                        try
                            mex('-outdir', object_path, '-output', binary_name, source_files{:});
                        catch E
                            warning('Polyhedron:MAKE:CompileError', 'The following compile error occured:\n%s\n', E.getReport);
                        end
                    otherwise
                        warning('Polyhedron:MAKE:UnknownTarget', 'Unknown target ''%s''', arg);
                end
            end
            
        end
    end
    
end

