function [] = writemesh(filepath, Faces, Vertices)
%WRITEMESH Writes triangulated mesh to file.
%   writemesh(filename, flag_BINARY, Faces, Vertices)

%%% verify input
%{
if max(all_faces(:)) > size(all_vertices, 1)
    error('missing vertices');
elseif max(all_faces(:)) < size(all_vertices, 1)
    warning('unnecessary vertices');
else
    % efficient storage, OK!
end
%}

[fPath, fName, fExtn] = fileparts(filepath);

%%% run
switch lower(fExtn)
    case '.vtk'
        fn_write = @(fid) writevtk(fid, Faces, Vertices);
        endian = {'ieee-be'}; % VTK requires big endian
    case '.stl'
        fn_write = @(fid) writestl(fid, Faces, Vertices);
        endian = {}; % default ok
    otherwise
        if isempty(fExtn)
            % no extension specified, I don't want to assume
        end
        % unknown extension specified
end

%%% open
fid = fopen(filepath, 'W', endian{:});
if fid == -1
    error('could not open file');
end

%%% write (try-catch in case something goes wrong)
try
    fn_write(fid);
catch exception
    warning('something went wrong trying to write the file'); %TODO: include exception message
end

%%% close
fid = fclose(fid);
if fid == -1
    error('could not close file');
end

end

function [] = writevtk(fid, Faces, Vertices)
% filepath := path to the file to be written
% Faces    := Mx3 matrix of triangle faces
% Vertices := Nx3 matrix of triangle vertices

% See more at http://www.vtk.org/wp-content/uploads/2015/04/file-formats.pdf

writeAscii = @(fid, str) [fprintf(fid, str); fprintf(fid, '\n')];
writeBinary = @(fid, dat, prec) [fwrite(fid, dat, prec); fprintf(fid, '\n')];

%%% pre-process data
Faces = Faces - 1; % 0-based indexing
nFaces = size(Faces, 1);
nVertices = size(Vertices, 1);

%%% write
fprintf(fid, '# vtk DataFile Version 2.0\n'); % File version
fprintf(fid, 'writemesh:writevtk in MATLAB\n'); % Header
fprintf(fid, 'BINARY\n\n'); % Format %TODO: extra \n for BINARY ???

DATASET = 'POLYDATA';
validatestring(DATASET, {'POLYDATA'});
fprintf(fid, 'DATASET %s\n', DATASET); % Geometry/Topology

DATATYPE = 'double';
validatestring(DATATYPE, {'bit', 'unsigned_char', 'char', 'unsigned_short', 'short', 'unsigned_int', 'int', 'unsigned_long', 'long', 'float', 'double'});
fprintf(fid, 'POINTS %d %s\n', nVertices, DATATYPE); %TODO: double or float?

Vertices = Vertices.';
fwrite(fid, Vertices, 'double'); %TODO: double or float?
fprintf(fid, '\n');
fprintf(fid, '\n'); % blank line
fprintf(fid,'POLYGONS %d %d\n', nFaces, (3+1)*nFaces);
Faces = Faces.'; Faces(2:4, :) = Faces; Faces(1, :) = 3;
fwrite(fid, Faces, 'int'); %TODO: uint, ulong?
fprintf(fid, '\n');

end

function [] = writestl(fid, Faces, Vertices)
% filepath := path to the file to be written
% Faces    := Mx3 matrix of triangle faces
% Vertices := Nx3 matrix of triangle vertices

% See more at https://en.wikipedia.org/wiki/STL_(file_format)
% Done with help from: https://uk.mathworks.com/matlabcentral/fileexchange/20922

%%% pre-process data
Vertices = single(Vertices); % STL only supports single precision data
v1 = Vertices(Faces(:, 1), :); % Mx3 matrix of v1 coordinates
v2 = Vertices(Faces(:, 2), :); % Mx3 matrix of v2 coordinates
v3 = Vertices(Faces(:, 3), :); % Mx3 matrix of v3 coordinates
n = cross(v2 - v1, v3 - v1, 2); %TODO: normalise and verify right-hand rule
facets = [n, v1, v2, v3].'; % [ni; nj; nk; v1x; v1y; v1z; v2x; v2y; v2z; v3x; v3y; v3z]_f1, ...

%%% write
solidname = 'Mesh';
header = ['solid ', solidname];
fwrite(fid, [header, repmat(' ', 1, 80-numel(header)-1), newline()], 'uint8'); % 80char header
fwrite(fid, size(facets, 2), 'uint32'); % size

% we need to write 12 float32 and then one uint16, that is super slow.
% instead, we will typecast our float32 data into uint16 (twice as many data) and write in one command
%{
for facet = facets
    fwrite(fid, facet, 'float32'); % data
    fwrite(fid, 0, 'uint16'); % attribute
end
%}
facets = reshape(typecast(facets(:), 'uint16'), size(facets, 1)*2, []);
facets(end+1, :) = 0; % attribute
fwrite(fid, facets, 'uint16');

end
