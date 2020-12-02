function [data] = performScan(obj, sequence, substrate)
% perform the scan using the provided sequence in the provided substrate

% store initial position
pos0 = obj.position;

% loop over all particles (all independent, thus parallel)
[obj.position, obj.phase, obj.flag] = run_forloop(obj.N_p, @one_walker, ...
    obj.position, obj.phase, obj.flag, obj.rng_seed, sequence, substrate);

% check for particles that were flagged
fprintf('Number of flagged particles: %i/%i\n', sum(obj.flag(:)~=0), numel(obj.flag(:)));
valid = ~obj.flag;

% read-out happens inside voxel only
insideVoxel = false(size(obj.flag));
for iP = 1:numel(insideVoxel) % check for each particle
    insideVoxel(iP) = substrate.voxel.containsPoint(obj.position(iP, :));
end

% EC space
% this only makes sense in case of impermeable boundaries
insideECS = isnan(obj.position(:, 4));

% store data
data.phase_ECS = obj.phase( insideECS & insideVoxel & valid, :);
data.phase_ICS = obj.phase(~insideECS & insideVoxel & valid, :);
displacement = obj.position(:, 1:3) - pos0; % only first 3, the 4th stores index!
data.displacement_ECS = displacement( insideECS & valid, :);
data.displacement_ICS = displacement(~insideECS & valid, :);

end
