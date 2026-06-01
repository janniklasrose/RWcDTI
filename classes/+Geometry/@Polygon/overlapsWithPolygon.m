function [bool] = overlapsWithPolygon(this, that)

%%% cheap BoundingBox test before expensive Polygon test
if ~this.BoundingBox.overlapsWithBoundingBox(that.BoundingBox)
    bool = false;
    return;
end

%%% actual check
bool = ~isempty(gpcmex_intersection(this.VerticesT, that.VerticesT));

end
