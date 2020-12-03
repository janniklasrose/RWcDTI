function [] = seedParticlesInBox(obj, boundingBoxes, particlesPerBox)
% Seed particles in boxes
%
%   boundingBox = [min_x1, min_x2; max_x, max_x2; ...; min_z1, min_z2; max_z1, max_z2]
%       \
%        \-> min==max allowed, will seed at that value for given dimension

% create a stream just for this to not interfere with other random stuff happening outside
rngstream = RandStream.create('mt19937ar', 'Seed', obj.rng_seed);

%%% checks and overloading
% bounding boxes
validateattributes(boundingBoxes, {'numeric'}, {'2d', 'nonempty', 'finite'});
% dimensions
N_b = size(boundingBoxes, 2);
switch size(boundingBoxes, 1)
    case 2 % [xmin; xmax]
        boundingBoxes(3:6, :) = zeros(4, N_b);
    case 4 % [xmin; xmax; ymin; ymax]
        boundingBoxes(5:6, :) = zeros(2, N_b);
    case 6 % [xmin; xmax; ymin; ymax; zmin; zmax]
        % ok
    otherwise
        error('ParticleWalker:seedParticlesInBox:inconsistent', ...
            'BBs must be [M,N] with M=2,4,6 and N=N_p');
end
% inconsistent
if any(boundingBoxes(1:2:end) > boundingBoxes(2:2:end)) % some box has min > max for some dimension
    error('ParticleWalker:seedParticlesInBox:inconsistent', ...
          'BBs must be [[xmin;xmax;ymin;ymax;zmin;zmax], []]');
end
% overlap
for i = 1:N_b
    box_i = boundingBoxes(:, i);
    for j = (i+1):N_b
        box_j = boundingBoxes(:, j);
        if all(box_i(1:2:end)<box_j(2:2:end) & box_j(1:2:end)<box_i(2:2:end)) % overlap if min<max
            error('ParticleWalker:seedParticlesInBox:inconsistent', ...
                  'BBs cannot overlap');
        end
    end
end
% particles per box
switch nargin()
    case 2 % particlesPerBox not specified
        sideLengths = boundingBoxes(2:2:end, :)-boundingBoxes(1:2:end, :); % max(:)-min(:)
        hasZeroDim = sideLengths == 0;
        if any(any(hasZeroDim, 2) ~= all(hasZeroDim, 2)) % zero-dimension inconsistent across boxes
            error('ParticleWalker:seedParticlesInBox:inconsistent', ...
                  'Each dimension must be either zero or non-zero across all boxes');
        end
        sideLengths(all(hasZeroDim, 2), :) = []; % remove zero-dimensions
        boxVolumes = prod(sideLengths, 1);
        particlesPerBox_theo = boxVolumes/sum(boxVolumes)*obj.N_p;
        particlesPerBox_prel = floor(particlesPerBox_theo); % preliminary, might be missing a few
        missesParticles = randperm(rngstream, N_b, obj.N_p-sum(particlesPerBox_prel));
        particlesPerBox_prel(missesParticles) = particlesPerBox_prel(missesParticles)+1; % increase
        particlesPerBox = particlesPerBox_prel;
    case 3 % particlesPerBox specified
        if isscalar(particlesPerBox) % scalar
            particlesPerBox = ones(1, N_b)*particlesPerBox; % make row
        end
        validateattributes(particlesPerBox, {'numeric'}, {'row', 'integer', 'nonnegative', 'finite'});
        if numel(particlesPerBox) ~= N_b % inconsistent
            error('ParticleWalker:seedParticlesInBox:inconsistent', ...
                  'Dimension mismatch, need to assign particles for each box');
        end
        if sum(particlesPerBox) ~= obj.N_p % inconsistent
            error('ParticleWalker:seedParticlesInBox:inconsistent', ...
                  'Not all or too many particles assigned');
        end
    otherwise
        narginchk(2, 3);
end

%%% place
iP_setLast = 0;
for iB = 1:N_b
    % logistics
    boundingBox = boundingBoxes(:, iB);
    nP_iB = particlesPerBox(iB); % tmp
    index = iP_setLast+(1:nP_iB).'; % indices (nP_iB may be 0)
    iP_setLast = iP_setLast + nP_iB; % increment particle counter
    % shift random numbers to fit in open interval (min, max) for each dimension
    obj.position(index, 1) = rand(rngstream, nP_iB, 1)*(boundingBox(2)-boundingBox(1))+boundingBox(1);
    obj.position(index, 2) = rand(rngstream, nP_iB, 1)*(boundingBox(4)-boundingBox(3))+boundingBox(3);
    obj.position(index, 3) = rand(rngstream, nP_iB, 1)*(boundingBox(6)-boundingBox(5))+boundingBox(5);
end

end
