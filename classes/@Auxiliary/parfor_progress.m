function varargout = parfor_progress(op, varargin)
%PARFOR_PROGRESS Progress monitor (progress bar) that works with parfor.
%   Example:
%
%      N = 100;
%      parfor_progress(N);
%      parfor i=1:N
%         pause(rand); % Replace with real code
%         parfor_progress;
%      end
%      parfor_progress(0);
%
%   See also PARFOR.

% By Jeremy Scheff - jdscheff@gmail.com - http://www.jeremyscheff.com/

return

% temporary file
%{
persistent FILEPATH;
if isempty(FILEPATH)
    FILEPATH = tempname();
end
%}
%%%%%%NOTE: persistent does not work with parfor loop!!!!!
FILEPATH = fullfile(tempdir(), 'parfor_progress_tmp.bin');
[folderPath, fileName, fileExt] = fileparts(FILEPATH);

% constant
width = 50; % Width of progress bar
rewind = repmat(char(8), [1, 7+width+2]);

switch op
    case 'init'
        
        fileID = fopen(FILEPATH , 'w');
        if fileID < 0
            error('parfor_progress:init' ...
                 ,'Do you have write permissions for %s?', folderPath);
        end
        
        maxIterations = intmax('uint32');
        nIterations = varargin{1};
        if nIterations > maxIterations
            error('parfor_progress:init' ...
                 ,'Cannot give updates for more than %d loop iterations', maxIterations);
        end
        
        fwrite(fileID, nIterations, 'uint32'); % header
        fwrite(fileID, 0, 'uint32'); % initial state
        fclose(fileID);
        
        percent = 0;
        if nargout() == 0
            fprintf('progress: %3.f%% [%s%s]\n', percent, repmat('=', [1, 0]), repmat(' ', [1, width]));
            return;
        end
        varargout{1} = percent;
        
    case 'update'
        
        if ~exist(FILEPATH, 'file')
            error('parfor_progress:update', ...
                'Could not find progress file (%s). Run PARFOR_PROGRESS(''init'', nIterations) to initialize!', FILEPATH);
        end
        
        fileID = fopen(FILEPATH, 'r+');
        
        data = fread(fileID, 2, 'uint32');
        nIterations = data(1);
        iIteration = data(2) + 1;
        
        sizeof = 4; % for 'uint32'
        fseek(fileID, -sizeof, 'cof');
        fwrite(fileID, iIteration, 'uint32');
        
        fclose(fileID);
        
        percent = iIteration/nIterations * 100;
        if nargout == 0
            n = round(percent*width/100);
            fprintf('%s %3.f%% [%s%s]\n', rewind, percent, repmat('=', [1, n]), repmat(' ', [1, width-n]));
            return;
        end
        varargout{1} = percent;
        
    case 'reset'
        
        fileID = fopen(FILEPATH, 'r');
        fclose(fileID);
        delete(FILEPATH);
        
        percent = 100;
        if nargout() == 0
            fprintf('%s %3.f%% [%s%s]\n', rewind, percent, repmat('=', [1, width]), repmat(' ', [1, 0]));
            return;
        end
        varargout{1} = percent;
        
    otherwise
        
        error('parfor_progress:usage', 'Illegal usage of parfor_progress');
        
end

end
