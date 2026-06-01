function [intersectInfo] = intersection(this, orig, dir)

% out: intersectInfo = struct with the following fields:
%   't' = t along ray
%   'T_enter_F_exit' = true if enter, false if exit
%   'normal' = outward-normal vector

% ray-triangle-intersection options
%{
options.eps      = 1e-20;
options.triangle = 'two sided'; % planeType
options.ray      = 'segment'; % lineType
options.border   = 'normal'; %%% 'normal'
options.fullReturn   = true;
%}
options = [];
% sort vertices
vertices = this.Vertices;
vert0 = vertices(this.Faces(:, 1), :);
vert1 = vertices(this.Faces(:, 2), :);
vert2 = vertices(this.Faces(:, 3), :);
% compute
[intersect, t, u, v] = TriangleRayIntersection(orig, dir, vert0, vert1, vert2, options); % xcoord (5th) output ignored
if ~any(intersect) % no intersections
    intersectInfo = [];
    return;
end

% make sure ray stays away from face edges (includes vertices)
bary = [u, v, 1-u-v];
bary = bary(intersect,:);
epsilon = 1e-6; % relative wrt 1 for bary, wrt step length for t
certain = all( min(abs(bary),[], 2)>epsilon ) && all( abs(t(intersect))>epsilon ) && all( abs(1-t(intersect))>epsilon );
if ~certain
    error('exec:tooclose', 'too close to edge, vertex, or face');
end

% find closest intersection and get info
found_t = t(intersect);
found_ID = find(intersect);
if numel(found_t) ~= numel(unique(found_t))
    error('exec:twointersect', 'two equal t found');
end
[min_t, min_faceIDs] = min(found_t);
faceID = found_ID(min_faceIDs);
intersectInfo.t = min_t;
intersectInfo.vertices = vertices(this.Faces(faceID, :), :);
VAR_value = this.VolumeAreaRatio_chached; % try cached one first
if ~isempty(VAR_value) % not in cache
    VAR_value = this.Volume/this.SurfaceArea;
end
intersectInfo.VolumeAreaRatio = VAR_value; % add permeability?

end
