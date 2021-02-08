# Random Walk for cardiac Diffusion Tensor Imaging

## Compiling

The code is using MATLAB, but performance-critical functions have been written in C in the form of [MEX functions](https://uk.mathworks.com/help/matlab/call-mex-file-functions.html). They need to be compiled to be available at runtime. To do this, execute [compile.m](./compile.m) inside MATLAB.

## Running a simulation

To run a simulation, it is easiest to specify all parameters using a configuration file (using the [YAML](https://en.wikipedia.org/wiki/YAML) format). Example configuration files are provided in the [config](./config/) directory.

For small scale simulations with a low number of walkers, executing on a local machine (laptop/desktop) will be sufficient. If large scale jobs are desired, parallelisation is almost certainly required. The [pbs.sh](./pbs.sh) file should give an indication how to run these on the HPC cluster. For storing simulation data of significant size, it is best to use the more portable [HDF5 format](https://uk.mathworks.com/help/matlab/hdf5-files.html) which is generally faster than using compressed MAT files.
