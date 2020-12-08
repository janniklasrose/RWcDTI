function [newstep] = reflect(oldstep, faceVertices)

V1 = faceVertices(1, :);
V2 = faceVertices(2, :);
V3 = faceVertices(3, :);
edge01 = V2 - V1;
edge02 = V3 - V1;
normal = Geometry.crossFast2(edge01, edge02);
normal = normal/norm(normal, 2);
step_magn = norm(oldstep, 2);
step_norm = oldstep/step_magn;
step_norm_reflected = step_norm(:) - 2*normal(:)*dot(step_norm, normal);
newstep = step_norm_reflected(:)*step_magn;

end
