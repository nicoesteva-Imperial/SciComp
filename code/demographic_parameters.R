# Part 1 – default parameters for the demographic model
# Source: the 2024 version of the course HPC worksheet (Question 1 and Question 2),
# MQB course repo: github.com/MulQuaBio/MQB,
#   content/hpc/instructions/2024_11_16_HPC_worksheet.ipynb
# (the matching provided code is content/code/demographic.R in the same repo).
# These values are NOT in the 2026 coursework brief or the 2026 lecture slides;
# TO CONFIRM with the lecturer that they are the 2026 "default settings".
# Four life stages, time step = 1 month.
#
# Matrices: COLUMN = current stage, ROW = next stage (stage 4 = adults).
# Note: the worksheet's printed matrix shows 0.2 at [4,3] but its R code uses 0.25;
# the R code value (0.25) is used here.

# ---------------------------------------------------------------------------
# GROWTH MATRIX: survival / maturation probabilities (no reproduction)
# ---------------------------------------------------------------------------
# Read it DOWN each column: column i = what happens to ONE individual currently
# in stage i over one month.
#
#             from: st1   st2   st3   st4
#   to st1   [1,]   0.1   0.0   0.0   0.0
#   to st2   [2,]   0.5   0.4   0.0   0.0
#   to st3   [3,]   0.0   0.4   0.7   0.0
#   to st4   [4,]   0.0   0.0   0.25  0.4
#
# Death is NOT stored in the matrix: multinomial() in Demographic.R computes it
# as  death = 1 - (column sum). So each column must sum to <= 1, NOT exactly 1
# (a column summing to 1 would mean individuals in that stage can never die).
#
#   stage | stay | move to next stage | die (= 1 - column sum) | column sum
#   ------|------|--------------------|------------------------|-----------
#     1   | 0.1  | 0.5  -> stage 2    | 0.4                    | 0.60
#     2   | 0.4  | 0.4  -> stage 3    | 0.2                    | 0.80
#     3   | 0.7  | 0.25 -> stage 4    | 0.05                   | 0.95
#     4   | 0.4  | - (final stage)    | 0.6                    | 0.40
#
# Biologically: the youngest stage has high mortality (40%/month) but most
# individuals leave it quickly; survival increases with stage (60% -> 80% -> 95%);
# stage 3 is slow to leave (70% stay); adults survive poorly (40%/month) but
# compensate by reproducing.
growth_matrix <- matrix(c(0.1, 0.0, 0.0,  0.0,
                          0.5, 0.4, 0.0,  0.0,
                          0.0, 0.4, 0.7,  0.0,
                          0.0, 0.0, 0.25, 0.4),
                        nrow = 4, ncol = 4, byrow = TRUE)

# ---------------------------------------------------------------------------
# REPRODUCTION MATRIX: mean number of stage-1 offspring per adult per month
# ---------------------------------------------------------------------------
# Only entry [1, 4] is non-zero: adults (column 4) produce new stage-1
# individuals (row 1). 2.6 is an average RATE (offspring per adult per month),
# not a probability, so it can be bigger than 1.
reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                                0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0, 0.0),
                              nrow = 4, ncol = 4, byrow = TRUE)

# ---------------------------------------------------------------------------
# PROJECTION MATRIX: used by the DETERMINISTIC model only
# ---------------------------------------------------------------------------
# projection = growth + reproduction. Entry [j, i] = how many stage-j individuals
# next month, on average, ONE stage-i individual turns into this month.
#
# The adult column (column 4) is (2.6, 0, 0, 0.4): one adult becomes
#   2.6 offspring in stage 1  +  0.4 of itself (it survives with prob. 0.4)
#   = 3.0 individuals next month.
# Its column sum is 3.0 > 1, which is fine: this is NOT a probability matrix,
# it mixes survival probabilities with a reproduction rate.
#
# Long-term behaviour (Lecture 2, eigenvalues): the dominant eigenvalue of this
# matrix is ~1.039, i.e. once the stage structure settles, the deterministic
# population is multiplied by 1.039 each month (~3.9% growth per month). As it is
# > 1, the DETERMINISTIC population never goes extinct from any starting size;
# extinctions can only happen in the stochastic model, through chance.
#   Check:  Re(eigen(projection_matrix)$values[1])   # 1.039025
projection_matrix <- reproduction_matrix + growth_matrix

# ---------------------------------------------------------------------------
# CLUTCH DISTRIBUTION: used by the STOCHASTIC model only
# ---------------------------------------------------------------------------
# Entry k = probability that a reproducing adult has a clutch of k offspring
# (k = 1..9). This IS a probability distribution, so it must sum to exactly 1.
#   mean clutch size = sum(k * P(k)) = 1*0.06 + 2*0.08 + ... + 9*0.03 = 4.89
#
# How the stochastic model turns the deterministic rate (2.6) into random events
# (see stochastic_recruitment() and offspring_calc() in Demographic.R):
#   1. Each adult reproduces this month with probability
#        recruitment_probability = 2.6 / 4.89 = 0.532
#      (number of adults reproducing ~ Binomial(adults, 0.532))
#   2. Each adult that reproduces draws a clutch size from this distribution.
#   Average offspring per adult = P(reproduce) * mean clutch = 0.532 * 4.89 = 2.6,
#   so on AVERAGE the stochastic model matches the deterministic rate of 2.6, but
#   individual months vary (some adults have 0 offspring, others up to 9).
#   This only works if 2.6 <= 4.89 (probability <= 1); otherwise the code stops.
clutch_distribution <- c(0.06, 0.08, 0.13, 0.15, 0.16, 0.18, 0.15, 0.06, 0.03)

num_stages <- nrow(projection_matrix)


# state_initialise_adult()
# What it does: creates a state vector where the whole population starts in the
#   final (adult) life stage – the initial condition required for Part 1.
# Parameters:
#   num_stages   - integer: number of life stages (length of the state vector)
#   initial_size - integer: total number of individuals
# Returns: integer vector of length num_stages, e.g. (0, 0, 0, 100)
state_initialise_adult <- function(num_stages, initial_size) {
  c(rep(0, num_stages - 1), initial_size)
}
