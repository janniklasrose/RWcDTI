function setup_par(nCPUs)
% initialises parallel pool if required
%
% On some systems, parpool initialisation may fail. MathWorks recommends setting:
% >> distcomp.feature('LocalUseMpiexec', false);
% either on-demand or in the user's startup.m file.

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
    parpool(mycluster, nCPUs, 'IdleTimeout', inf);
end

end
