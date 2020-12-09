function [dxdydz] = getLimitedStep(dim, maxStepLength, varargin)
% Return a Gaussian step with limited length
% Output:
%   dxdydz := [dx, dy, dz]

% step in space
maxStep_squared = maxStepLength^2; % pre-compute here
dxdydz = zeros(1, dim);
needUpdate = true();
tries = 0;
while needUpdate

    % check
    tries = tries + 1;
    if tries > 10
        error('ParticleWalker:getLimitedStep:tries', 'Cannot draw step with limited size');
    end

    % update BEFORE checking new needUpdate (because of initialisation)
    dxdydz = getStep(dim, varargin{:});
    needUpdate = sum(dxdydz.^2) > maxStep_squared;

end

end

function [dxdydz] = getStep(dim, varargin)
% Produce a random step
%   getStep(dim, [stepType], [stream])

% process optional arguments
if length(varargin) < 1
    stepType = 'constant';
else
    stepType = varargin{1};
end
if length(varargin) < 2
    stream = {}; % default MATLAB
else
    stream = varargin(2); % get cell, not content
end

switch stepType
    case 'normal'
        dxdydz = randn(stream{:}, 1, dim);
    case 'constant'
        choiceVector = [-1, +1]; % left or right
        dxdydz = choiceVector(randi(stream{:}, numel(choiceVector), [1, dim]));
    otherwise
        error('Error:NotImplemented', 'Step type not supported');
end

end
