%>> setenv('MW_MINGW64_LOC', 'C:\mingw-w64\x86_64-7.2.0-posix-seh-rt_v5-rev1\mingw64')
% http://uk.mathworks.com/help/matlab/matlab_external/upgrading-mex-files-to-use-64-bit-api.html

mex('-setup', 'C++')

Auxiliary.MAKE
ParticleWalker.MAKE
Geometry.Polygon.MAKE
Geometry.Polyhedron.MAKE
