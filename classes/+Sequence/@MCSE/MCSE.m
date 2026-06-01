classdef MCSE < Sequence.BaseSequence
    %MCSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scanner;
        nT;
        DELTA;
        delta;
        G_peak;
    end
    
    methods
        function [this] = MCSE(bfactor, scanner, nT)
            %MCSE Motion-Compensated Spin Echo sequence
            
            if nargin() == 0
                return;
            end
            
            % NOTE on gradient strength:
            % * the gradients can be applied along two directions simultaneously
            % * here we assume that we use two at the same time and the directions are not normalized (i.e. [1, 1, 0])
            G_peak   = Scanner.(scanner).gradientStrength;
            G_peak = 39.477813e-3; % FOR PAPER
            slewrate = Scanner.(scanner).slewRate;
            
            % set
            this = Sequence.MCSE(); % instantiate
            this.scanner = scanner;
            this.nT = nT;
            this.makeMCSE(bfactor, G_peak, slewrate); % dt, gG, bfactor
            this.G_peak = G_peak;
            
        end
        function [new] = copy(old)
            new = Sequence.MCSE(old.bfactor, old.scanner, old.nT);
        end
    end
    
    methods(Access=private)
        [] = makeMCSE(this, bfactor, G_peak, slewrate)
    end
    
end
