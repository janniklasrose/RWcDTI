function [varargout] = run_forloop(N, func, varargin)

% prepare output array
nArgout = nargout();
varargout = cell(1, nArgout);

% initialise parallel for loop
nWorkers = parfor_init();

% launch timer
timer = tic();
cumtime = zeros(1, N);

% execute loop
tmp_all = cell(1, N);
Auxiliary.parfor_progress('init', N);
if isempty(nWorkers)
    for i = 1:N
        tmp_iArgout = cell(1, nArgout);
        tt = tic;
        [tmp_iArgout{1:nargout}] = func(i, varargin{:});
        te = toc(tt);
        cumtime(i) = te;
        tmp_all{i} = tmp_iArgout;
        Auxiliary.parfor_progress('update');
    end
else
    parfor(i = 1:N, nWorkers)
        tmp_iArgout = cell(1, nArgout);
        tt = tic;
        [tmp_iArgout{1:nArgout}] = func(i, varargin{:});
        te = toc(tt);
        cumtime(i) = te;
        tmp_all{i} = tmp_iArgout;
        Auxiliary.parfor_progress('update');
    end
end
Auxiliary.parfor_progress('reset');
for iArgout = 1:nArgout
    for i = 1:N
        varargout{iArgout}(i, :) = tmp_all{i}{iArgout}; % reorganise
    end
end

% get elapsed time
toc(timer); % prints if no return arguments
fprintf('runtime = %g\n', sum(cumtime));

end

function [nWorkers] = parfor_init()

% number of workers
pool = gcp('nocreate'); % query
if isempty(pool)
    nWorkers = []; % will cause reverse-order serial execution of parfor loop
    fprintf('No parallel pool exists, running loop in serial.\n');
else % ~isempty(pool)
    nWorkers = pool.NumWorkers; % use existing pool
    fprintf('A parallel pool exists, running loop in parallel (NumWorkers = %i).\n', nWorkers);
end

end
