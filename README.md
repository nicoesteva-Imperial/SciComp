# Scientific Computing and Simulation for Ecology and Evolution

Coursework repository for the 2026 Scientific Computing in Ecology & Evolution module (Imperial College London).

## Structure
- `code/` – R scripts (run with the project root as the working directory)
- `results/` – generated figures and output files
- `sandbox/` – scratch/testing area
- `notes/` – lecture notes

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

**Default parameters (`code/demographic_parameters.R`).** These aren't in the 2026 brief or slides. I took them from the 2024 HPC worksheet in the MulQuaBio MQB repo (`content/hpc/instructions/2024_11_16_HPC_worksheet.ipynb`), which matches the provided code. **Still to confirm with the lecturer.**
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
