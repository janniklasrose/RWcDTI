function [bool] = containsPoint(this, point)
% An axis-aligned cuboid (or of any dimension) contains a point if and only if
%   each coordinate is fully inside the bounds of the box.

% loop over dimensions
bool = true;
for i = 1:min(numel(this.Range)/2, numel(point))
    bool = bool && (point(i) >= this.Range(2*i-1) && point(i) <= this.Range(2*i));
end

end
