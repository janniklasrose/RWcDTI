classdef ParticleWalker < BaseClass
    
    properties(SetAccess=immutable, GetAccess=public)
        nP; % number of particles
    end
    
    properties(SetAccess=public, GetAccess=public) %TODO: help/doc %TODO: set SetAccess back to private !!!!!!
        position; % [nP x DIM] array of [x, y, z]-positions of all particles
        phase; % [nP x DIM] array of accumulated [x, y, z]-phase of all particles
        flag; % [nP x 1] array of flags
    end
    
    methods(Access=public)
        function [this] = ParticleWalker(nP)
            
            % prevent recursion
            if nargin == 0
                return;
            end
            
            % assign
            this.nP = nP;
            
            % init
            this.position = zeros(nP, 3, 'double'); % initially located at origin
            this.phase = zeros(nP, 3, 'double'); % initially no accuired phase
            this.flag = zeros(nP, 1, 'uint8'); % initially unflagged
            
        end
    end
    
    methods(Access=public)
        [] = seedParticlesInBox(this, boundingBoxes, particlesPerBox)
        [tensor_values, nParticles, history, posHist] = performScan(this, sequence, geometry)
        [] = plot(this)
    end
    
    methods(Static=true, Access=public)
        function [] = MAKE(varargin)
            
            if nargin() == 0 % default
                varargin = {'needsChecking_box'}; % all
            end
            
            folder = mfilename('fullpath');
            [folder,~,~] = fileparts(folder);
            source_path = fullfile(folder, 'private', 'src');
            object_path = fullfile(folder, 'private');
            
            for iArg = 1:numel(varargin)
                arg = varargin{iArg};
                switch arg
                    case 'needsChecking_box'
                        source_files = {fullfile(source_path, 'needsChecking_box.c')};
                        binary_name = 'needsChecking_box';
                        try
                            mex('-outdir', object_path, '-output', binary_name, source_files{:});
                        catch E
                            warning('ParticleWalker:MAKE:CompileError', 'The following compile error occured:\n%s\n', E.getReport);
                        end
                    otherwise
                        warning('ParticleWalker:MAKE:UnknownTarget', 'Unknown target ''%s''', arg);
                end
            end
            
        end
    end
    
end
