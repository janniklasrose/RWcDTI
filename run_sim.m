function run_sim(output_file, varargin)
% setup and run simulation using a configuration file
%   run_sim(output, [config1, ...])

% default arguments
if nargin < 1
    output_file = 'output.mat';
end
if isempty(varargin)
    varargin = {'config.yml'};
end
config_files = varargin;

%% Load configuration

for i = 1:numel(config_files)
    file = config_files{i};
    if ~exist(file, 'file')
        error('Config file "%s" not found', file);
    end
end
configs = cellfun(@yaml.ReadYaml, config_files, 'UniformOutput', false);
config = combine_structs(configs{:});

%% Sequence

if isfield(config.sequence, 'type')
    seq_type = config.sequence.type;
    if isfield(config.sequence, seq_type)
        seq_data = config.sequence.(seq_type);
    else
        seq_data = struct();
    end
    seq_Nt = config.sequence.N_t;
    seq_dtmax = cell2mat(config.sequence.dt_max); % one or two
    sequence = MRI.ScanSequence.create(seq_Nt, seq_dtmax, seq_type, seq_data);
else
    % read dt & gG from file, construct sequence directly
    seq = config.sequence.data;
    sequence = MRI.ScanSequence(cell2mat(seq.dt), cell2mat(seq.gG));
end

%% Substrate

% load myocyte objects
if isfield(config.substrate.geometry.myocytes, 'file')
    myocytes = load(config.substrate.geometry.myocytes.file); % get from file
    myocytes = myocytes.myocytes;
else
    % load .Vertices & .Faces directly from config file
    % need to convert the nested cells from YAML to arrays
    myocytes = cellfun(@(s) struct('Vertices', cell2mat(s.Vertices), ...
                                    'Faces', cell2mat(s.Faces)), ...
                        config.substrate.geometry.myocytes.data);
end

% load other geometry parameters
LxLyLz = cell2mat(config.substrate.geometry.LxLyLz);

% set the transform according to the configuration
if isfield(config.substrate.geometry, 'transform')
    y_extent = cell2mat(config.substrate.geometry.transform.y_extent);
    Ly = LxLyLz(2);
    y_minvals = unique([0:+Ly:y_extent(2), 0:-Ly:y_extent(1)]); % realistic y_slice
    y_slice_minmax = [y_minvals(1:end-1); y_minvals(2:end)]; % use shifted indexing to avoid rounding error
    transform_config = rmfield(config.substrate.geometry.transform, 'y_extent');
    transform = {'block', y_slice_minmax, transform_config};
else
    transform = {'full'};
end

% construct the substrate
substrate = Substrate.Substrate(LxLyLz, myocytes, transform{:});

% add other parameters
voxel = cell2mat(config.substrate.domain.voxel);
substrate.voxel = Geometry.BoundingBox(voxel);
substrate.transit_model = config.substrate.membranes.transit_model;
substrate.kappa = config.substrate.membranes.permeability;
substrate.D_i = config.substrate.diffusivity.D_ics;
substrate.D_e = config.substrate.diffusivity.D_ecs;

%% Monte Carlo

% seed
Np = config.montecarlo.N_p;
rngseed = config.montecarlo.rngseed;
walker = MonteCarlo.ParticleWalker(Np, rngseed); % create system of N_P particles
seeding = config.montecarlo.seedbox; % use alias in case it's char
if ischar(seeding)
    if startsWith(seeding, 'voxel')
        seedbox = voxel;
    elseif startsWith(seeding, 'origin')
        seedbox = zeros(1, 6);
    else
        error('Unknown seedbox option')
    end
    if endsWith(seeding, '+buffer')
        T = sum(sequence.dt); % total simulation time
        buffer = [-1, +1, -1, +1, -1, +1]*sqrt(6 * substrate.D_e * T);
        seedbox = seedbox + buffer;
    end
else % assume numeric value
    seedbox = cell2mat(seeding);
end
seedbox = seedbox.'; % [min; max]-pairs (using min==max results in point seed)
walker.seedParticlesInBox(seedbox);

% set up the parallel
MonteCarlo.setup_par(config.montecarlo.num_cores);

% optionally, configure the step type
if isfield(config.montecarlo, 'stepType')
    walker.stepType = config.montecarlo.stepType;
end

% execute
clock = tic(); % start timer
data = walker.performScan(sequence, substrate); % RUN
runtime = toc(clock);

%% produce output

% save
result = struct('data', data, 'runtime', runtime);
save(output_file, '-struct', 'result', '-v7.3');

end

function [s_out] = combine_structs(varargin)

% find fieldnames
structures = varargin;
N_structures = numel(structures);
struct_fieldnames = cellfun(@(s) fieldnames(s)', structures, 'UniformOutput', false, 'ErrorHandler', @(err, varargin) '-');
aint_struct = cellfun(@(s) isequal(s, '-'), struct_fieldnames);
if any(aint_struct)
    assert(all(aint_struct), 'field is both struct and value');
    s_out = structures{end}; % take the last value
    return
end
fields = unique([struct_fieldnames{:}]);

% initialise empty output struct
s_out = struct();

for i = 1:numel(fields)
    fieldname = fields{i};
    field_values = cell(1, N_structures);
    for j = 1:numel(structures)
        s = structures{j};
        if isfield(s, fieldname)
            field_values{j} = s.(fieldname);
        end
    end
    field_values = field_values(~cellfun(@isempty, field_values));
    s_out.(fieldname) = combine_structs(field_values{:});
end

end
