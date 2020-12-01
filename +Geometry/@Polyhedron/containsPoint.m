function [bool] = containsPoint(this, point)
% A polyhedron contains a point if and only if a ray eminating from that point
%   intersects the faces of the polyhedron an odd number of times.

vertices = this.Vertices; % shorthand
faces = this.Faces;
bool = false(size(point, 1), 1);

% check for obvious rejection
minXYZ = min(vertices, [], 1);
maxXYZ = max(vertices, [], 1);
if ~all(minXYZ<=point & point<=maxXYZ)
    return;
end

% get the three triangle vertices
[V1, V2, V3] = get_vertices(vertices, faces);

% check each point
for iPoint = 1:size(point, 1)
    pnt = point(iPoint, :);

    % compute maximum distance of point to all vertices
    dists = sqrt(sum((pnt-vertices).^2, 2));
    maxdist = max(dists);

    certain = false; % repeat until we are certain
    counter = 0; % keep track of attempts
    while ~certain
        counter = counter + 1;
        if counter > 50
            error('Geometry:Polyhedron:containsPoint', 'Counter > 50');
        end

        % determine ray
        dir = rand(1, 3)-0.5; % pick random direction
        dir = dir/norm(dir, 2); % unit vector
        dir = dir*maxdist*10; % long enough to fully pass through polyhedron

        % compute intersections and test
        [intersect, t, u, v] = TriangleRayIntersection(pnt, dir, V1, V2, V3);
        nIntersects = sum(intersect); % number of intersections
        bool(iPoint) = mod(nIntersects, 2) > 0; % inside if odd

        % make sure ray stays away fron surface triangle edges
        certain = intersection_is_certain(intersect, u, v, t, false);

    end
end

end
