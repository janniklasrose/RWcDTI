classdef ParticleWalker < handle

    properties(SetAccess=immutable, GetAccess=public)
        N_p; % number of particles
    end

    properties(SetAccess=private)
        position; % [nP x DIM] array of [x, y, z]-positions of all particles
        phase; % [nP x DIM] array of accumulated [x, y, z]-phase of all particles
        flag; % {nP x 1} cell array of flags
    end

    properties(SetAccess=private)
        rng_seed; % seed to (all) RNGs
    end

    methods(Access=public)
        function [obj] = ParticleWalker(N_p, seed)

            % prevent recursion
            if nargin == 0
                return;
            end

            % randomness
            if nargin < 2 || strcmp(seed, 'shuffle')
                % shuffle makes MATLAB init based on system time
                tmp = RandStream('mt19937ar', 'Seed', 'shuffle');
                seed = tmp.Seed;
            end
            obj.rng_seed = seed;

            % assign
            obj.N_p = N_p;

            % init
            obj.position = zeros(N_p, 3, 'double'); % initially located at origin
            obj.phase = zeros(N_p, 3, 'double'); % initially no accuired phase
            obj.flag = cell(N_p, 1); % initially unflagged

        end
    end

    methods(Access=public)
        [] = seedParticlesInBox(obj, boundingBoxes, particlesPerBox)
        [scan_data] = performScan(obj, sequence, geometry, voxel)
    end

end
