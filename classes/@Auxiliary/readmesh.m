function [Faces, Vertices] = readmesh(filepath, varargin)
%READMESH Writes triangulated mesh to file.
%   [Faces, Vertices] = readmesh(filepath)

extension = filepath(end-2:end); %TODO: get from path with . separated name

%%% run
switch lower(extension)
    case 'vtk'
        error('vtk files currently not supported');
    case 'stl'
        fn_read = @(fid) readstl(fid, varargin);
end

%%% open
fid = fopen(filepath, 'r');
if fid == -1
    error('could not open file');
end

%%% write (try-catch in case something goes wrong)
try
    [out] = fn_read(fid);
catch exception
    warning('something went wrong trying to read from file'); %TODO: include exception message
end

%%% close
fid = fclose(fid);
if fid == -1
    error('could not close file');
end

Faces = out.Faces;
Vertices = out.Vertices;

end

function [out] = readstl(fid, NameValuePairs)
% filepath := path to the file to be written
% Faces    := Mx3 matrix of triangle faces
% Vertices := Nx3 matrix of triangle vertices

% See more at https://en.wikipedia.org/wiki/STL_(file_format)

%TODO: does not support {'Name', 'Name', 'Value'} yet
TypeForFaces    = 'uint32';
TypeForVertices = 'single';
mergeVertices = false();
for i = 1:numel(NameValuePairs)
    if mod(i, 2) % odd
        Name = NameValuePairs{i};
        continue;
    else % even
        Value = NameValuePairs{i};
    end
    switch lower(Name)
        case 'faces'
            % verify that Value is a name of a datatype
            % warn if overflow can occur
            TypeForFaces = Value;
        case 'vertices'
            % verify that Value is a name of a datatype
            % warn if is not single/double
            TypeForVertices = Value;
        case 'merge'
            % verify that Value is boolean or 1/0 binary
            mergeVertices = Value;
        otherwise
            error('''Name'' must be char');
    end
end

%%% read
solidname = 'Mesh';
header = char(fread(fid, 80, 'char').'); % 80char header
nFacets = fread(fid, 1, 'uint32'); % size
Faces = zeros(3, nFacets, TypeForFaces);
Vertices = zeros(3, 3, nFacets, TypeForVertices);
for iFacet = 1:nFacets
    offset = 3*(iFacet-1);
    Faces(:, iFacet) = (1:3)+offset;
    % [ni; nj; nk; v1x; v1y; v1z; v2x; v2y; v2z; v3x; v3y; v3z]_f1, ...
    normal = fread(fid, 3, 'float32'); % ignore
    Vertices(:, 1, iFacet) = fread(fid, 3, 'float32');
    Vertices(:, 2, iFacet) = fread(fid, 3, 'float32');
    Vertices(:, 3, iFacet) = fread(fid, 3, 'float32');
    attrib = fread(fid, 1, 'uint16'); % ignore
end
Faces = Faces.';
Vertices = [Vertices(1:3:end).', Vertices(2:3:end).', Vertices(3:3:end).'];

%TODO: does not merge vertices yet
if mergeVertices
    %{
    Faces_uniq = Faces_orig;
    [Vertices_uniq, orig2uniq, uniq2orig] = unique(Vertices_orig, 'rows', 'stable');
    orig2uniq = uint32(orig2uniq);
    uniq2orig = uint32(uniq2orig);
    nVertices_uniq = size(Vertices_uniq, 1);
    for iVertex_orig = 1:nVertices_orig
        fprintf('%i/%i\n', iVertex_orig, nVertices_orig);
        Faces_uniq(Faces_orig == iVertex_orig) = uniq2orig(iVertex_orig);
    end
    nFaces_uniq = size(Faces_uniq, 1);
    %}
end

out.Faces = Faces;
out.Vertices = Vertices;

end
