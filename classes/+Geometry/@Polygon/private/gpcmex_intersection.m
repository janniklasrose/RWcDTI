function [xy3] = gpcmex_intersection(xy1, xy2)

%TODO: replace with open-source mex code for portability
[xy3] = gpcmex_int(xy1', xy2'); % returns xy3 with NaN-separated polygons [x1, x2, x3, nan, x4, ..., xi, ... xn], or [] if no intersection
% handle NaN (%TODO: structs instead, then add NaNs?)
return;

% p1
p1.x = xy1(1, :);
p1.y = xy1(2, :);
p1.ishole = false();
% p2
p2.x = xy2(1, :);
p2.y = xy2(2, :);
p2.ishole = false();
% mex function call
p3 = gpcmex('int', p1, p2); % gpc (poly clipping) algorithm

% process
xy3 = zeros(2, 0); % empty
if ~isempty(p3)
    n = numel(p3);
    for i = 1:n
        xy3 = [xy3, [p3(i).x(:), p3(i).y(:)].', NaN(2, 1)]; % NaN-separated
    end
    xy3(:, end) = []; % remove last NaN
end

end
 
