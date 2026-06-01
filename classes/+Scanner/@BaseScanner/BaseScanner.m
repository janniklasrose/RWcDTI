classdef(Abstract) BaseScanner < BaseClass
    %SCANNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Abstract, Constant)
        slewRate; % [T/(m*s)]
        gradientStrength; % [T/m]
    end
    
    methods(Abstract)
    end
    
end
