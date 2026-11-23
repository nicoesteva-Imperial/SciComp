# Part 1, panel a: deterministic vs stochastic population trajectories
#
# Log-scaled total population over 24 time steps (months), starting from
# 100 adults (red) and 10 adults (blue). Deterministic model = solid line,
# stochastic runs = dashed lines. Runs locally (no HPC needed).
#
# Run from the project root:  Rscript code/part1_panel_a.R
# Outputs:
#   results/part1_panel_a.rda  data (re-used later for the final 2-panel figure)
#   results/part1_panel_a.pdf  preview plot of panel a on its own

source("code/Demographic.R")            # model functions
source("code/demographic_parameters.R") # matrices, clutch distribution, state_initialise_adult()


# ---------------------------------------------------------------------------
# Settings (change here, nothing below needs editing)
# ---------------------------------------------------------------------------
initial_sizes     <- c(100, 10)          # number of adults at time 0
size_colours      <- c("red", "blue")    # one colour per initial size (brief: 100 red, 10 blue)
simulation_length <- 24                  # time steps (months)
n_stochastic      <- 5                   # stochastic runs per initial size ("several")
seed              <- 2026                # fixed seed, so the figure is reproducible


# ---------------------------------------------------------------------------
# Run the simulations
# ---------------------------------------------------------------------------
set.seed(seed)
panel_a <- list()   # one entry per initial size

for (size in initial_sizes) {
  initial_state <- state_initialise_adult(num_stages, size)

  # deterministic: one run (always the same answer); vector of length 25
  det <- deterministic_simulation(initial_state, projection_matrix, simulation_length)

  # stochastic: n_stochastic independent runs. replicate() puts each run in a
  # COLUMN, so stoch is a 25 x n_stochastic matrix (rows = time 0..24)
  stoch <- replicate(n_stochastic,
                     stochastic_simulation(initial_state, growth_matrix, reproduction_matrix,
                                           clutch_distribution, simulation_length))

  panel_a[[as.character(size)]] <- list(initial_size  = size,
                                        deterministic = det,
                                        stochastic    = stoch)
}

# quick sanity checks (stop with an error if something is off)
for (run in panel_a) {
  stopifnot(length(run$deterministic) == simulation_length + 1,
            all(dim(run$stochastic) == c(simulation_length + 1, n_stochastic)),
            run$deterministic[1] == run$initial_size,
            all(run$stochastic[1, ] == run$initial_size))
}


# ---------------------------------------------------------------------------
# Save the data
# ---------------------------------------------------------------------------
dir.create("results", showWarnings = FALSE)
save(panel_a, initial_sizes, size_colours, simulation_length, n_stochastic, seed,
     file = "results/part1_panel_a.rda")


# ---------------------------------------------------------------------------
# Plot preview of panel a on its own (plot function shared with part1_figure.R)
# ---------------------------------------------------------------------------
source("code/part1_plot_functions.R")

pdf("results/part1_panel_a.pdf", width = 7, height = 5)
plot_panel_a(panel_a, size_colours, simulation_length)
dev.off()

cat("Panel a: saved results/part1_panel_a.rda and results/part1_panel_a.pdf\n")
