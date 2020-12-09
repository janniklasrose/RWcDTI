function [] = compile(force, setup)
% compile the MEX files

% handle arguments
if nargin < 1
    force = false; % by default don't compile if files exist
end
if nargin < 2
    setup = false; % assume the user has configured MEX
end
validateattributes(force, {'numeric', 'logical'}, {'binary'});
validateattributes(setup, {'numeric', 'logical'}, {'binary'});

if setup
    mex('-setup', 'C');
end

make(force, '+Geometry/private/', 'crossMex')
make(force, '+Substrate/@Substrate/private/', 'needsChecking_box')

end

function [] = make(force, folder, varargin)

for iArg = 1:numel(varargin)
    binary_name = varargin{iArg};
    source_file = fullfile(folder, [binary_name,'.c']);
    target_file = fullfile(folder, [binary_name,'.',mexext]);
    if exist(target_file, 'file') && ~force
        continue
    end
    try
        mex('-outdir', folder, '-output', binary_name, source_file);
    catch E
        warning('compile:make:CompileError', ...
                'The following compile error occured:\n%s\n', E.getReport);
    end
end

end
