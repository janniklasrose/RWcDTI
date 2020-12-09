function setup_par(nCPUs)
% initialises parallel pool if required

% set a global variable for ParticleWalker.run_forloop
global NUM_CORES

if nCPUs > 1 && isempty(gcp('nocreate')) % throws if no pool support but only if nCPUS>1
    NUM_CORES = nCPUs;
    if nargin < 1
        nCPUs = feature('numcores');
    end
    mycluster = parcluster('local');
    mycluster.NumWorkers = nCPUs;
    mycluster.NumThreads = 1; % maybe 2 for hyperthreading?
    [~, hostname] = system('hostname'); hostname = strtrim(hostname);
    mkdir('cluster', hostname);
    mycluster.JobStorageLocation = fullfile(pwd, 'cluster', hostname); % absolute path
    distcomp.feature('LocalUseMpiexec', true);
    parpool(mycluster, nCPUs, 'IdleTimeout', inf);
end

end
