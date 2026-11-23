# Scientific Computing and Simulation for Ecology and Evolution

Coursework repository for the 2026 Scientific Computing in Ecology & Evolution module (Imperial College London).

## Structure
- `code/` – R scripts (run with the project root as the working directory)
- `results/` – generated figures and output files
- `sandbox/` – scratch/testing area
- `notes/` – lecture notes

## Part 1 code at a glance
Full description of every script and output: [`code/Part1_README.md`](code/Part1_README.md). HPC how-to: [`notes/Part1_HPC_workflow.md`](notes/Part1_HPC_workflow.md).

**Rebuild the Part 1 figure** (laptop, from the project root): `Rscript code/part1_run_all.R` → `results/part1_figure.pdf`

| Script | What it does |
|---|---|
| `code/Demographic.R` | Deterministic and stochastic model functions (provided, bugs fixed) |
| `code/demographic_parameters.R` | Default matrices, clutch distribution, `state_initialise_adult()` |
| `code/test_demographic.R` | 10 unit tests for the model |
| `code/part1_panel_a.R` | Panel a: 24-month runs from 100 and 10 adults → `results/part1_panel_a.rda` |
| `code/part1_submit.sh` | HPC: submits the 20 simulation jobs + the combine job (`bash`, on the HPC) |
| `code/part1_hpc.sh` | PBS array job script (20 jobs) |
| `code/part1_hpc.R` | One HPC job: seed = job number, 40 sims × 4 sizes × 120 months → `results/part1_hpc/part1_hpc_<i>.rda` |
| `code/part1_combine.sh` | PBS job run after all 20 succeed: tidies logs, runs panel b and the figure |
| `code/part1_panel_b.R` | Pools the 20 HPC files → P(extinction) + 95% CI → `results/part1_panel_b_summary.rda` |
| `code/part1_plot_functions.R` | Shared plotting functions for panels a and b |
| `code/part1_figure.R` | Final two-panel figure → `results/part1_figure.pdf` |
| `code/part1_run_all.R` | Runs panel a → panel b → figure in order (laptop) |

## Coursework overview
| Part | Task | Report | HPC? |
|---|---|---|---|
| 1 | Stochastic vs deterministic demographic population model | 1 two-panel figure, 100-word caption, ≤150 words | Yes (panel b) |
| 2 | Neutral model of an ecological community (own code, runs in ≤1 min) | 1 two-panel figure, 100-word caption, ≤150 words | No |
| 3 | Microproject: individual-based model of community assembly | ≤1000 words, conceptual diagram + multi-panel figure | Yes |

## Three-week plan
Timetabled sessions are from the module schedule; targets are my own plan and will be revised (changes are explained in the diary).

### Week 8 (16–20 Nov) – Part 1
| Date | Sessions | Target |
|---|---|---|
| Mon 16/11 | Lectures: introduction, matrix population models; distributed computing; coding skills | Set up repo, lecture notes, read `Demographic.R` |
| Tue 17/11 | – | First diary entry, find default parameters, fix bugs in `Demographic.R` |
| Wed 18/11 | Drop-in; lectures: applications of matrix models, neutral theory | Tests for the model; panel a (local run) |
| Thu 19/11 | Drop-in; lecture: applications of neutral theory; lab | Panel b script tested locally (seeds, RDA output) |
| Fri 20/11 | – | Submit Part 1 HPC array job (20 jobs × 40 sims per size) |

### Week 9 (23–27 Nov) – Part 1 finish, Part 2, Part 3 idea
| Date | Sessions | Target |
|---|---|---|
| Mon 23/11 | Drop-in; lecture: microproject intro; lab; project ideas brainstorm | Analyse HPC results, panel b; start Part 2 functions |
| Tue 24/11 | – | Part 2: neutral step / generation / octave functions + tests |
| Wed 25/11 | – | Part 2 figure, check it runs in <1 min with varied parameters |
| Thu 26/11 | Drop-in; lecture: coalescence; peer feedback | Part 3 literature review and question; Part 2 stretch (coalescence)? |
| Fri 27/11 | Drop-in; lecture: database and web app; lab | Part 3 model design + conceptual diagram |

### Week 10 (30 Nov – 4 Dec) – Part 3 and write-up
| Date | Sessions | Target |
|---|---|---|
| Mon 30/11 | Drop-in; peer feedback; lab | Part 3 model coded and tested locally |
| Tue 01/12 | – | Part 3 HPC runs |
| Wed 02/12 | – | Analyse Part 3, plan next iteration |
| Thu 03/12 | Lab | Part 3 figure; write report |
| Fri 04/12 | Lab | Final checks (repo runs from root, .e/.o files pushed, PDF submitted) |

## Development diary
Entries are added in chronological order and pushed immediately; earlier entries are never edited (changes of view get a new entry).

### 2026-11-17 11:15 – Getting started with Part 1

**What I did so far.** Yesterday (16/11) I attended the introduction and matrix population model lectures, set up this repository and wrote lecture notes (`notes/`). I read through the provided `code/Demographic.R` to understand how the model works.

**How the model works.** The population is split into life stages; in every matrix, columns are the current stage and rows the next stage. The deterministic model multiplies the state vector by the projection matrix each step. The stochastic model splits the projection matrix into a growth matrix (survival/maturation, applied with a multinomial draw per stage, death = 1 − column sum) and a reproduction matrix (each adult reproduces with probability *rate / mean clutch size*, then a clutch size is drawn from a clutch distribution). This keeps the stochastic mean equal to the deterministic model.

**Problems found in the code.**
- `survival_maturation()` calls `sum_vect()`, which is not defined, so the stochastic model crashes.
- `multinomial()` uses `rmultinom(n = 11, ...)` but only uses the first draw (`n = 1` is enough, and extra draws waste random numbers).
- `multinomial()` only prints a warning if probabilities sum to >1 instead of stopping.
- The final `if` block in `stochastic_simulation()` does nothing.
- No default parameters (projection/growth/reproduction matrices, clutch distribution) are in the file.

**Plan.**
1. Find the default parameters for the provided code.
2. Fix the bugs above and write tests: deterministic step matches a hand-calculated matrix multiplication; `multinomial()` returns whole numbers summing to ≤ the pool; fixed seed gives identical stochastic output; the mean of many stochastic runs is close to the deterministic run.
3. Panel a locally: 24 steps, 100 vs 10 adults, deterministic (solid) and stochastic (dashed) on a log scale.
4. Panel b: a script using `PBS_ARRAY_INDEX` as the seed, running 40 simulations per initial size (3, 10, 30, 100) for 120 steps, saving to RDA. Test locally before HPC.

**Predictions.**
- Stochastic runs will scatter around the deterministic line, with more relative spread for 10 adults than for 100.
- Some runs starting from 10 adults may go extinct even if the deterministic model grows.
- Extinction probability will decrease as initial population size increases (highest for 3, close to 0 for 100).

**AI use.** I used Claude Code to turn the lecture slides into structured notes, explain eigenvalues/eigenvectors with a worked example, add documentation comments to each function in `Demographic.R`, and help spot bugs in the code. I checked its worked examples by running them in R. I want to write the fixes and tests myself with AI help, rather than having it write them for me.

### 2026-11-19 15:14 – Bug fixes, default parameters and unit tests for Part 1

**What I did since the last entry.** Lectures on 18/11 (applications of matrix models, neutral theory) and today (applications of neutral theory); lecture notes in `notes/Populations.md` and `notes/Communities.md`. For Part 1 I fixed the bugs listed on 17/11, added a parameters file and wrote unit tests. I also wrote study notes on how the model works (`notes/Part1_Demographic_model.md`, with figures made by `notes/images/make_part1_figures.R`).

**Bug fixes in `code/Demographic.R`.**
- `multinomial()` now calls `stop()` if the probabilities sum to more than 1 (it used to print a warning and carry on).
- `rmultinom(n = 11, ...)` changed to `n = 1`, because only the first draw was used.
- `survival_maturation()`: replaced the undefined `sum_vect()` with `new_state <- new_state + individuals_count`. The stochastic model no longer crashes.
- Removed the `if` block at the end of `stochastic_simulation()`, which did nothing.

**Default parameters (`code/demographic_parameters.R`).
- Growth matrix (columns = from, rows = to):
  - stage 1: stay 0.1, move on 0.5
  - stage 2: stay 0.4, move on 0.4
  - stage 3: stay 0.7, move on 0.25
  - adults: stay 0.4

  Death is 1 − column sum: 0.4, 0.2, 0.05 and 0.6. The worksheet's printed matrix says 0.2 at [4,3], but its R code uses 0.25. I used 0.25.
- Reproduction matrix: 2.6 babies per adult per month (entry [1,4]).
- Projection matrix = growth + reproduction. Its dominant eigenvalue is ≈ 1.039, so the deterministic population should grow by about 3.9% a month in the long run.
- Clutch distribution for sizes 1–9: 0.06, 0.08, 0.13, 0.15, 0.16, 0.18, 0.15, 0.06, 0.03. The mean clutch is 4.89, so in the stochastic model each adult breeds with probability 2.6 / 4.89 ≈ 0.532.
- `state_initialise_adult(num_stages, initial_size)` puts all individuals in the adult stage, as Part 1 requires.

**Tests (`code/test_demographic.R`, testthat).** Each test has a comment saying what it checks and why. The model is random, so the tests check things that must always hold, reproducibility with a fixed seed, and that averages match the deterministic model:
1. Parameters are valid: growth matrix columns sum to ≤ 1, the clutch distribution sums to 1, and the recruitment probability is ≤ 1.
2. `state_initialise_adult(4, 100)` gives (0, 0, 0, 100).
3. One deterministic step from 100 adults gives (260, 0, 0, 40), matching the hand calculation.
4. A 24-step deterministic run returns 25 values, starting at 100, with 300 at time 1.
5. `multinomial()` gives whole, non-negative numbers that never add up to more than the pool, over 200 runs. It also handles a pool of 0 and probabilities (1, 0), and errors when the probabilities sum to more than 1.
6. `survival_maturation()` never creates individuals: total ≤ 40 when starting from 10 per stage, over 200 runs.
7. `random_draw()` only returns clutch sizes 1–9.
8. The same seed gives identical stochastic runs. This matters for HPC seeds.
9. Extinction is permanent: once a run hits 0 it stays at 0 (100 runs from 3 adults).
10. The mean of 2000 stochastic runs is within 5% of the deterministic run, for 5 months from 100 adults.

Output of `Rscript code/test_demographic.R` (run from the project root), all 10 tests passing:
```
Test passed with 3 successes 😸.
Test passed with 2 successes 🌈.
Test passed with 1 success 🥳.
Test passed with 3 successes 🎉.
Test passed with 603 successes 🥇.
Test passed with 400 successes 😀.
Test passed with 1 success 🥇.
Test passed with 2 successes 🎉.
Test passed with 38 successes 🌈.
Test passed with 1 success 🌈.
```
The success counts are the number of `expect_*()` checks inside each test. For example, test 5 is 3 checks × 200 runs plus 3 special cases = 603. Test 9 has a variable count because it only checks runs that went extinct: 38 of the 100 runs from 3 adults did.

**Quick check run.** From 100 adults over 24 months (seed 1):
- deterministic: 100, 300, 276, 230, 195, … 449, 466
- stochastic: 100, 295, 264, 204, 178, … 294, 350

Both have the same shape: a jump as the adults breed, a dip as the babies die and the adults age out, then growth. The stochastic run wanders around the deterministic one, as predicted on 17/11.

**Problem.** Running `source("code/test_demographic.R")` in RStudio first failed with `cannot open file 'code/Demographic.R'`, because RStudio's working directory wasn't the project root. I added `SCSE.Rproj` so that opening the project in RStudio sets the working directory to the root. This is what the brief requires anyway.

**Change to the plan.** I'm about a day behind: panel a was planned for 18/11. Fixing the bugs, finding the parameters and understanding the model properly took longer than expected. Next: write the panel a script (local), then the panel b HPC script, testing it locally before submitting. The predictions from 17/11 still stand.

**AI use.** I used Claude Code to:
- find the 2024 parameters in the MQB repo and explain where 4.89 and the 53% come from
- help write the fixes and the tests, and add a "what/why" comment to each test
- explain the stochastic model with worked examples and figures
- turn lecture slides 3–5 into notes

I ran the tests and the example simulations myself to check the results. Useful prompts: "explain each test as a comment as it comes"; "where is the 53% coming from?".

### 2026-11-23 15:34 – Part 1 panel a, HPC run and final figure

**What I did since the last entry.** On 19/11 I wrote and tested the panel a script (`code/part1_panel_a.R`) and the panel b HPC scripts (`code/part1_hpc.sh`, `code/part1_hpc.R`), plus the script that analyses their output (`code/part1_panel_b.R`). I tested them locally first: with no `PBS_ARRAY_INDEX` set, `part1_hpc.R` runs as job 1 and saves to `sandbox/part1_hpc_test/`, so test output never mixes with real results. Today (23/11) I ran the simulations on the Imperial HPC (CX3), analysed them and made the final two-panel figure.

**Panel a.** 24 months from 100 adults (red) and 10 adults (blue): one deterministic run (solid) and 5 stochastic runs (dashed) for each, seed 2026, log y axis. As predicted on 17/11, the stochastic runs scatter around the deterministic line, with much more relative spread from 10 adults. One run from 10 adults fell to a single individual by month 24.

**HPC run (job 3055970).**
- Array job of 20 jobs (`#PBS -J 1-20`). Each job uses its job number as its seed and runs 40 simulations × 4 initial sizes (3, 10, 30, 100 adults) × 120 months, so there are 800 simulations per size in total.
- All 20 `.e` files are empty, and each job took 13–25 s.
- The `.o`/`.e` files are in `results/part1_hpc/logs/`, and the raw results are in `results/part1_hpc/part1_hpc_<i>.rda`.

**Panel b results** (P(extinction) after 120 months, exact 95% binomial CI):

| Initial adults | Extinct / 800 | P(extinction) | 95% CI |
|---|---|---|---|
| 3 | 325 | 0.406 | 0.372–0.441 |
| 10 | 50 | 0.063 | 0.047–0.082 |
| 30 | 1 | 0.001 | 0.000–0.007 |
| 100 | 0 | 0.000 | 0.000–0.005 |

The 17/11 predictions held: extinction risk falls steeply with initial size, it's highest for 3 adults and essentially 0 for 100. Some runs from 10 adults went extinct even though the deterministic model grows (λ ≈ 1.039). Extinction risk drops by roughly an order of magnitude between 3 and 10 adults, which fits demographic stochasticity mattering mainly in small populations.

**Reproducibility check.** I reran job 7 on the laptop (`PBS_ARRAY_INDEX=7`) and compared it with the HPC file. The `extinct` table was identical (`identical()` = TRUE), so the seeds work as intended.

**Final figure.** `code/part1_figure.R` puts panels a and b side by side in `results/part1_figure.pdf`, with bold a/b labels. The plotting functions are now in `code/part1_plot_functions.R`, so the preview PDFs and the final figure are drawn by the same code. I first removed the panel titles, because captions usually do that job in papers, then put them back. I still need to decide on this for the final report. I also widened panel b's x range and tidied the panel a legend, because value labels were being cut off. `code/part1_run_all.R` rebuilds panel a → panel b → figure with one command.

**Automating the HPC side for Part 3.** `code/part1_submit.sh` submits the 20 jobs and then `code/part1_combine.sh` with `qsub -W depend=afterok:<array ID>`. PBS holds the combine job until all 20 jobs have succeeded, then the combine job tidies the logs and makes panel b and the figure. So far this has only been dry-run tested with a fake `qsub` on the laptop. I'll test it for real in Part 3. Every script is described in `code/Part1_README.md`, and the HPC workflow is in `notes/Part1_HPC_workflow.md`.

**Problems.**
- `part1_panel_b.R` stopped with `No part1_hpc_<i>.rda files found`, because the HPC hadn't run yet. The scripts weren't on GitHub either, because they were never committed.
- `git clone` on the HPC failed with `Permission denied (publickey)`. The SSH key on my GitHub account was my laptop's. I made a separate key on the HPC with `ssh-keygen` and added it to GitHub.
- The terminal stopped accepting input after `module avail` (a pager or frozen session). I opened a new terminal and logged in again.
- Plain `qstat` lists every user's jobs, so I use `qstat -u nee26 -t` instead. I also checked `results/` before any job had finished, so I learned to wait for status `X`.
- I first ran HPC commands on the laptop by mistake. I now check the prompt before typing.

**Change to the plan.** The HPC submission was planned for Fri 20/11 and happened on Mon 23/11, so I'm about 3 days behind the original plan for Part 1. Part 1 now only needs the caption and the 150 words. Next: Part 2 functions (planned for 24/11).

**AI use.** I used Claude Code to:
- explain the HPC workflow step by step: SSH keys, git between laptop and HPC, `qsub`/`qstat`, array jobs and `afterok` dependencies
- debug the problems above
- combine the panels into one figure and fix the clipped labels
- write the run-all and submit/combine scripts, the HPC notes and the script overview

I ran every command on the HPC myself and checked the results (`.e` files, the numbers, the rendered figure). Useful prompts: "explain to me how this code is running from top to bottom"; "how does the overall HPC know when the jobs are done?".
