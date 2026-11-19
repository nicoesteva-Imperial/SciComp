# Figures for notes/Part1_Demographic_model.md (study notes, not coursework output)
# Run from the project root:  Rscript notes/images/make_part1_figures.R

source("code/Demographic.R")
source("code/demographic_parameters.R")
out_dir <- "notes/images"
p_breed <- stochastic_recruitment(reproduction_matrix, clutch_distribution)  # 0.532


# ---------------------------------------------------------------------------
# 1. Life-cycle diagram: what the growth + reproduction matrices mean
# ---------------------------------------------------------------------------
png(file.path(out_dir, "part1_lifecycle.png"), width = 1600, height = 900, res = 150)
par(mar = c(0.5, 0.5, 2, 0.5))
plot(NA, xlim = c(0, 8), ylim = c(-2.1, 2.9), asp = 1, axes = FALSE, xlab = "", ylab = "",
     main = "Life cycle encoded by the matrices (1 time step = 1 month)")
xs <- c(1, 3, 5, 7); r <- 0.45
stay <- diag(growth_matrix)
move <- c(growth_matrix[2, 1], growth_matrix[3, 2], growth_matrix[4, 3])
die  <- 1 - colSums(growth_matrix)
th <- seq(0, 2 * pi, length.out = 100)
for (i in 1:4) {
  polygon(xs[i] + r * cos(th), r * sin(th), col = c("#cfe8ff", "#b3d9ff", "#8cc4ff", "#ffd59e")[i], border = "grey20", lwd = 2)
  text(xs[i], 0, c("Stage 1", "Stage 2", "Stage 3", "Adult")[i], font = 2)
  # self-loop below the node = stay
  a <- seq(120, 420, length.out = 60) * pi / 180
  lx <- xs[i] + 0.3 * cos(a); ly <- -0.78 + 0.3 * sin(a)
  lines(lx, ly, col = "grey30", lwd = 2)
  arrows(lx[59], ly[59], lx[60], ly[60], length = 0.08, col = "grey30", lwd = 2)
  text(xs[i], -1.3, paste0("stay ", stay[i]), col = "grey20")
  text(xs[i], -1.7, paste0("die ", round(die[i], 2)), col = "firebrick", font = 2)
}
for (i in 1:3) {  # maturation arrows
  arrows(xs[i] + r, 0, xs[i + 1] - r, 0, length = 0.1, lwd = 2, col = "steelblue4")
  text((xs[i] + xs[i + 1]) / 2, 0.22, paste0("move ", move[i]), col = "steelblue4", font = 2)
}
# reproduction arc from adults back to stage 1
t <- seq(0, 1, length.out = 100)
ax <- 7 - 6 * t; ay <- 0.48 + 1.45 * sin(pi * t)
lines(ax, ay, col = "darkorange3", lwd = 3)
arrows(ax[99], ay[99], ax[100], ay[100], length = 0.12, col = "darkorange3", lwd = 3)
text(4, 2.75, "reproduction: 2.6 babies per adult per month", col = "darkorange3", font = 2)
text(4, 2.3, sprintf("(stochastic: breed with prob. %.3f, then clutch of 1-9, mean 4.89)", p_breed),
     col = "darkorange3", cex = 0.85)
dev.off()


# ---------------------------------------------------------------------------
# 2. Clutch distribution and its mean (4.89)
# ---------------------------------------------------------------------------
png(file.path(out_dir, "part1_clutch.png"), width = 1400, height = 850, res = 150)
par(mar = c(4.5, 4.5, 3, 1))
mean_clutch <- sum(clutch_distribution * seq_along(clutch_distribution))
bp <- barplot(clutch_distribution, names.arg = 1:9, col = "#8cc4ff", border = "grey30",
              ylim = c(0, 0.22), xlab = "clutch size k (babies)", ylab = "probability P(k)",
              main = "Clutch distribution: mean = sum of k x P(k) = 4.89")
text(bp, clutch_distribution + 0.012, sprintf("%d x %.2f\n= %.2f", 1:9, clutch_distribution,
     1:9 * clutch_distribution), cex = 0.65)
# bar k is centred at bp[k]; map the mean 4.89 onto the bar axis
mean_x <- approx(1:9, bp, xout = mean_clutch)$y
# dashed line at the mean, with a gap so it doesn't cross the bar-5 label
segments(mean_x, c(0, 0.196), mean_x, c(0.161, 0.205), col = "darkorange3", lwd = 3, lty = 2)
text(mean_x, 0.212, "mean 4.89", col = "darkorange3", font = 2, pos = 2)
dev.off()


# ---------------------------------------------------------------------------
# 3. One month from 100 adults, repeated 5000 times: stochastic outcomes
#    scatter around the deterministic values (260 babies, 40 adults)
# ---------------------------------------------------------------------------
set.seed(1)
one_month <- t(replicate(5000, stochastic_step(c(0, 0, 0, 100), growth_matrix, reproduction_matrix,
                                               clutch_distribution, p_breed)))
png(file.path(out_dir, "part1_one_month.png"), width = 1600, height = 750, res = 150)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1))
hist(one_month[, 4], breaks = seq(min(one_month[, 4]) - 0.5, max(one_month[, 4]) + 0.5, 1),
     col = "#ffd59e", border = "white", main = "Surviving adults after 1 month\n(start: 100 adults)",
     xlab = "number of adults", ylab = "number of runs (of 5000)")
abline(v = 40, col = "black", lwd = 3)
legend("topright", c("deterministic: 0.4 x 100 = 40", sprintf("stochastic mean: %.1f", mean(one_month[, 4]))),
       lwd = c(3, NA), pch = c(NA, 15), col = c("black", "#ffd59e"), bty = "n", cex = 0.8)
hist(one_month[, 1], breaks = 40, col = "#8cc4ff", border = "white",
     main = "Babies born in 1 month\n(start: 100 adults)", xlab = "number of babies", ylab = "number of runs (of 5000)")
abline(v = 260, col = "black", lwd = 3)
legend("topright", c("deterministic: 2.6 x 100 = 260", sprintf("stochastic mean: %.1f", mean(one_month[, 1]))),
       lwd = c(3, NA), pch = c(NA, 15), col = c("black", "#8cc4ff"), bty = "n", cex = 0.8)
dev.off()


# ---------------------------------------------------------------------------
# 4. Many stochastic runs vs deterministic, small (3) vs large (100) start
# ---------------------------------------------------------------------------
months <- 60; n_runs <- 30
png(file.path(out_dir, "part1_trajectories.png"), width = 1700, height = 800, res = 150)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3.5, 1))
set.seed(2)
for (start in c(3, 100)) {
  det <- deterministic_simulation(c(0, 0, 0, start), projection_matrix, months)
  runs <- replicate(n_runs, stochastic_simulation(c(0, 0, 0, start), growth_matrix, reproduction_matrix,
                                                  clutch_distribution, months))
  n_extinct <- sum(runs[months + 1, ] == 0)
  plot(0:months, det, log = "y", type = "n", ylim = c(1, max(runs, det)), xlab = "time (months)",
       ylab = "total population (log scale)",
       main = sprintf("Start: %d adults  -  %d of %d runs went extinct", start, n_extinct, n_runs))
  for (j in 1:n_runs) {
    y <- runs[, j]; y[y == 0] <- NA
    lines(0:months, y, col = adjustcolor("steelblue", 0.45))
    if (runs[months + 1, j] == 0) {        # mark the extinction point
      last <- max(which(!is.na(y)))
      points(last - 1, y[last], pch = 4, col = "firebrick", lwd = 2)
    }
  }
  lines(0:months, det, lwd = 3)
  legend("topleft", c("deterministic", "stochastic runs", "extinction"), lwd = c(3, 1, 2),
         lty = c(1, 1, NA), pch = c(NA, NA, 4), col = c("black", "steelblue", "firebrick"), bty = "n", cex = 0.8)
}
dev.off()

cat("Figures written to", out_dir, "\n")
