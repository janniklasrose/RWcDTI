function [bool] = containsPoint(this, point)

vertices = this.Vertices;
minXYZ = min(vertices, [], 1);
maxXYZ = max(vertices, [], 1);
if ~all(minXYZ<=point & point<=maxXYZ)
    bool = false;
    return;
end

vert1   = vertices(this.Faces(:, 1), :);
vert2   = vertices(this.Faces(:, 2), :);
vert3   = vertices(this.Faces(:, 3), :);
bool  = false(size(point, 1), 1);
for iPoint = 1:size(point, 1)
    certain = false;
    counter = 0;
    while ~certain
        counter = counter + 1;
        if counter > 50
            error('Geometry:Polyhedron:contains', 'cannot determine inside');
        end
        dir = rand(1, 3)-0.5; % pick random direction
        dir = dir/norm(dir, 2);
        options.eps      = 1e-15; % to check if ray is parallel to face
        options.triangle = 'two sided'; % planeType
        options.ray      = 'ray'; % lineType
        options.border   = 'normal';
        [intersect, t, u, v] = TriangleRayIntersection(point(iPoint, :), dir, vert1, vert2, vert3, options);
        nIntersect = sum(intersect);    % number of intersections
        bool(iPoint) = mod(nIntersect,2)>0; % inside if odd number of intersections
        % make sure ray stays away fron surface triangle edges
        bary = [u, v, 1-u-v];
        bary = bary(intersect,:);
        epsilon = 1e-6;
        certain = all( min(abs(bary),[], 2)>epsilon ) && all( abs(t(intersect))>epsilon );
    end
end

end
