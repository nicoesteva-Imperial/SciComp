#!/bin/bash
# Part 1, panel b: submit the WHOLE HPC pipeline with one command
#
# Run on the HPC login node, FROM THE PROJECT ROOT:
#     cd ~/SciComp
#     git pull
#     bash code/part1_submit.sh
#
# What it does:
#   1. qsub code/part1_hpc.sh       -> 20 simulation jobs (array job)
#   2. qsub code/part1_combine.sh   -> 1 job that WAITS (depend=afterok) until
#                                      all 20 have succeeded, then pools them
#                                      and makes the figure
#
#   part1_hpc.sh [1..20] ──all finished OK──► part1_combine.sh
#
# Afterwards (check with: qstat -u $USER -t):
#     git add results/ && git commit -m "Part 1 HPC results (job <ID>)" && git push
#
# Template for later parts (e.g. Part 3): copy the three files part<N>_submit.sh,
# part<N>_hpc.sh, part<N>_combine.sh and change the names below.

set -e   # stop at the first error

array_script="code/part1_hpc.sh"
combine_script="code/part1_combine.sh"
log_dir="results/part1_hpc/logs"

# safety checks: on the HPC, in the project root
if ! command -v qsub > /dev/null; then
  echo "ERROR: qsub not found. Run this on the HPC login node, not on the laptop." >&2
  exit 1
fi
if [ ! -f "$array_script" ] || [ ! -f "$combine_script" ]; then
  echo "ERROR: run this from the project root (cd ~/SciComp)." >&2
  exit 1
fi

mkdir -p "$log_dir"

# 1. simulation jobs; qsub prints the job ID, e.g. 3055970[].pbs-8
array_id=$(qsub "$array_script")
echo "Submitted simulations:  $array_id"

# 2. combine job, held until every array job finishes with exit status 0.
#    Its own .o/.e files go straight into the logs folder.
combine_id=$(qsub -W depend=afterok:"$array_id" \
                  -o "$PWD/$log_dir/part1_combine.o" \
                  -e "$PWD/$log_dir/part1_combine.e" \
                  "$combine_script")
echo "Submitted combine step: $combine_id  (waits for $array_id)"

echo
echo "Check progress with:  qstat -u $USER -t"
echo "The combine job shows status H (held) until the simulations are done."
