function [] = assert_poly(xy)

%TODO: implement in mex only (too expensive in .m)

%%% checks
nPmin = 3;
% matrix
if ~ismatrix(xy)
    error('The polygon must be a matrix.');
end
% size
if size(xy, 1) == 2 && size(xy, 2) > nPmin % [ [x1;y1], [xi;yi], [xn;yn] ]
    xy = xy.'; % transpose
elseif size(xy, 2) == 2 && size(xy, 1) > nPmin % [ [x1,y1]; [xi,yi]; [xn,yn] ]
    %xy = xy; % ok
else
    error('The polygon must have dimension [2, N] or [N, 2] where N is at least %i.', nPmin);
end
% points
nP = size(unique(xy, 'rows'), 1); % number of unique points
if nP < 3
    error('The polygon is made up of too few unique (%i) points. Use at least %i unique points.', nP, nPmin);
end
% direction
if ~ispolycw(xy(:, 1), xy(:, 2)) % has to be clockwise
    error('The polygon needs to be defined in a clockwise manner.');
end

end
