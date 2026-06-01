function [connectedObjects] = getConnectedObjects(Faces, Vertices)
%CONNECTEDFACES Summary of this function goes here
%   Detailed explanation goes here

error('not yet done');

empty = struct('Faces', [], 'Vertices', []);
objects = repmat(empty, [1, 0]);
nObjects = 0;
iFaceAlreadyAdded = false(1, nFaces_orig);

numFaces=tris.size(1);
nbList=tris.neighbors;
adjMat=zeros(numFaces);
for count=1:numFaces
    if ~isnan(nbList(count,1))
        adjMat(count, nbList(count,1))=1;
    end
    if ~isnan(nbList(count,2))
        adjMat(count, nbList(count,2))=1;
    end
    if ~isnan(nbList(count,3))
        adjMat(count, nbList(count,3))=1;
    end
end
adjMat=adjMat-diag(diag(adjMat)); % remove the diagonal since a face is always connected to itself





% loop through each face, find connected faces, and add to object
for iFace_orig = 1:nFaces_orig
    
    % check lookup
    if iFaceAlreadyAdded(iFace_orig) % face was already added to object
        continue; % skip
    end
    
    % get vertices of new face
    vertices_i = Vertices_orig(Faces_orig(iFace_orig, :), :);
    nVertices_i = size(vertices_i, 1);
    
    % add face to new object
    nObjects = nObjects + 1; % add one object
    nVertices_current = size(objects(nObjects).Vertices, 1);
    objects(nObjects).Vertices(end+1:end+nVertices_i, :) = vertices_i; % add vertex
    objects(nObjects).Faces(end+1, :) = 1;
    iFaceAlreadyAdded(iFace_orig) = true(); % 
    
    % 
    for jFace_orig = iFace_orig+1:nFaces_orig
        if any(Faces_orig == Faces_orig(iFace_orig, :), 1)
            objects
        end
    end
end


end

