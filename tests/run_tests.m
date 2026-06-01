repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'external', 'yamlmatlab'));

results = runtests(fullfile(repoRoot, 'tests'));
disp(table(results));
assertSuccess(results);
