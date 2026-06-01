classdef CMR_RBH < Scanner.BaseScanner
    %CMR_RBH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        slewRate = 60.0; % [T/(m*s)] per axis
        gradientStrength = 40.5e-3; % [T/m] per axis ??? NOMINAL: 40.5e-3 ???
    end
    
    methods
    end
    
end
