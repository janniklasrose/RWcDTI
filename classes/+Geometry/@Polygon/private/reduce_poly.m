% REDUCE_POLY Reduces a polygon to a given number of vertices
%   Syntax: poly = reduce_poly(poly, num)
%
%   Inputs:  poly       Polygon (2 rows, n columns)
%            num        Required number of vertices
%   Outputs: poly       Reduced polygon
%
% Description: This code reduces the number of vertices in a closed polygon
% to the number specified by 'num'. It does this by calculating the
% importance of each vertex based on angle and segment length and then
% removing the least important. The process is repeated until the desired
% number of vertices is reached.
%
% Coded by: Peter Bone (peterbone@hotmail.com)
%------------------------------------------------------------------------
function [poly] = reduce_poly(poly, num)

assert(num >= 3, 'cannot reduce polygon to less than 3 vertices');

nVertices = size(poly, 2);
num = min(num, nVertices);

% Calculate initial importance of each vertex
importance = zeros(1, nVertices);
for iVertex = 1:nVertices
    importance(iVertex) = vertex_importance(iVertex, poly, nVertices);
end

% Iterate until desired number of vertices is reached
while nVertices > num
    
    [~, i] = min(importance(1:nVertices));
    
    % Remove vertex with least importance
    if i < nVertices
        poly(:,i:nVertices-1) = poly(:,i+1:nVertices);
        importance(i:nVertices-1) = importance(i+1:nVertices);
        vp = i;
    else
        vp = 1;
    end
    nVertices = nVertices - 1;
    
    % Recalculate importance for vertices neighbouring the removed one
    vm = 1 + mod(i - 2, nVertices);
    importance(vp) = vertex_importance(vp, poly, nVertices);
    importance(vm) = vertex_importance(vm, poly, nVertices);
    
end

% Clip polygon to the final length
poly = poly(:,1:num);


function a = vertex_importance(v, poly, numv)

% Find adjacent vertices
vp = 1 + mod(v, numv);
vm = 1 + mod(v - 2, numv);

% Obtain adjacent line segments and their lengths
dir1 = poly(:,v) - poly(:,vm);
dir2 = poly(:,vp) - poly(:,v);
len1 = norm(dir1);
len2 = norm(dir2);

% Calculate angle between vectors and multiply by segment lengths
% This is the importance of the vertex.
% Vertices with large angle and large segments attached are less
% likely to be removed
len1len2 = len1 * len2;
a = abs(acos((dir1' * dir2) / len1len2)) * len1len2;
%a = abs(1 - ((dir1' * dir2) / len1len2)) * len1len2;
