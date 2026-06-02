function [intersectInfo, leavesBlock] = intersectBlock(obj, position, dxdydz)
%INTERSECTBLOCK Find the block boundary intersection for a local step.
%   [intersectInfo, leavesBlock] = intersectBlock(obj, position, dxdydz)
%   checks whether position + dxdydz leaves the local substrate block. If it
%   does, intersectInfo contains the first block boundary intersection.

positionFuture = position + dxdydz;
leavesBlock = ~obj.block_bb.BoundingBox.containsPoint(positionFuture);

if leavesBlock
    intersectInfo = obj.block_bb.intersection(position, dxdydz);
else
    intersectInfo = [];
end

end
