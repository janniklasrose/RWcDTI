function [bool] = overlapsWithBoundingBox(this, that)
%   Two axis-aligned cuboids (or of any dimension) overlap if and only if the projections to all axes overlap.
%   The projection to an axis is simply the coordinate range for that axis.

%%% checks
%{
% this check is inefficient
if ~isa(that, 'Geometry.BoundingBox')
    error('Geometry:BoundingBox:overlapsWithBoundingBox:that', 'Wrong type for other BoundingBox');
end
%}

%%% loop over dimensions
bool = true;
%{
% this is more legible but less efficient
for i = 1:min(this.DIM, that.DIM)
    bool = bool && (this.Range(2*i) >= that.Range(2*i-1) && this.Range(2*i-1) <= that.Range(2*i));
end
%}
range1 = this.Range; range2 = that.Range; % this is more efficient
for i = 1:min(this.DIM, that.DIM)
    bool = bool && (range1(2*i) >= range2(2*i-1) && range1(2*i-1) <= range2(2*i));
end

end
