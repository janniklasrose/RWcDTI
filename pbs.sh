#!/bin/bash
#- PBS directives go here -#
#PBS -l walltime=1:00:00
#PBS -l select=1:ncpus=20:mem=60gb
#...
NCPUS=20 # same as in the PBS -l directive!

#- Load the software -#
module load matlab/R2019b

#- Copy files to the local directory $TMPDIR -#
#...

#- Edit the config file or add an override file -#
sed -r -i "/num_cores/s/[0-9]+/${NCPUS}/g" config.yml
cat > config_extra.yml <<EOF
substrate:
  domain:
    voxel: [0, 1000, 0, 1000, 0, 1000]
EOF
# alternatively, use Python (with pyyaml) to create/edit a .yml file

#- Execute MATLAB -#
# optionally, use the `-logfile <FILE>`
matlab -noFigureWindows -batch "run_sim output.mat config.yml config_extra.yml"

#- Copy files back to $HOME -#
#...
