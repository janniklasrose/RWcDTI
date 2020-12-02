function setup_par(nCPUs)
% initialises parallel pool if required

if nCPUs > 1 && isempty(gcp('nocreate'))
    if nargin < 1
        nCPUs = feature('numcores');
    end
    mycluster = parcluster('local');
    mycluster.NumWorkers = nCPUs;
    mycluster.NumThreads = 1; % maybe 2 for hyperthreading?
    [~, hostname] = system('hostname'); hostname = strtrim(hostname);
    mkdir('cluster', hostname);
    mycluster.JobStorageLocation = fullfile(pwd, 'cluster', hostname); % pwd for absolute path
    distcomp.feature('LocalUseMpiexec', true);
    parpool(mycluster, nCPUs, 'IdleTimeout', inf);
end

end
