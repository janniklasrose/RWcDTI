classdef(Abstract) BaseObject < BaseClass
    %BASEOBJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Abstract)
        [h] = plot(this, varargin);
    end
    
end
