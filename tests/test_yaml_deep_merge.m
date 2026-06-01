function tests = test_yaml_deep_merge
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'external', 'yamlmatlab'));
end

function testMergeStructDeepPreservesNestedFields(testCase)
base = struct();
base.config = struct();
base.config.montecarlo = struct('n_walkers', 128, 'dt', 0.01);
base.config.sequence = struct('type', 'PGSE', 'TE', 30);
base.output = 'baseline';

override = struct();
override.config = struct();
override.config.montecarlo = struct('dt', 0.02);

merged = yaml.merge_struct(base, override, {}, 'deep');

verifyEqual(testCase, merged.config.montecarlo.n_walkers, 128);
verifyEqual(testCase, merged.config.montecarlo.dt, 0.02);
verifyEqual(testCase, merged.config.sequence.type, 'PGSE');
verifyEqual(testCase, merged.config.sequence.TE, 30);
verifyEqual(testCase, merged.output, 'baseline');
end

function testMergeImportsDeepMergesImportedConfigIntoLocalConfig(testCase)
data = struct();
data.config = struct();
data.config.montecarlo = struct('n_walkers', 256);
data.config.sequence = struct('type', 'STEAM');
data.import = {struct('config', struct( ...
    'montecarlo', struct('dt', 0.005), ...
    'substrate', struct('radius', 8)))};

merged = yaml.mergeimports(data);

verifyEqual(testCase, merged.config.montecarlo.n_walkers, 256);
verifyEqual(testCase, merged.config.montecarlo.dt, 0.005);
verifyEqual(testCase, merged.config.sequence.type, 'STEAM');
verifyEqual(testCase, merged.config.substrate.radius, 8);
verifyFalse(testCase, isfield(merged, 'import'));
end

function testMergeImportsDeepMergesMultipleStructImports(testCase)
data = struct();
data.import = { ...
    struct('config', struct( ...
        'montecarlo', struct('n_steps', 100), ...
        'sequence', struct('TE', 30))), ...
    struct('config', struct( ...
        'montecarlo', struct('dt', 0.01), ...
        'sequence', struct('TR', 1000))) ...
    };

merged = yaml.mergeimports(data);

verifyEqual(testCase, merged.config.montecarlo.n_steps, 100);
verifyEqual(testCase, merged.config.montecarlo.dt, 0.01);
verifyEqual(testCase, merged.config.sequence.TE, 30);
verifyEqual(testCase, merged.config.sequence.TR, 1000);
end
