function [intersect, t, u, v] = TriangleRayIntersection(orig, dir, V1, V2, V3)
%
% Modified version of TriangleRayIntersection.
%
% Original Author:
%    Jarek Tuszynski (jaroslaw.w.tuszynski@leidos.com)
%
% License: BSD license (http://en.wikipedia.org/wiki/BSD_licenses)

% scale orig and dir
Nverts = size(V1, 1);
orig = ones(Nverts, 3).*orig;
dir  = ones(Nverts, 3).*dir;

% tolerances
eps = 1e-20;
zero = 0.0;

% initialize default output
intersect = false(Nverts, 1); % by default there are no intersections
[t, u, v] = deal(inf(Nverts, 1));

% some pre-calculations
edge1 = V2 - V1; % find vectors for two edges sharing V1
edge2 = V3 - V1;
tvec = orig - V1; % vector from V1 to ray origin
pvec = crossFast2(dir, edge2);
qvec = crossFast2(tvec, edge1);
det = sum(edge1.*pvec, 2); % determinant of the matrix M = dot(edge1, pvec)

% find faces parallel to the ray
angleOK = (abs(det)>eps); % if det ~ 0 then ray lies in the triangle plane
if all(~angleOK), return; end % if all parallel then no intersections
det(~angleOK) = nan; % change to avoid division by zero

% calculate all variables for all line/triangle pairs
u = sum(tvec .*pvec, 2)./det; % 1st barycentric coordinate
v = sum(dir  .*qvec, 2)./det; % 2nd barycentric coordinate
t = sum(edge2.*qvec, 2)./det; % 'position on the line' coordinate

% test if line/plane intersection is within the triangle
ok = (angleOK & u>=-zero & v>=-zero & u+v<=1.0+zero);

% compute where along the line the intersection occurs
intersect = (ok & t>=-zero & t<=1.0+zero); % between origin and destination

end

function [c] = crossFast2(a, b)
% Fast cross product along dim=2

useMex = false;
if useMex % compiled MEX file
    c = crossMex(a, b);
else % see function definition below
    c = crossMat(a, b);
end

end

function [c] = crossMat(a, b)
% Cross product without overhead
%
% Inputs:
%   a = [Nx3]
%   b = [Nx3]

c = [a(:, 2).*b(:, 3) - a(:, 3).*b(:, 2), ...
     a(:, 3).*b(:, 1) - a(:, 1).*b(:, 3), ...
     a(:, 1).*b(:, 2) - a(:, 2).*b(:, 1)];

end
