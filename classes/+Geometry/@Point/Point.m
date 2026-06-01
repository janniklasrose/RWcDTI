classdef Point < Geometry.BaseObject
    %POINT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess=public, SetAccess=public)
        Coordinates(1, :) double {mustBeNonNan, mustRetainDimension} = zeros(1, 0);
    end
    
    properties(GetAccess=public, Dependent=true)
        DIM;
    end
    methods % Dependent
        function [DIM] = get.DIM(this)
            DIM = numel(this.Range);
        end
    end
    
    methods
        function [this] = Point(point, varargin)
            % Point([x, y, z])
            % Point([x; y; z])
            
            % construct
            if nargin() == 0
                return;
            end
            this = Geometry.Point();
            
            % set
            this.Coordinates = point;
            
        end
    end
    
end

function [] = mustRetainDimension(Coordinates)

%TODO: implement that dimension does not change from how it was constructed

end
