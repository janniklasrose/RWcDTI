function run_sim(config_file, output_file)
% setup and run simulation using a configuration file

% default arguments
if nargin < 1
    config_file = 'config.yml';
end
if nargin < 2
    output_file = 'output.mat';
end

%% Load configuration

config = yaml.ReadYaml(config_file);

%% Sequence

seq_type = config.sequence.type;
if isfield(config.sequence, seq_type)
    seq_data = config.sequence.(seq_type);
else
    seq_data = struct();
end
seq_Nt = config.sequence.N_t;
seq_dtmax = cell2mat(config.sequence.dt_max); % one or two
sequence = MRI.make_sequence(seq_Nt, seq_dtmax, seq_type, seq_data);

%% Substrate

% load myocyte objects
if isfield(config.substrate.geometry.myocytes, 'file')
    myocytes = load(config.substrate.geometry.myocytes.file); % get from file
    myocytes = myocytes.myocytes;
else
    % load .Vertices & .Faces directly from config file
    error('Error:NotImplemented', 'Loading polyhedra from config not supported');
end

% load other geometry parameters
LxLyLz = cell2mat(config.substrate.geometry.LxLyLz);

% set the transform according to the configuration
if isfield(config.substrate.geometry, 'transform')
    rot = config.substrate.geometry.transform.deg_rot_per_L_in_y;
    y_extent = cell2mat(config.substrate.geometry.transform.y_extent);
    Ly = LxLyLz(2);
    y_minvals = unique([0:+Ly:y_extent(2), 0:-Ly:y_extent(1)]); % realistic y_slice
    y_slice_minmax = [y_minvals(1:end-1); y_minvals(2:end)]; % use shifted indexing to avoid rounding error
    transform = {'block', y_slice_minmax, 'deg_rot_per_L_in_y', rot};
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
seed = config.montecarlo.seed;
walker = MonteCarlo.ParticleWalker(Np, seed); % create system of N_P particles
T = sum(sequence.dt); % total simulation time
buffer = [-1, +1, -1, +1, -1, +1]*sqrt(6 * substrate.D_e * T);
seedbox = voxel + buffer; % with buffer
walker.seedParticlesInBox(seedbox.'); % [min; max]-pairs (using min==max results in point seed)

% set up the parallel
MonteCarlo.setup_par(config.montecarlo.num_cores);

% execute
clock = tic(); % start timer
data = walker.performScan(sequence, substrate); % RUN
runtime = toc(clock);

%% produce output

% save
result = struct('data', data, 'runtime', runtime);
save(output_file, '-struct', 'result', '-v7.3');

end
