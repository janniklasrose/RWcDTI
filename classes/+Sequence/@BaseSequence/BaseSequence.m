classdef(Abstract) BaseSequence < BaseClass
    %SEQUENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant=true, GetAccess=public)
        MAXDTCORSE = 1e-3;
        MAXDTFINE = 1e-4;
    end
    
    properties(Constant=true, GetAccess=public)
        %GAMMA Proton (1H) gyromagnetic ratio
        %   Approximate value: 2.675e8 rad/(s*T)
        %   Reference: http://physics.nist.gov/cgi-bin/cuu/Value?gammap
        gamma(1,1) double {mustBeFinite} = 2.675221900e8;
    end
    
    methods(Static=true, Access=protected)
        [directions] = compute_directions(name)
        [delta] = compute_delta(DELTA, epsilon, bfactor, G_peak)
    end
    
    methods(Access=public)
        [D] = compute_analytical(this, spacing, D0, nTerms)
        [RESULT] = computeResults(this, phase)
        [h] = plot(this, varargin)
    end
    
    properties(GetAccess=protected, SetAccess=protected)
        iT = 0; % state, starts at zero so that first call to .next() initialises to 1
        %\->>> (1,1) double {mustBeFinite,mustBeInteger,mustBeNonnegative}
    end
    methods
        function [bool] = next(this)
            if this.iT >= length(this.dt) % at the end
                bool = false; return;
            end
            this.iT = this.iT + 1;
            bool = true; return;
        end
    end
    
    properties(SetAccess=protected, GetAccess=public)
        dt = zeros(1, 0); % time increments
        %\->>> (1,1) double {mustBeFinite,mustBeInteger,mustBeNonnegative}
        gG = zeros(3 ,0); % gamma * G (gradient waveform)
        %\->>> (1,1) double {mustBeFinite,mustBeInteger,mustBeNonnegative}
        bfactor = []; % b
        %\->>> (1,1) double {mustBeFinite,mustBeInteger,mustBeNonnegative}
    end
    methods
        function [dt] = get_dt(this)
            dt = this.dt(:, this.iT);
        end
        function [gG] = get_gG(this)
            gG = this.gG(:, this.iT);
        end
    end
    
    methods
    end
    
end
