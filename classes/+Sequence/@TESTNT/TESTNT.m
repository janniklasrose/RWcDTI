classdef TESTNT < Sequence.BaseSequence
    %TESTNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scanner;
        nT;
        DELTA;
        delta;
        G_peak;
    end
    
    methods
        function [this] = TESTNT(bfactor, scanner, nT)
            %TESTNT Testing N_T
            
            if nargin() == 0
                return;
            end
            
            % set
            this = Sequence.TESTNT(); % instantiate
            this.scanner = scanner;
            this.nT = nT;
            TIME = 0.1; % 0.1 second
            this.dt = diff(linspace(0, TIME, nT+1));
            this.gG = zeros(1, nT);
            this.bfactor = bfactor;
            this.DELTA = 0.1;
            this.delta = 0;
            this.G_peak = 0;
            
        end
        function [new] = copy(old)
            new = Sequence.TESTNT(old.bfactor, old.scanner, old.nT);
        end
    end
    
end
