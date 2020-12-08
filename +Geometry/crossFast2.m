function [c] = crossFast2(a, b)
% Fast cross product along dim=2

try
    c = crossMex(a, b);
catch exception
    % try-catch is much cheaper than @exist and if-else
    warning(exception.identifier, '%s', exception.message);
    % fallback option
    c = crossMat(a, b); % see function definition below
end

end

function [c] = crossMat(a, b)
% Cross product without overhead
%
% Inputs:
%   a = [Nx3]
%   b = [Nx3]

c = [a(:, 2).*b(:, 3) - a(:, 3).*b(:, 2), ...
     a(:, 3).*b(:, 1) - a(:, 1).*b(:, 3), ...
     a(:, 1).*b(:, 2) - a(:, 2).*b(:, 1)];

end
