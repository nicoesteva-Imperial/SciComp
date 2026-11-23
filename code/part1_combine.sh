#!/bin/bash
# Part 1, panel b: COMBINE step, run on the HPC after all 20 array jobs succeed
#
# Don't qsub this by hand. code/part1_submit.sh submits it with
#     qsub -W depend=afterok:<array job ID> code/part1_combine.sh
# so PBS holds it until EVERY job of part1_hpc.sh has finished without error.
# If any job fails, this job never starts (no half-finished results).
#
# What it does (one small job, single CPU):
#   1. moves the array jobs' .o/.e files into results/part1_hpc/logs/
#   2. Rscript code/part1_panel_b.R  -> results/part1_panel_b_summary.rda (+ preview pdf)
#   3. Rscript code/part1_figure.R   -> results/part1_figure.pdf
# Panel a is NOT run here: the brief says to make it locally. Its data
# (results/part1_panel_a.rda) comes from the git repository.

#PBS -N part1_combine
#PBS -l walltime=00:10:00
#PBS -l select=1:ncpus=1:mem=1gb

cd "$PBS_O_WORKDIR"      # project root (where part1_submit.sh was run)

# load R: use the same lines as in part1_hpc.sh
module load tools/prod
module load R

echo "Combine job starting on $(hostname) at $(date)"

# 1. tidy the array jobs' log files (all finished, so they all exist now)
mkdir -p results/part1_hpc/logs
mv part1_hpc.[oe]* results/part1_hpc/logs/ 2>/dev/null

# 2-3. analysis and figure; stop at the first error
set -e
Rscript code/part1_panel_b.R
Rscript code/part1_figure.R

echo "Combine job finished at $(date)"
