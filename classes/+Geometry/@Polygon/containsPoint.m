function [inside] = containsPoint(this, point)

inside = inpolygon(point(1), point(2), this.Vertices(:, 1), this.Vertices(:, 2));
%TODO: try to simplify @inpolygon

end
