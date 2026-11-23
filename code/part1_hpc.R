# Part 1, panel b: extinction simulations, ONE cluster job
#
# Each HPC array job runs this script once. The job number PBS_ARRAY_INDEX
# (1..20) is used as the random seed, so every job uses different random
# numbers, and any job can be re-run to get exactly the same result.
#
# Per job: 40 stochastic simulations of 120 time steps for EACH initial size
# (3, 10, 30, 100 adults). A simulation counts as extinct if the population is
# 0 at the final step. Total over 20 jobs = 800 simulations per initial size.
#
# On the cluster:  submitted by code/part1_hpc.sh (working dir = project root)
#   -> saves results/part1_hpc/part1_hpc_<i>.rda
# Local test:      Rscript code/part1_hpc.R            (no PBS_ARRAY_INDEX set)
#   -> uses i = 1 and saves to sandbox/part1_hpc_test/, so test output
#      never mixes with the real cluster results.
#   To test another job number locally:  PBS_ARRAY_INDEX=2 Rscript code/part1_hpc.R
#   (that writes to results/, like a real job; delete it afterwards)

start_time <- proc.time()[["elapsed"]]   # timer (lecture 1: build one in)

source("code/Demographic.R")
source("code/demographic_parameters.R")


# ---------------------------------------------------------------------------
# Settings (from the coursework brief)
# ---------------------------------------------------------------------------
initial_sizes     <- c(3, 10, 30, 100)  # adults at time 0
n_simulations     <- 40                 # simulations per initial size, per job
simulation_length <- 120                # time steps before extinction is assessed


# ---------------------------------------------------------------------------
# Job number -> seed and output location
# ---------------------------------------------------------------------------
job_index <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))   # NA if not on the cluster

if (is.na(job_index)) {
  job_index  <- 1
  output_dir <- "sandbox/part1_hpc_test"
  cat("PBS_ARRAY_INDEX not set: LOCAL TEST with job_index = 1\n")
} else {
  output_dir <- "results/part1_hpc"
}
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

seed <- job_index
set.seed(seed)


# ---------------------------------------------------------------------------
# Simulations
# ---------------------------------------------------------------------------
# extinct: a table with one ROW per initial size and one COLUMN per simulation;
# each entry is TRUE if that simulation went extinct within 120 steps.
extinct <- matrix(NA, nrow = length(initial_sizes), ncol = n_simulations,
                  dimnames = list(initial_size = initial_sizes, simulation = 1:n_simulations))

for (s in seq_along(initial_sizes)) {
  initial_state <- state_initialise_adult(num_stages, initial_sizes[s])
  for (k in 1:n_simulations) {
    population <- stochastic_simulation(initial_state, growth_matrix, reproduction_matrix,
                                        clutch_distribution, simulation_length)
    # last value = population after 120 steps (stays 0 once extinct)
    extinct[s, k] <- population[simulation_length + 1] == 0
  }
}

run_time <- proc.time()[["elapsed"]] - start_time


# ---------------------------------------------------------------------------
# Save (only the summary needed for panel b, so files stay tiny)
# ---------------------------------------------------------------------------
output_file <- file.path(output_dir, paste0("part1_hpc_", job_index, ".rda"))
save(extinct, initial_sizes, n_simulations, simulation_length, job_index, seed, run_time,
     file = output_file)

# printed text goes to the job's .o file on the cluster (proof the job ran)
cat("Job", job_index, "| seed", seed, "| run time", round(run_time, 1), "s\n")
cat("Extinctions out of", n_simulations, "per initial size:\n")
print(rowSums(extinct))
cat("Saved", output_file, "\n")
