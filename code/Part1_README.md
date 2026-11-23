# Part 1: what each script does

All scripts are run **from the project root** (`SCSE/`), for example `Rscript code/part1_figure.R`, or in RStudio with `SCSE.Rproj` open.

## Quick start

| I want to… | Run | Where |
|---|---|---|
| Rebuild the final figure from the saved results | `Rscript code/part1_run_all.R` | Laptop |
| Rerun the HPC simulations | `bash code/part1_submit.sh` | HPC, in `~/SciComp` |
| Check the model works | `Rscript code/test_demographic.R` | Laptop |

## Order the scripts run in

```
 Demographic.R + demographic_parameters.R      (model + parameters, used by everything below)
        │
        ├── part1_panel_a.R ───────────────────────► results/part1_panel_a.rda
        │
        └── part1_hpc.sh → part1_hpc.R  (HPC ×20) ──► results/part1_hpc/part1_hpc_<i>.rda
                                                          │
                              part1_panel_b.R ◄──────────┘
                                    │
                                    ▼
                         results/part1_panel_b_summary.rda
                                    │
 part1_figure.R ◄───────────────────┴──── (+ part1_panel_a.rda)
        │
        ▼
 results/part1_figure.pdf     ← the figure for the report
```

## Model

| File | What it does |
|---|---|
| `code/Demographic.R` | The model, provided by the course (bugs fixed, see diary 17/11 and 19/11). Functions for the **deterministic** model (`deterministic_step`, `deterministic_simulation`: matrix × state each month) and the **stochastic** model (`multinomial`, `survival_maturation`, `random_draw`, `stochastic_recruitment`, `offspring_calc`, `stochastic_step`, `stochastic_simulation`: random survival, maturation and clutches) |
| `code/demographic_parameters.R` | Default parameters: the growth, reproduction and projection matrices (4 life stages, monthly steps), the clutch-size distribution, and `state_initialise_adult()`, which puts all individuals in the adult stage |
| `code/test_demographic.R` | 10 unit tests (testthat) checking the parameters, the deterministic maths, that the stochastic functions never create individuals, reproducibility with a seed, that extinction is permanent, and that the stochastic mean ≈ the deterministic model |

## Panel a (runs on the laptop)

| File | What it does |
|---|---|
| `code/part1_panel_a.R` | Simulates 24 months from 100 adults (red) and 10 adults (blue): 1 deterministic run and 5 stochastic runs each (seed 2026). Saves `results/part1_panel_a.rda` and a preview `results/part1_panel_a.pdf` |

## Panel b (simulations on the HPC)

| File | What it does |
|---|---|
| `code/part1_submit.sh` | **Run on the HPC with `bash`.** Submits `part1_hpc.sh` (20 jobs), then `part1_combine.sh`, which PBS holds (`afterok`) until all 20 have succeeded |
| `code/part1_hpc.sh` | PBS job script: starts 20 copies (`#PBS -J 1-20`) of `part1_hpc.R`, each with 1 CPU, 1 GB and up to 30 min |
| `code/part1_hpc.R` | One job: uses its job number (1–20) as the seed, runs 40 stochastic simulations × 120 months for each initial size (3, 10, 30, 100 adults), and saves which runs went extinct to `results/part1_hpc/part1_hpc_<i>.rda`. Run on the laptop, it does a test run into `sandbox/part1_hpc_test/` |
| `code/part1_combine.sh` | PBS follow-up job: moves the `.o`/`.e` logs into `results/part1_hpc/logs/`, then runs `part1_panel_b.R` and `part1_figure.R` on the HPC |
| `code/part1_panel_b.R` | Pools the 20 HPC files (800 runs per size) and calculates P(extinction) with exact 95% binomial confidence intervals. Saves `results/part1_panel_b_summary.rda` and a preview `results/part1_panel_b.pdf`. Optional argument: a different input folder, for example `sandbox/part1_hpc_test` |

## Final figure

| File | What it does |
|---|---|
| `code/part1_plot_functions.R` | Plotting functions only: `plot_panel_a()`, `plot_panel_b()` and `panel_label()` (the bold a/b). Shared by the panel scripts and the figure script, so all of them draw identical panels |
| `code/part1_figure.R` | Loads the two saved data files and draws panels a and b side by side → `results/part1_figure.pdf`. Recomputes nothing, so it takes about 1 s |
| `code/part1_run_all.R` | Laptop pipeline: checks that the 20 HPC files exist, then runs `part1_panel_a.R` → `part1_panel_b.R` → `part1_figure.R`, stopping at the first error |

## Outputs

| File | Contents |
|---|---|
| `results/part1_figure.pdf` | **Final two-panel figure for the report** |
| `results/part1_panel_a.rda` / `.pdf` | Panel a data / preview |
| `results/part1_hpc/part1_hpc_1.rda` … `_20.rda` | Raw HPC output: an `extinct` table (4 sizes × 40 runs) per job, plus its seed and run time |
| `results/part1_hpc/logs/` | `.o` (printed output) and `.e` (errors) for each HPC job, kept as proof of the HPC run (job 3055970) |
| `results/part1_panel_b_summary.rda` / `part1_panel_b.pdf` | Panel b's 4 data points with CIs / preview |
| `sandbox/part1_hpc_test/` | Local test runs only, **not** used in the report |

## Other

| File | What it does |
|---|---|
| `notes/images/make_part1_figures.R` | Makes the explanatory figures in `notes/Part1_Demographic_model.md` (study notes, not part of the coursework figure) |
| `notes/Part1_HPC_workflow.md` | How the HPC run works: SSH, git, `qsub`, `sftp`, reproducibility, troubleshooting |
