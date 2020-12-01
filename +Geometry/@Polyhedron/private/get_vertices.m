function [V1, V2, V3] = get_vertices(vertices, faces)
% Sort vertices of faces into V1, V2, and V3

V1 = vertices(faces(:, 1), :);
V2 = vertices(faces(:, 2), :);
V3 = vertices(faces(:, 3), :);

end
