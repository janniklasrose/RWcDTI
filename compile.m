%>> setenv('MW_MINGW64_LOC', 'C:\mingw-w64\x86_64-7.2.0-posix-seh-rt_v5-rev1\mingw64')
% http://uk.mathworks.com/help/matlab/matlab_external/upgrading-mex-files-to-use-64-bit-api.html

mex('-setup', 'C')

MAKE('+Geometry/@Polyhedron/', 'crossMex')

function [] = MAKE(folder, varargin)

    source_path = fullfile(folder, 'private');
    object_path = fullfile(folder, 'private');

    for iArg = 1:numel(varargin)
        arg = varargin{iArg};
        source_files = {fullfile(source_path, [arg,'.c'])};
        binary_name = arg;
        try
            mex('-outdir', object_path, '-output', binary_name, source_files{:});
        catch E
            warning('MAKE:CompileError', 'The following compile error occured:\n%s\n', E.getReport);
        end
    end

end
