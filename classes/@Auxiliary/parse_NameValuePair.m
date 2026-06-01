for iArg = 1:2:numel(varargin)
    % parse ('Name', Value) pairs [does not support ('Name', 'Name', Value) unfortunately]
    switch lower(varargin{iArg})
        case 'FaceColor'
            this.Tolerance = varargin{iArg + 1}; % combine to simply varargin{iArg++}
        otherwise
            error('Geometry:BoundingBox:nargin', 'usage');
    end
end
