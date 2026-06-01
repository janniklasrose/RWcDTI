function [bool] = containsPoint(this, point)
%   An axis-aligned cuboid (or of any dimension) contains a point if and only if each coordinate is inside the box.

%%% checks
%{
% this check is inefficient
if ~isa(point, 'Geometry.Point')
    error('Geometry:BoundingBox:containsPoint:point', 'Point must be of type <Geometry.Point>');
end
%}

%%% loop over dimensions
bool = true;
%{
% this requires @Geometry.Point
for i = 1:min(this.DIM, point.DIM)
    bool = bool && (point.Coordinates(i) >= this.Range(2*i-1) && point.Coordinates(i) <= this.Range(2*i));
end
%}
range = this.Range; % this is more efficient
for i = 1:min(this.DIM, numel(point))
    bool = bool && (point(i) >= range(2*i-1) && point(i) <= range(2*i));
end

end
