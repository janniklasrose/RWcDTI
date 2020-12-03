# Random Walk

## Compiling

The code is using MATLAB, but performance-critical functions have been written in C in the form of [MEX functions](https://uk.mathworks.com/help/matlab/call-mex-file-functions.html). They need to be compiled to be available at runtime. To do this, execute `compile.m` inside MATLAB.

## Running a simulation

To run a simulation, it is easiest to specify all parameters using a configuration file (using the [YAML](https://en.wikipedia.org/wiki/YAML) format). Example configuration files are provided in the `config/` directory.
