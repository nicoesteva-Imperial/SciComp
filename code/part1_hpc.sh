#!/bin/bash
# Part 1, panel b: PBS array job script for the Imperial HPC
#
# Submit FROM THE PROJECT ROOT on the cluster:
#     cd ~/SciComp          # wherever the repo was cloned on the HPC
#     qsub code/part1_hpc.sh
#
# Starts 20 copies of code/part1_hpc.R; copy i gets PBS_ARRAY_INDEX = i (1..20),
# which the R script uses as its seed. Each copy writes
# results/part1_hpc/part1_hpc_<i>.rda, and the cluster writes one .o (printed
# output) and one .e (errors) file per job into the submission folder.
#
# Resources: one job takes about 20 s locally (160 simulations), so
# 30 min walltime and 1 GB memory per job are plenty.

#PBS -N part1_hpc
#PBS -J 1-20
#PBS -l walltime=00:30:00
#PBS -l select=1:ncpus=1:mem=1gb

# go to the folder qsub was run from (the project root), so the R script's
# relative paths (code/..., results/...) work; no hard-coded paths
cd "$PBS_O_WORKDIR"

# load R. CHECK on the login node: run `module avail R` and, if needed,
# replace the line below with the exact version listed (e.g. module load R/4.x.x)
module load tools/prod
module load R

echo "Job $PBS_ARRAY_INDEX starting on $(hostname) at $(date)"
Rscript code/part1_hpc.R
echo "Job $PBS_ARRAY_INDEX finished at $(date)"
