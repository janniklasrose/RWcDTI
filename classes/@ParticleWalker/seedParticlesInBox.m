function [] = seedParticlesInBox(this, boundingBoxes, particlesPerBox)
%PARTICLEWALKER.SEEDPARTICLESINBOX Summary
%
%   Description
%
%   boundingBox = [min_x1, min_x2; max_x, max_x2; ...; min_z1, min_z2; max_z1, max_z2]
%       \
%        \-> min==max allowed, will seed at that value for given dimension
%
%   See also PARTICLEWALKER

%TODO: allow for placement in ellipse(/circular) cylinders via rand_z, rand_r, rand_t to test confined cylinders!!!! do with optional flag ('rectangle', 'circle', 'ellipse')
%       \_- achieve this via a cell arrays (with optional char cell array for type) to combine shapes

%TODO: improve error messages (after including changes in other TODOs)

%%% checks and overloading
% bounding boxes
validateattributes(boundingBoxes, {'numeric'}, {'2d', 'nonempty', 'finite'});
% dimensions
nB = size(boundingBoxes, 2);
switch size(boundingBoxes, 1)
    case 2 % [xmin; xmax]
        boundingBoxes(3:6, :) = zeros(4, nB);
    case 4 % [xmin; xmax; ymin; ymax]
        boundingBoxes(5:6, :) = zeros(2, nB);
    case 6 % [xmin; xmax; ymin; ymax; zmin; zmax]
        % ok
    otherwise
        error('boundingBoxes must be [M,N] with M=2,4,6 and N=nP');
end
% inconsistent
if any(boundingBoxes(1:2:end) > boundingBoxes(2:2:end)) % some box has min > max for some dimension
    error('boundingBoxes must be [[xmin;xmax;ymin;ymax;zmin;zmax], []]');
end
% overlap
for i = 1:nB
    box_i = boundingBoxes(:, i);
    for j = (i+1):nB
        box_j = boundingBoxes(:, j);
        if all(box_i(1:2:end)<box_j(2:2:end) & box_j(1:2:end)<box_i(2:2:end)) % overlap if min<max
            error('ERROR');
        end
    end
end
% particles per box
switch nargin()
    case 2 % particlesPerBox not specified
        sideLengths = boundingBoxes(2:2:end, :)-boundingBoxes(1:2:end, :); % max(:)-min(:)
        hasZeroDim = sideLengths == 0;
        if any(any(hasZeroDim, 2) ~= all(hasZeroDim, 2)) % zero-dimension inconsistent across boxes
            error('Each dimension must be either zero or non-zero across all boxes');
        end
        sideLengths(all(hasZeroDim, 2), :) = []; % remove zero-dimensions
        boxVolumes = prod(sideLengths, 1);
        particlesPerBox_theo = boxVolumes/sum(boxVolumes)*this.nP;
        particlesPerBox_prel = floor(particlesPerBox_theo); % preliminary, might be missing a few
        missesParticles = randperm(nB, this.nP-sum(particlesPerBox_prel));
        particlesPerBox_prel(missesParticles) = particlesPerBox_prel(missesParticles)+1; % increase
        particlesPerBox = particlesPerBox_prel;
    case 3 % particlesPerBox specified
        if isscalar(particlesPerBox) % scalar
            particlesPerBox = ones(1, nB)*particlesPerBox; % make row
        end
        validateattributes(particlesPerBox, {'numeric'}, {'row', 'integer', 'nonnegative', 'finite'});
        if numel(particlesPerBox) ~= nB % inconsistent
            error('Dimension mismatch, need to assign particles for each box');
        end
        if sum(particlesPerBox) ~= this.nP % inconsistent
            error('Not all or too many particles assigned');
        end
    otherwise
        narginchk(2, 3);
end

%%% place
iP_setLast = 0;
for iB = 1:nB
    % logistics
    boundingBox = boundingBoxes(:, iB);
    nP_iB = particlesPerBox(iB); % tmp
    index = iP_setLast+(1:nP_iB).'; % indices (nP_iB may be 0)
    iP_setLast = iP_setLast + nP_iB; % increment particle counter
    % shift random numbers to fit in open interval (min, max) for each dimension
    this.position(index, 1) = rand(nP_iB, 1)*(boundingBox(2)-boundingBox(1))+boundingBox(1);
    this.position(index, 2) = rand(nP_iB, 1)*(boundingBox(4)-boundingBox(3))+boundingBox(3);
    this.position(index, 3) = rand(nP_iB, 1)*(boundingBox(6)-boundingBox(5))+boundingBox(5);
end

end
