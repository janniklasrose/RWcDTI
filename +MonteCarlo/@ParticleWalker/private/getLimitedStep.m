function [dxdydz] = getLimitedStep(dim, maxStepLength, rngstream)
% Return a Gaussian step with limited length
% Output:
%   dxdydz := [dx, dy, dz]

% default for max step length
if nargin < 2
    maxStepLength = 5;
end
maxStep_squared = maxStepLength^2;

% default for random number stream
if nargin < 3
    stream = {};
else
    stream = {rngstream};
end

% step in space
dxdydz = zeros(1, dim);
needUpdate = true();
tries = 0;
while needUpdate

    % check
    tries = tries + 1;
    if tries > 10
        error('exec:stepsize', 'cannot draw step with limited size');
    end

    % update BEFORE checking new needUpdate (because of initialisation)
    dxdydz = randn(stream{:}, 1, dim);
    needUpdate = sum(dxdydz.^2) > maxStep_squared;

end

end
