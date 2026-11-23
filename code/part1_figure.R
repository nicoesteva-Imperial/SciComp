# Part 1: final two-panel figure (panel a and panel b side by side, one PDF)
#
# Uses the saved data only, so no simulations are rerun and no HPC is needed:
#   results/part1_panel_a.rda          made by code/part1_panel_a.R
#   results/part1_panel_b_summary.rda  made by code/part1_panel_b.R
#
# Run from the project root:  Rscript code/part1_figure.R
# Output:  results/part1_figure.pdf

source("code/part1_plot_functions.R")

load("results/part1_panel_a.rda")           # panel_a, size_colours, simulation_length, ...
load("results/part1_panel_b_summary.rda")   # panel_b

pdf("results/part1_figure.pdf", width = 11, height = 4.8)
par(mfrow = c(1, 2), mar = c(4.5, 4.8, 3.5, 1))   # 1 row, 2 plots; room for titles + a/b labels

plot_panel_a(panel_a, size_colours, simulation_length)
panel_label("a")

plot_panel_b(panel_b)
panel_label("b")

dev.off()
cat("Saved results/part1_figure.pdf\n")
