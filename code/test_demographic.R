# Unit tests for the Part 1 demographic model
# Run from the project root:  Rscript code/test_demographic.R
#
# HOW TESTING WORKS (testthat package)
#   test_that("description", { ... }) groups some checks under a name.
#   Inside, each expect_...() is one check:
#     expect_equal(a, b)     a must equal b (tiny rounding differences allowed)
#     expect_identical(a, b) a must be EXACTLY b
#     expect_true(x)         x must be TRUE
#     expect_lte(a, b)       a must be <= b  ("less than or equal")
#     expect_length(x, n)    x must have n elements
#     expect_error(code)     the code must STOP with an error
#   If every check passes, the test passes. If any fails, testthat prints which
#   check failed and the values it got, so you know exactly what broke.
#
# WHY TESTING RANDOM CODE IS TRICKY
#   A stochastic function gives a different answer every time, so we can't say
#   "the answer must be 40". Instead we test three kinds of things:
#   (a) rules that must ALWAYS hold, however lucky/unlucky the dice
#       (whole numbers, nobody created from nothing, extinction is permanent)
#   (b) reproducibility: with the same seed, the same "random" numbers come out
#   (c) averages: over many runs, the mean should match the deterministic model

library(testthat)
source("code/Demographic.R")            # the model functions
source("code/demographic_parameters.R") # the matrices and clutch distribution


# ---------------------------------------------------------------------------
# TEST 1: the parameters make sense
# ---------------------------------------------------------------------------
# What: checks the INPUTS before testing any function.
#   - colSums(growth_matrix) <= 1 : each column is "what happens to one
#     individual", so stay + move can't be more than 100% (the rest is death).
#   - sum(clutch_distribution) == 1 : clutch sizes 1..9 must cover all
#     possibilities, so their probabilities must add to exactly 1.
#   - recruitment probability (2.6 / 4.89 = 0.532) <= 1 : it is a probability.
# Why: if a parameter is wrong (e.g. a typo making a column sum to 1.2), every
#   other result would be wrong too, and this test points straight at the cause.
test_that("parameters are valid", {
  expect_true(all(colSums(growth_matrix) <= 1))
  expect_equal(sum(clutch_distribution), 1)
  expect_lte(stochastic_recruitment(reproduction_matrix, clutch_distribution), 1)
})


# ---------------------------------------------------------------------------
# TEST 2: the starting population is set up correctly
# ---------------------------------------------------------------------------
# What: state_initialise_adult(4, 100) must give (0, 0, 0, 100), i.e. everyone
#   in the LAST stage (adults), as Part 1 requires. Tried with 100 and 3.
# Why: if the adults ended up in stage 1 by mistake, the simulations would run
#   without errors but answer the wrong question. Hard to spot in a plot.
test_that("state_initialise_adult puts everyone in the last stage", {
  expect_equal(state_initialise_adult(4, 100), c(0, 0, 0, 100))
  expect_equal(state_initialise_adult(4, 3), c(0, 0, 0, 3))
})


# ---------------------------------------------------------------------------
# TEST 3: one deterministic step = the matrix multiplication done by hand
# ---------------------------------------------------------------------------
# What: from (0, 0, 0, 100), one month should give
#   stage 1 = 2.6 x 100 = 260 babies,  stage 4 = 0.4 x 100 = 40 surviving adults
#   -> (260, 0, 0, 40)   (worked through in notes/Part1_Demographic_model.md)
#   as.vector() turns R's 1-column matrix result into a plain vector to compare.
# Why: compares the code with an answer worked out independently by hand. It
#   would catch a transposed matrix (rows/columns swapped), which is a very
#   common mistake: then the babies would end up in the wrong stage.
test_that("deterministic_step matches hand-calculated matrix multiplication", {
  expect_equal(as.vector(deterministic_step(c(0, 0, 0, 100), projection_matrix)),
               c(260, 0, 0, 40))
})


# ---------------------------------------------------------------------------
# TEST 4: the deterministic simulation records the right things
# ---------------------------------------------------------------------------
# What: a 24-step run must return 25 numbers (time 0 PLUS 24 steps), start
#   at 100 (the initial total) and have 300 (= 260 + 40) at time 1.
# Why: catches "off-by-one" errors (24 vs 25 values), which would misalign the
#   x-axis of panel a, and checks it stores the TOTAL population, not one stage.
test_that("deterministic_simulation returns the right length and starting value", {
  out <- deterministic_simulation(c(0, 0, 0, 100), projection_matrix, 24)
  expect_length(out, 25)
  expect_equal(out[1], 100)
  expect_equal(out[2], 300)
})


# ---------------------------------------------------------------------------
# TEST 5: multinomial() splits individuals correctly
# ---------------------------------------------------------------------------
# What: multinomial(50, c(0.3, 0.4)) splits 50 individuals into
#   "outcome 1" (30%), "outcome 2" (40%) and death (the other 30%, dropped).
#   Repeated 200 times with different random numbers, EVERY result must:
#     - have 2 entries (one per outcome, death removed)
#     - be whole, non-negative numbers (no 2.7 animals, no -1 animals)
#     - add up to at most 50 (nobody created; the missing ones died)
#   Plus three special cases:
#     - pool of 0 -> (0, 0): nobody to split
#     - probabilities (1, 0) -> all 20 go to outcome 1: no randomness possible,
#       so we CAN check an exact answer
#     - probabilities (0.7, 0.6) sum to 1.3 -> must stop with an error
#       (this was a bug: the original code only printed a warning)
# Why: this is the "dice for a whole stage" function. Everything stochastic
#   depends on it, so it is tested the hardest.
# set.seed(1): fixes the random numbers so the test does the same thing every run.
test_that("multinomial returns whole numbers and never creates individuals", {
  set.seed(1)
  for (k in 1:200) {
    x <- multinomial(50, c(0.3, 0.4))
    expect_length(x, 2)
    expect_true(all(x == round(x)) && all(x >= 0))
    expect_lte(sum(x), 50)
  }
  expect_equal(multinomial(0, c(0.3, 0.4)), c(0, 0))
  expect_equal(multinomial(20, c(1, 0)), c(20, 0))
  expect_error(multinomial(10, c(0.7, 0.6)))
})


# ---------------------------------------------------------------------------
# TEST 6: survival and maturation never create individuals
# ---------------------------------------------------------------------------
# What: start with 10 in every stage (40 in total) and apply only survival and
#   maturation (NO reproduction). 200 times, the result must have 4 stages
#   and a total of at most 40.
# Why: without births the population can only stay the same or shrink. If the
#   total ever went up, individuals were being counted twice somewhere in
#   combining the per-stage results (the step that originally crashed because
#   of the undefined sum_vect()). Starting with every stage filled means all
#   four columns of the growth matrix get used.
test_that("survival_maturation never creates individuals", {
  set.seed(2)
  for (k in 1:200) {
    s <- survival_maturation(c(10, 10, 10, 10), growth_matrix)
    expect_length(s, 4)
    expect_lte(sum(s), 40)
  }
})


# ---------------------------------------------------------------------------
# TEST 7: clutch sizes are always possible values
# ---------------------------------------------------------------------------
# What: draws 1000 clutch sizes; every one must be one of 1, 2, ..., 9.
#   (%in% 1:9 asks "is each value in the set 1 to 9?")
# Why: a clutch of 0 or 10 is impossible under this distribution. Getting one
#   would mean random_draw() is indexing the distribution wrongly.
test_that("random_draw only returns possible clutch sizes", {
  set.seed(3)
  draws <- replicate(1000, random_draw(clutch_distribution))
  expect_true(all(draws %in% 1:9))
})


# ---------------------------------------------------------------------------
# TEST 8: same seed -> same simulation (reproducibility)
# ---------------------------------------------------------------------------
# What: runs the stochastic simulation twice, each time after set.seed(42).
#   The two results must be IDENTICAL, and 25 values long (time 0 + 24 steps).
# Why: computers make "random" numbers from a starting value (the seed). Same
#   seed = same sequence of dice rolls = same result. This is essential for
#   the HPC part: each job uses its PBS_ARRAY_INDEX as the seed, so any job
#   can be re-run and checked, and different jobs give different results.
test_that("stochastic_simulation is reproducible with a fixed seed", {
  set.seed(42); a <- stochastic_simulation(c(0, 0, 0, 10), growth_matrix, reproduction_matrix, clutch_distribution, 24)
  set.seed(42); b <- stochastic_simulation(c(0, 0, 0, 10), growth_matrix, reproduction_matrix, clutch_distribution, 24)
  expect_identical(a, b)
  expect_length(a, 25)
})


# ---------------------------------------------------------------------------
# TEST 9: extinction is permanent
# ---------------------------------------------------------------------------
# What: 100 simulations from 3 adults (small, so many go extinct). For each:
#   match(0, out) finds the first time the population hits 0 (NA if never).
#   If it did hit 0, every value AFTER that must also be 0.
# Why: nothing can be born from an empty population. If a run went
#   0 -> 5, the code would be creating animals from nothing, and the
#   extinction probabilities for panel b would be wrong.
#   (In the code this holds because the loop stops at 0 and the rest of the
#   vector was created full of zeros.)
test_that("extinction is permanent (zeros stay zero)", {
  set.seed(4)
  for (k in 1:100) {
    out <- stochastic_simulation(c(0, 0, 0, 3), growth_matrix, reproduction_matrix, clutch_distribution, 50)
    first_zero <- match(0, out)
    if (!is.na(first_zero)) expect_true(all(out[first_zero:length(out)] == 0))
  }
})


# ---------------------------------------------------------------------------
# TEST 10: on average, stochastic = deterministic
# ---------------------------------------------------------------------------
# What: the "5000 parallel universes" idea from the notes, here with 2000.
#   - det: ONE deterministic run from 100 adults, 5 months (6 values).
#   - sims: 2000 stochastic runs from the same start. replicate() puts them
#     side by side as COLUMNS: a 6 x 2000 table (rows = months, cols = runs).
#   - rowMeans(sims): the average over the 2000 universes, month by month.
#   Each average must be within 5% of the deterministic value (tolerance = 0.05).
# Why: this is the main check that the stochastic model is built right. The
#   2.6 / 4.89 recruitment trick and the multinomial survival are designed so
#   the AVERAGE matches the deterministic model. If e.g. adults bred
#   every month (forgetting the 53%), births would be 4.89 instead of 2.6 per
#   adult (~1.9x too many) and this test would fail.
#   Short (5 months) and large (100 adults) so randomness averages out well
#   and almost no runs go extinct, which keeps the 5% tolerance meaningful.
test_that("mean of many stochastic runs is close to the deterministic model", {
  set.seed(5)
  det <- deterministic_simulation(c(0, 0, 0, 100), projection_matrix, 5)
  sims <- replicate(2000, stochastic_simulation(c(0, 0, 0, 100), growth_matrix, reproduction_matrix, clutch_distribution, 5))
  expect_equal(rowMeans(sims), det, tolerance = 0.05)
})
