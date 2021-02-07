function [varargout] = run_forloop(N, func, varargin)
% wrapper to call a function in a for loop
%   enables both serial and parallel loop execution

% prepare output array
nArgout = nargout();
varargout = cell(1, nArgout);

% initialise parallel for loop
nWorkers = active_workers();

% execute loop
tmp_all = cell(1, N);
if isempty(nWorkers)
    bar = waitbar(0, 'Start');
    for i = 1:N
        tmp_iArgout = cell(1, nArgout);
        [tmp_iArgout{1:nargout}] = func(i, varargin{:});
        tmp_all{i} = tmp_iArgout;
        waitbar(i/N, bar, 'Please wait...');
    end
    waitbar(1, bar, 'Done');
    pause(1); % give user a chance to see it
    close(bar);
else
    bar = parforbar_new(N);
    parfor(i = 1:N, nWorkers)
        tmp_iArgout = cell(1, nArgout);
        [tmp_iArgout{1:nArgout}] = func(i, varargin{:});
        tmp_all{i} = tmp_iArgout;
        parforbar_increment(bar);
    end
    parforbar_delete(bar);
end

%TODO: find a better way than this expensive remapping
% needed because parfor doesn't allow us to operate on varargout directly
for iArgout = 1:nArgout
    for i = 1:N
        varargout{iArgout}(i, :) = tmp_all{i}{iArgout}; % reorganise
    end
end

end

function [nWorkers] = active_workers()
% get the number of workers from parpool (or none if no pool exists)
%   always prints a message informing the user. this is to avoid unexpected behaviour,
%   such as when the user forgot to start a parallel pool and should know about it.

% load global variable (set by user or in setup_par)
global NUM_CORES

try
    pool = gcp('nocreate'); % query
catch exception
    % problem with pool, most likely no parallel license
    if strcmp(exception.identifier, 'MATLAB:UndefinedFunction')
        fprintf('Parallel features seem to be unavailable.\n');
    end
    pool = [];
end
if isempty(pool)
    nWorkers = []; % will cause reverse-order serial execution of parfor loop
    fprintf('No parallel pool exists, running loop in serial.\n');
else % ~isempty(pool)
    nWorkers = pool.NumWorkers; % use existing pool
    if ~isempty(NUM_CORES)
        nWorkers = min(NUM_CORES, nWorkers); % limit cores
    end
    fprintf('A parallel pool exists, running loop in parallel (NumWorkers = %i).\n', nWorkers);
end

end

function [bar] = parforbar_new(N)
% attempt to create a new parfor progress bar

try
    bar = ParforProgressbar(N); % see /external/ParforProgMon
catch
    bar = [];
end

end

function [] = parforbar_increment(bar)
% increment the parfor progress bar (if one exists)

if ~isempty(bar)
    bar.increment();
end

end

function [] = parforbar_delete(bar)
% delete the parfor progress bar (if one exists)

if ~isempty(bar)
    bar.delete();
end

end
