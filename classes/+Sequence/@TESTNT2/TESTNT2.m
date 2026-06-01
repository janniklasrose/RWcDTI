classdef TESTNT2 < Sequence.BaseSequence
    %TESTNT2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scanner;
        nT;
        DELTA;
        delta;
        G_peak;
    end
    
    methods
        function [this] = TESTNT2(bfactor, scanner, nT)
            %TESTNT2 Testing N_T
            
            if nargin() == 0
                return;
            end
            
            % set
            this = Sequence.TESTNT2(); % instantiate
            this.scanner = scanner;
            this.nT = nT;
            TIME = 1.0; % 1.0 second
            this.dt = diff(linspace(0, TIME, nT+1));
            this.gG = zeros(1, nT);
            this.bfactor = bfactor;
            this.DELTA = 1.0;
            this.delta = 0;
            this.G_peak = 0;
            
        end
        function [new] = copy(old)
            new = Sequence.TESTNT2(old.bfactor, old.scanner, old.nT);
        end
    end
    
end
