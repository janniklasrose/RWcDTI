classdef Polygon < Geometry.BaseObject
    %POLYGON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess=private, GetAccess=public)
        Vertices(:, 2) double {mustBeFinite} = zeros(0, 2);
        BoundingBox(1, 1) Geometry.BoundingBox = Geometry.BoundingBox();
    end
    
    properties
        Color(1, 3) {mustBeFinite, mustBeNonnegative} = [0, 0, 0];
    end
    
    properties(Dependent=true)
        VerticesT;
        nVertices;
        Area;
    end
    methods
        function [VerticesT] = get.VerticesT(this)
            VerticesT = this.Vertices.';
        end
        function [nVertices] = get.nVertices(this)
            nVertices = size(this.Vertices, 1);
        end
        function [Area] = get.Area(this)
            Area = polyarea(this.Vertices(:, 1), this.Vertices(:, 2));
            % NOTE: this requires the vertices to be ordered
            % we could simply do the following if we were looking for speed (no overhead)
            %{
            area = abs( sum(  (this.vertices([2:end, 1], 1) - this.vertices(:, 1)) ...
                            .*(this.vertices([2:end, 1], 2) + this.vertices(:, 2)) )/2);
            %}
        end
    end
    
    methods
        function [this] = Polygon(varargin)
            % [this] = Polygon(vertices)
            % [this] = Polygon('square', [xmin,xmax,ymin,ymax])
            switch nargin()
                case 0
                    return;
                case 1
                    Vertices = varargin{1};
                case 2
                    rangespec = varargin{2};
                    Vertices = [[0;0],[1;0],[1;1],[0;1]];
                    Vertices = Vertices - 0.5; % centre around 0 with range [-0.5,+0.5]
                    origin = (rangespec(2:2:end)+rangespec(1:2:end)).'/2;
                    range  = (rangespec(2:2:end)-rangespec(1:2:end)).'; % size: [2,1]
                    Vertices = Vertices.*range + origin;
                    Vertices = Vertices.';
                otherwise
                    error('Geometry:Polygon:varargin', 'usage');
            end
            this          = Geometry.Polygon();
            this.Vertices = Vertices;
            
            minXY = min(this.Vertices, [], 1); 
            maxXY = max(this.Vertices, [], 1);
            bb_tol = 1e-8;
            this.BoundingBox = Geometry.BoundingBox([minXY(1), maxXY(1), minXY(2), maxXY(2)], bb_tol);
            
        end
    end
    
    methods
        [] = reduce(this, n);
        [inside] = containsPoint(this, point);
        [h] = plot(this, varargin)
        [bool] = overlapsWithPolygon(this, that);
    end
    
    methods(Static=true, Access=public)
        function [] = MAKE(varargin)
            
            if nargin() == 0 % default
                varargin = {'gpcmex_int'}; % all
            end
            
            folder = mfilename('fullpath');
            [folder,~,~] = fileparts(folder);
            source_path = fullfile(folder, 'private', 'src');
            object_path = fullfile(folder, 'private');
            
            for iArg = 1:numel(varargin)
                arg = varargin{iArg};
                switch arg
                    case 'gpcmex_int'
                        source_files = {fullfile(source_path, 'gpcmex_int.c'), fullfile(source_path, 'gpc.c')};
                        binary_name = 'gpcmex_int';
                        try
                            mex('-outdir', object_path, '-output', binary_name, source_files{:});
                        catch E
                            warning('Polygon:MAKE:CompileError', 'The following compile error occured:\n%s\n', E.getReport);
                        end
                    otherwise
                        error('Polygon:MAKE:UnknownTarget', 'Unknown target ''%s''', arg);
                end
            end
            
        end
    end
    
end
