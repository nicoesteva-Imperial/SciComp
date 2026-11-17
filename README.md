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
