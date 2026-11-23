# Part 1: rebuild everything on the LAPTOP with one command
#
# Run from the project root:   Rscript code/part1_run_all.R
#   (or in RStudio with SCSE.Rproj open:  source("code/part1_run_all.R"))
#
# Needs the HPC results already in results/part1_hpc/ (see code/part1_submit.sh).
# Steps, in order (each script runs in a fresh R session and must succeed):
#   1. part1_panel_a.R   panel a simulations      -> results/part1_panel_a.rda
#   2. part1_panel_b.R   pool the 20 HPC files    -> results/part1_panel_b_summary.rda
#   3. part1_figure.R    draw the final figure    -> results/part1_figure.pdf

hpc_dir       <- "results/part1_hpc"
expected_jobs <- 20

# check the HPC output first, so a missing file gives a clear message
hpc_files <- list.files(hpc_dir, pattern = "^part1_hpc_[0-9]+\\.rda$")
if (length(hpc_files) != expected_jobs) {
  stop("Found ", length(hpc_files), " HPC result files in ", hpc_dir,
       ", expected ", expected_jobs, ".\n",
       "Run the HPC jobs first (bash code/part1_submit.sh on the HPC), then git pull.")
}

steps <- c("code/part1_panel_a.R", "code/part1_panel_b.R", "code/part1_figure.R")
for (script in steps) {
  cat("\n=== Running", script, "===\n")
  status <- system2("Rscript", script)
  if (status != 0) stop(script, " failed (exit status ", status, "); stopping.")
}

cat("\nPart 1 rebuilt. Final figure: results/part1_figure.pdf\n")
