# Random Walk for cardiac Diffusion Tensor Imaging

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4506756.svg)](https://doi.org/10.5281/zenodo.4506756)

## Compiling

The code is using MATLAB, but performance-critical functions have been written in C in the form of [MEX functions](https://uk.mathworks.com/help/matlab/call-mex-file-functions.html). They need to be compiled to be available at runtime. To do this, execute [compile.m](./compile.m) inside MATLAB.

## Running a simulation

To run a simulation, it is easiest to specify all parameters using a configuration file (using the [YAML](https://en.wikipedia.org/wiki/YAML) format). Example configuration files are provided in the [config](./config/) directory.

For small scale simulations with a low number of walkers, executing on a local machine (laptop/desktop) will be sufficient. If large scale jobs are desired, parallelisation is almost certainly required. The [pbs.sh](./pbs.sh) file should give an indication how to run these on the HPC cluster. For storing simulation data of significant size, it is best to use the more portable [HDF5 format](https://uk.mathworks.com/help/matlab/hdf5-files.html) which is generally faster than using compressed MAT files.

## Publication

### Citation

If this software is useful to you, please consider citing the [original paper](https://doi.org/10.1002/mrm.27561):

> Rose, JN, Nielles-Vallespin, S, Ferreira, P, Firmin, DN, Scott, AD, Doorly, DJ. Novel insights into in-vivo diffusion tensor cardiovascular magnetic resonance using computational modelling and a histology‐based virtual microstructure. Magn Reson Med. 2019; 81: 2759–2773. DOI:[10.1002/mrm.27561](https://doi.org/10.1002/mrm.27561)

The [tagged releases](https://github.com/janniklasrose/RWcDTI/releases) are archived on [Zenodo](https://doi.org/10.5281/zenodo.4506756).

### Dataset

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3925758.svg)](https://doi.org/10.5281/zenodo.3925758)

Simulation data (both input geometries and results) from the MRM paper is published [here](https://doi.org/10.5281/zenodo.3925758).
