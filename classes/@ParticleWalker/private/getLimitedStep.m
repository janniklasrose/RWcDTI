function [dxdydz] = getLimitedStep(dim)
% dxdydz = [dx, dy, dz]

maxStep_squared = 5^2;

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
    dxdydz = randn(1, dim);
    needUpdate = sum(dxdydz.^2) > maxStep_squared;
    
end

end
