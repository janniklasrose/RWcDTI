classdef(Abstract=true) Auxiliary
    
    methods(Static=true, Access=public)
    end
    methods(Static=true, Access=public)
        [dist] = euc_dist(x)
        [] = writemesh(filepath, Faces, Vertices)
        [Faces, Vertices] = readmesh(filepath, varargin)
        [] = notify()
        varargout = parfor_progress(op, varargin)
        squeeze_axes(handles)
        [connectedObjects] = getConnectedObjects(Faces, Vertices)
    end
    
    methods(Static=true, Access=public)
        function [] = MAKE(varargin)
            
            if nargin() == 0 % default
                varargin = {'pdistmex'}; % all
            end
            
            folder = mfilename('fullpath');
            [folder,~,~] = fileparts(folder);
            source_path = fullfile(folder, 'private', 'src');
            object_path = fullfile(folder, 'private');
            
            for iArg = 1:numel(varargin)
                arg = varargin{iArg};
                switch arg
                    case 'pdistmex'
                        source_files = {fullfile(source_path, 'pdistmex.c')};
                        binary_name = 'pdistmex';
                        try
                            mex('-outdir', object_path, '-output', binary_name, source_files{:});
                        catch E
                            warning('Auxiliary:MAKE:CompileError', 'The following compile error occured:\n%s\n', E.getReport);
                        end
                    otherwise
                        error('Auxiliary:MAKE:UnknownTarget', 'Unknown target ''%s''', arg);
                end
            end
            
        end
    end
    
end
