classdef BoundingBox < Geometry.BaseObject
    %BOUNDINGBOX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess=public, SetAccess=private)
        Range(1, :) double {mustBeNonNan, mustBeIncreasingPairs} = zeros(1, 0);
    end
    
    properties(GetAccess=public, Dependent=true)
        DIM;
    end
    methods % Dependent
        function [DIM] = get.DIM(this)
            DIM = numel(this.Range)/2;
        end
    end
    
    methods
        function [this] = BoundingBox(range, varargin)
            % BoundingBox([xmin, xmax, ymin, ymax, zmin, zmax])
            % BoundingBox([xmin; xmax; ymin; ymax; zmin; zmax])
            
            % construct
            if nargin() == 0
                return;
            end
            this = Geometry.BoundingBox();
            
            % set
            this.Range = range(:);
            
        end
    end
    
    methods
        [bool] = overlapsWithBoundingBox(this, that)
        [bool] = containsPoint(this, point)
        [h] = plot(this, varargin)
    end
    
end

function [] = mustBeIncreasingPairs(Range)

if mod(numel(Range), 2) % must be even number
    error('Geometry:BoundingBox:MustBeIncreasingPairs:Pairs', 'Range must have [[min, max], ...] pairs!');
end
if any(Range(1:2:end) > Range(2:2:end)) % only "strictly larger than" is disallowed
    error('Geometry:BoundingBox:MustBeIncreasingPairs:Increasing', 'Range must be increasing pairs (min <= max)!');
end

end
