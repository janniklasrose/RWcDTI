function [certain] = intersection_is_certain(intersect, u, v, t, test_end, eps)
% Check if the intersection is certain by some tolerance

if nargin < 5
    test_end = false;
end
if nargin < 6
    eps = 1e-6; % relative wrt 1 for bary, wrt step length for t
end

bary = [u, v, 1-u-v]; % barycentric coordinates
min_abs_bary = min(abs(bary(intersect, :)), [], 2);
abs_t0_int = abs(t(intersect));
abs_t1_int = abs(1-t(intersect));
certain = all(min_abs_bary > eps) && all(abs_t0_int > eps);
if test_end
    certain = certain && all(abs_t1_int > eps);
end

end
