function [directions] = compute_directions(name)

% REFERENCE: "Optimal Strategies for Measuring Diffusion in Anisotropic...
% Systems by MRI" by Jones DK, Horsfield MA, Simmons A. Tables 1 & 2

% [x_1 y_1 z_1;x_2 y_2 z_2...;x_n y_n z_n]; where n = number of directions

if nargin() == 0
    name = 'default';
end

switch lower(name)
    case {'default', 'six', 6, ''}
        directions = [ +1. , +1. ,  0. ;
                       +1. , -1. ,  0. ;
                       +1. ,  0. , +1. ;
                       +1. ,  0. , -1. ;
                        0. , +1. , +1. ;
                        0. , +1. , -1. ];
    otherwise
        error('what is the matter with you?');
end

end
