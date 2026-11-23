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
# Plot (a function, so the final 2-panel figure script can call it too)
# ---------------------------------------------------------------------------
# Log scale: log(0) is undefined, so a population of 0 is drawn as missing (NA)
# and the line stops; an "x" marks the last non-zero point of an extinct run.
plot_panel_a <- function(panel_a, size_colours, simulation_length) {
  time   <- 0:simulation_length
  all_y  <- unlist(lapply(panel_a, function(r) c(r$deterministic, r$stochastic)))
  y_max  <- max(all_y) * 5   # headroom at the top for the legend, so it covers no data
  y_min  <- min(all_y[all_y > 0])

  plot(NA, xlim = c(0, simulation_length), ylim = c(y_min, y_max), log = "y",
       xlab = "Time (months)", ylab = "Total population size (log scale)",
       main = "Deterministic vs stochastic population growth", las = 1)

  any_extinct <- FALSE
  for (i in seq_along(panel_a)) {
    run <- panel_a[[i]]
    col <- size_colours[i]
    for (j in seq_len(ncol(run$stochastic))) {
      y <- run$stochastic[, j]
      y[y == 0] <- NA
      lines(time, y, col = adjustcolor(col, 0.6), lty = 2, lwd = 1.2)
      if (anyNA(y)) {                          # this run went extinct
        last <- max(which(!is.na(y)))
        points(time[last], y[last], pch = 4, col = col, lwd = 2)
        any_extinct <- TRUE
      }
    }
    lines(time, run$deterministic, col = col, lty = 1, lwd = 3)
  }

  sizes <- sapply(panel_a, `[[`, "initial_size")
  legend_text <- c(paste(sizes, "adults, deterministic"), paste(sizes, "adults, stochastic"))
  legend_col  <- rep(size_colours[seq_along(sizes)], 2)
  legend_lty  <- rep(c(1, 2), each = length(sizes))
  legend_lwd  <- rep(c(3, 1.2), each = length(sizes))
  legend_pch  <- rep(NA, 2 * length(sizes))
  if (any_extinct) {
    legend_text <- c(legend_text, "extinction"); legend_col <- c(legend_col, "black")
    legend_lty  <- c(legend_lty, NA); legend_lwd <- c(legend_lwd, 2); legend_pch <- c(legend_pch, 4)
  }
  legend("top", legend_text, col = legend_col, lty = legend_lty, lwd = legend_lwd,
         pch = legend_pch, bty = "n", cex = 0.85, ncol = 2)
}

pdf("results/part1_panel_a.pdf", width = 7, height = 5)
plot_panel_a(panel_a, size_colours, simulation_length)
dev.off()

cat("Panel a: saved results/part1_panel_a.rda and results/part1_panel_a.pdf\n")
