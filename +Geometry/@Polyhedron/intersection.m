function [intersectInfo] = intersection(this, orig, dir)
% Compute the intersection of ray [orig, dir->] with polyhedron
%
% Output:
%   intersectInfo = struct with the following fields:
%       .t        := distance t along the ray where intersection occurs
%       .vertices := vertices of the intersected face

% get the three triangle vertices
[V1, V2, V3] = get_vertices(this.Vertices, this.Faces);

% compute
[intersect, t, u, v] = TriangleRayIntersection(orig, dir, V1, V2, V3);
if ~any(intersect) % no intersections
    intersectInfo = [];
    return;
end

% make sure ray stays away from face edges (includes vertices)
if ~intersection_is_certain(intersect, u, v, t, true)
    error('exec:tooclose', 'too close to edge, vertex, or face');
end

% find closest intersection and get info
found_t = t(intersect);
if numel(found_t) ~= numel(unique(found_t))
    error('exec:twointersect', 'two equal t found');
end
[min_t, min_faceIDs] = min(found_t);
found_ID = find(intersect);
faceID = found_ID(min_faceIDs);

% store
intersectInfo.t = min_t;
intersectInfo.vertices = [V1(faceID, :); V2(faceID, :); V3(faceID, :)];

end
