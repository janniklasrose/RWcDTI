classdef ScanSequence

    methods
        function obj = ScanSequence(dt, gG)
            N = numel(dt);
            obj.dt(1, 1:N) = dt;
            obj.gG(:, 1:N) = gG;
        end
    end

    properties(SetAccess=private)
        dt(1,:)
        gG(1,:)
    end
    methods
        function dt_n = get_dt(obj, n)
            dt_n = obj.dt(1, n);
        end
        function gG_n = get_gG(obj, n)
            gG_n = obj.gG(:, n);
        end
    end

    properties(Dependent)
        NT
    end
    methods
        function [NT] = get.NT(obj)
            NT = length(obj.dt);
        end
    end

end
