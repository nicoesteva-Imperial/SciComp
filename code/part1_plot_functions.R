# Part 1: plotting functions for panel a and panel b
#
# Shared by part1_panel_a.R, part1_panel_b.R (single-panel previews) and
# part1_figure.R (final two-panel figure), so all three draw identical panels.
# Each panel has a title; panel b also shows the number of simulations per size.


# ---------------------------------------------------------------------------
# Panel a: deterministic vs stochastic time series (log y axis)
# ---------------------------------------------------------------------------
# Log scale: log(0) is undefined, so a population of 0 is drawn as missing (NA)
# and the line stops; an "x" marks the last non-zero point of an extinct run.
plot_panel_a <- function(panel_a, size_colours, simulation_length) {
  time   <- 0:simulation_length
  all_y  <- unlist(lapply(panel_a, function(r) c(r$deterministic, r$stochastic)))
  y_max  <- max(all_y) * 5   # headroom at the top for the legend, so it covers no data
  y_min  <- min(all_y[all_y > 0])

  plot(NA, xlim = c(0, simulation_length), ylim = c(y_min, y_max), log = "y",
       xlab = "Time (months)", ylab = "Total population size (log scale)", las = 1,
       main = "Deterministic vs stochastic population growth", cex.main = 1.05)

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
         pch = legend_pch, bty = "n", cex = 0.8, ncol = 2,
         seg.len = 1.8, x.intersp = 0.6, text.width = 10.5)   # column width in months (x units)
}


# ---------------------------------------------------------------------------
# Panel b: probability of extinction vs initial population size
# ---------------------------------------------------------------------------
plot_panel_b <- function(panel_b) {
  # widen the x range a little (log axis, so multiply) so the value labels
  # above the first and last points are not cut off by the plot border
  x_range <- range(panel_b$initial_size) * c(0.75, 1.35)
  plot(panel_b$initial_size, panel_b$p_extinct, log = "x", ylim = c(0, 1), xlim = x_range,
       xaxt = "n", pch = 19, cex = 1.3, las = 1,
       xlab = "Initial population size (adults, log scale)",
       ylab = "Probability of extinction (after 120 months)",
       main = "Extinction risk falls with initial population size", cex.main = 1.05)
  axis(1, at = panel_b$initial_size)                       # ticks at 3, 10, 30, 100
  arrows(panel_b$initial_size, panel_b$ci_lower, panel_b$initial_size, panel_b$ci_upper,
         angle = 90, code = 3, length = 0.05)               # 95% CI error bars
  lines(panel_b$initial_size, panel_b$p_extinct, lty = 3)
  text(panel_b$initial_size, panel_b$ci_upper, sprintf("%.3f", panel_b$p_extinct),
       pos = 3, cex = 0.8)
  legend("topright", c("proportion of runs extinct", "95% confidence interval"),
         pch = c(19, NA), lty = c(NA, 1), bty = "n", cex = 0.8)
  mtext(sprintf("%d stochastic simulations per initial size", panel_b$n_runs[1]),
        side = 3, line = 0.2, cex = 0.8)
}


# ---------------------------------------------------------------------------
# Panel letter ("a", "b") in the top-left corner, outside the plot area
# ---------------------------------------------------------------------------
# grconvertX/Y convert "fraction of this panel's figure region" to plot
# coordinates, so the letter lands in the same spot on linear and log axes.
panel_label <- function(letter) {
  text(grconvertX(0.02, from = "nfc", to = "user"),
       grconvertY(0.96, from = "nfc", to = "user"),
       letter, font = 2, cex = 1.4, xpd = NA)
}
