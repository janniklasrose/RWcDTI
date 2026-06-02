function tests = test_validation
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
repoRoot = fileparts(fileparts(mfilename('fullpath')));
testCase.TestData.OriginalPath = path;
addpath(repoRoot);
end

function teardownOnce(testCase)
path(testCase.TestData.OriginalPath);
end

function testScanSequenceValidatesConstructorInputs(testCase)
verifyAnyError(testCase, @() MRI.ScanSequence([0.01, -0.01], [0, 0]));
verifyAnyError(testCase, @() MRI.ScanSequence([0.01, 0.01], [0, NaN]));

sequence = MRI.ScanSequence([0.01, 0.02], [1, 2; 3, 4; 5, 6]);

verifyEqual(testCase, sequence.NT, 2);
verifyEqual(testCase, sequence.get_gG(2), [2; 4; 6]);
end

function testSubstrateConfigurationValidation(testCase)
substrate = minimalSubstrate();

substrate.transit_model = 'Fieremans2010';
substrate.dim = 'xy';
substrate.kappa = 0.1;
substrate.D_i = 1;
substrate.D_e = 1;

verifyEqual(testCase, substrate.transit_model, 'Fieremans2010');
verifyEqual(testCase, substrate.dim, 'xy');
verifyAnyError(testCase, @() assignProperty(substrate, 'transit_model', 'invalid'));
verifyAnyError(testCase, @() assignProperty(substrate, 'dim', 'abc'));
verifyAnyError(testCase, @() assignProperty(substrate, 'kappa', -1));
verifyAnyError(testCase, @() assignProperty(substrate, 'D_i', Inf));
end

function testParticleWalkerValidation(testCase)
verifyAnyError(testCase, @() MonteCarlo.ParticleWalker(0, 0));
verifyAnyError(testCase, @() MonteCarlo.ParticleWalker(1.5, 0));
verifyAnyError(testCase, @() MonteCarlo.ParticleWalker(1, -1));

walker = MonteCarlo.ParticleWalker(2, 0);
walker.stepType = 'normal';

verifyEqual(testCase, walker.N_p, 2);
verifyEqual(testCase, walker.stepType, 'normal');
verifyAnyError(testCase, @() assignProperty(walker, 'stepType', 'unsupported'));
end

function substrate = minimalSubstrate()
vertices = [0, 0, 0;
            1, 0, 0;
            0, 1, 0;
            0, 0, 1];
faces = uint16([1, 2, 3;
                1, 2, 4;
                1, 3, 4;
                2, 3, 4]);
myocyte = Geometry.Polyhedron(vertices, faces);
substrate = Substrate.Substrate([1, 1, 1], myocyte, 'full');
end

function assignProperty(obj, name, value)
obj.(name) = value;
end

function verifyAnyError(testCase, func)
try
    func();
catch
    return
end

verifyFail(testCase, 'Expected function to throw an error.');
end
