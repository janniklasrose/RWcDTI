classdef Myocyte < Geometry.Polyhedron
    
    methods(Access=public)
        function [this] = Myocyte(varargin)
            this = this@Geometry.Polyhedron(varargin{:}); % call superclass constructor
        end
    end
    
    %TODO: implement Myocyte-specific properties and methods
    
end
