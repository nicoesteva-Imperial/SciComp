# Part 1, panel b: probability of extinction vs initial population size
#
# Reads the RDA files written by the HPC jobs (code/part1_hpc.R), pools all
# simulations, and computes P(extinction after 120 steps) for each initial size.
#
# Run from the project root (locally, after copying the HPC results back):
#     Rscript code/part1_panel_b.R
# To test on the local test files instead:
#     Rscript code/part1_panel_b.R sandbox/part1_hpc_test
#
# Outputs:
#   results/part1_panel_b_summary.rda  (test run: in the test folder) the 4 data points (+ confidence intervals);
#                                      small, so the figure can be remade without the HPC
#   results/part1_panel_b.pdf          preview plot of panel b on its own


# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------
args          <- commandArgs(trailingOnly = TRUE)
input_dir     <- if (length(args) > 0) args[1] else "results/part1_hpc"
# real run -> results/ ; test run -> next to the test files, so test output is
# never mistaken for the real HPC results
output_dir    <- if (length(args) > 0) input_dir else "results"
expected_jobs <- 20   # from the brief; a warning is given if files are missing


# ---------------------------------------------------------------------------
# Read and pool all job files
# ---------------------------------------------------------------------------
files <- list.files(input_dir, pattern = "^part1_hpc_[0-9]+\\.rda$", full.names = TRUE)
if (length(files) == 0) stop("No part1_hpc_<i>.rda files found in ", input_dir)
if (length(files) != expected_jobs) {
  warning("Found ", length(files), " job files, expected ", expected_jobs)
}

all_extinct <- NULL   # will become: rows = initial sizes, columns = ALL simulations
seeds_used  <- c()
for (f in files) {
  job <- new.env()           # load into its own environment, so files can't
  load(f, envir = job)       # overwrite each other's (or this script's) variables
  all_extinct <- cbind(all_extinct, job$extinct)
  seeds_used  <- c(seeds_used, job$seed)
}
if (anyDuplicated(seeds_used)) stop("Two job files used the same seed: ", seeds_used)

initial_sizes <- as.numeric(rownames(all_extinct))


# ---------------------------------------------------------------------------
# P(extinction) and 95% confidence interval for each initial size
# ---------------------------------------------------------------------------
# Each simulation is a yes/no outcome, so the number extinct is binomial.
# binom.test() gives the exact (Clopper-Pearson) 95% CI for the proportion,
# which still works when 0 runs went extinct (CI = 0 to a small upper value).
n_runs    <- ncol(all_extinct)
n_extinct <- rowSums(all_extinct)
ci        <- sapply(n_extinct, function(x) binom.test(x, n_runs)$conf.int)

panel_b <- data.frame(initial_size = initial_sizes,
                      n_runs       = n_runs,
                      n_extinct    = n_extinct,
                      p_extinct    = n_extinct / n_runs,
                      ci_lower     = ci[1, ],
                      ci_upper     = ci[2, ],
                      row.names    = NULL)
print(panel_b)

dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
save(panel_b, seeds_used, file = file.path(output_dir, "part1_panel_b_summary.rda"))


# ---------------------------------------------------------------------------
# Plot (a function, so the final 2-panel figure script can call it too)
# ---------------------------------------------------------------------------
plot_panel_b <- function(panel_b) {
  plot(panel_b$initial_size, panel_b$p_extinct, log = "x", ylim = c(0, 1),
       xaxt = "n", pch = 19, cex = 1.3, las = 1,
       xlab = "Initial population size (adults, log scale)",
       ylab = "Probability of extinction (after 120 months)",
       main = "Extinction risk falls with initial population size")
  axis(1, at = panel_b$initial_size)                       # ticks at 3, 10, 30, 100
  arrows(panel_b$initial_size, panel_b$ci_lower, panel_b$initial_size, panel_b$ci_upper,
         angle = 90, code = 3, length = 0.05)               # 95% CI error bars
  lines(panel_b$initial_size, panel_b$p_extinct, lty = 3)
  text(panel_b$initial_size, panel_b$ci_upper, sprintf("%.3f", panel_b$p_extinct),
       pos = 3, cex = 0.8)
  legend("topright", c("proportion of runs extinct", "95% confidence interval"),
         pch = c(19, NA), lty = c(NA, 1), bty = "n", cex = 0.85)
  mtext(sprintf("%d stochastic simulations per initial size", panel_b$n_runs[1]),
        side = 3, line = 0.2, cex = 0.8)
}

pdf(file.path(output_dir, "part1_panel_b.pdf"), width = 7, height = 5)
plot_panel_b(panel_b)
dev.off()

cat("Panel b: saved part1_panel_b_summary.rda and part1_panel_b.pdf in", output_dir, "\n")
