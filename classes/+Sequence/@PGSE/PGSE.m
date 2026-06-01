classdef PGSE < Sequence.BaseSequence
    %PGSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scanner;
        nT;
        DELTA;
        delta;
        G_peak;
    end
    
    methods
        function [this] = PGSE(bfactor, scanner, nT)
            %PGSE Pulsed Gradient Spin Echo sequence
            
            if nargin() == 0
                return;
            end
            
            % NOTE on gradient strength:
            % * the gradients can be applied along two directions simultaneously
            % * here we assume that we use two at the same time and the directions are not normalized (i.e. [1, 1, 0])
            G_peak   = Scanner.(scanner).gradientStrength;
            G_peak = 40.571567e-3; % FOR PAPER
            slewrate = Scanner.(scanner).slewRate;
            
            % set
            this = Sequence.PGSE(); % instantiate
            this.scanner = scanner;
            this.nT = nT;
            this.makePGSE(bfactor, G_peak, slewrate); % dt, gG, bfactor
            this.G_peak = G_peak;
            
        end
        function [new] = copy(old)
            new = Sequence.PGSE(old.bfactor, old.scanner, old.nT);
        end
    end
    
    methods(Access=private)
        [] = makePGSE(this, bfactor, G_peak, slewrate)
    end
    
end
