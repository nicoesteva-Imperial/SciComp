# CMEE 2024 HPC exercises R code provided
# Stochastic and deterministic demographic model
#
# Conventions used throughout:
#   - "state" is a vector with the number of individuals in each life stage,
#     ordered from youngest (first entry) to adults (last entry).
#   - In every matrix, COLUMN = current stage and ROW = next stage, so entry
#     [j, i] is the rate/probability of going from stage i to stage j in one step.
#   - projection_matrix = growth_matrix + reproduction_matrix


# deterministic_step()
# What it does: advances the population by ONE time step deterministically, by
#   multiplying the state vector by the projection matrix (n_{t+1} = P n_t).
#   Every individual follows the "average" outcome, so results can be fractional.
# Parameters:
#   state             - numeric vector: number of individuals in each life stage now
#   projection_matrix - square matrix (stages x stages): survival, maturation and
#                       reproduction rates combined
# Returns: numeric vector (as a 1-column matrix) of individuals per stage next step
deterministic_step <- function(state,projection_matrix){
  new_state = projection_matrix %*% state
  return(new_state)
}


# deterministic_simulation()
# What it does: runs the deterministic model for a number of time steps by calling
#   deterministic_step() repeatedly, recording the TOTAL population size each step.
# Parameters:
#   initial_state     - numeric vector: individuals per life stage at time 0
#   projection_matrix - square matrix: combined growth + reproduction rates
#   simulation_length - integer: number of time steps to simulate
# Returns: numeric vector of length simulation_length + 1 with the total population
#   size at times 0, 1, ..., simulation_length
deterministic_simulation <- function(initial_state,projection_matrix,simulation_length){
  population_size <- numeric(simulation_length + 1) # list as long as sim length + 1
  population_size[1] <- sum(initial_state) # first value = sum initial state
  for (i in 1:simulation_length) {
    initial_state <- deterministic_step(initial_state, projection_matrix) # step through
    population_size[i + 1] <- sum(initial_state) # add to index
  }
  return(population_size)
}


# multinomial()
# What it does: randomly splits a group of individuals between several outcomes
#   (e.g. "stay in stage", "move to next stage") plus an implicit extra outcome,
#   death, whose probability is 1 - sum(probs). Uses a multinomial draw, so every
#   individual ends up in exactly one outcome and the counts are whole numbers.
# Parameters:
#   pool  - integer: number of individuals to split up
#   probs - numeric vector: probability of each (non-death) outcome; should sum to <= 1
# Returns: integer vector, same length as probs, with the number of individuals
#   assigned to each outcome (the dead are dropped)
# NOTE: if sum(probs) > 1 it only prints a warning, then rmultinom() errors on the
#   negative death probability. n = 11 draws 11 samples but only the first is used
#   (n = 1 would be enough).
multinomial <- function(pool, probs) {
  if (sum(probs) > 1) { # check probability
    print("Sum of probabilities is greater than 1")
  }
  death = 1 - sum(probs) # death prob
  probd = c(probs, death) # merge them
  x = as.vector(rmultinom(n=11, pool, probd)) # sample
  return(x[1:length(probs)])
}


# survival_maturation()
# What it does: the stochastic version of applying the growth matrix. For each
#   life stage, it takes the individuals in that stage and randomly decides (via
#   multinomial()) whether each one stays, matures into another stage, or dies,
#   using that stage's column of the growth matrix as probabilities. Results from
#   all stages are added together to give the new state.
# Parameters:
#   state         - integer vector: individuals per life stage now
#   growth_matrix - square matrix: survival/maturation probabilities only (no
#                   reproduction); column i = where individuals in stage i go next
# Returns: integer vector: individuals per life stage after survival and maturation
# NOTE: calls sum_vect(), which is not defined anywhere in this file, so this
#   function currently errors. new_state + individuals_count would do the same job.
survival_maturation <- function(state,growth_matrix){
  new_state <- rep(0, length(state)) # 1. new population state
  for (i in 1:length(state)){
    current_individuals <- state[i] # 2.1 individuals in life stage i
    transition_probs <- growth_matrix[,i] # 2.2 initialise probabilities from matrix
    individuals_count <- multinomial(current_individuals, transition_probs) # 2.2 individuals that remain in stage i
    new_state <- sum_vect(new_state, individuals_count)
  }
  return(new_state) # 3. return new_state
}


# random_draw()
# What it does: draws ONE random value from a discrete probability distribution.
#   Used to pick a clutch size: the value returned is the index (1, 2, 3, ...)
#   chosen with the given probabilities.
# Parameters:
#   probability_distribution - numeric vector: probability of each outcome, where
#                              entry k is the probability of drawing the value k
# Returns: integer between 1 and length(probability_distribution)
random_draw <- function(probability_distribution) {
  draw <- sample(1:length(probability_distribution), size = 1, prob = probability_distribution, replace = TRUE)
  return(draw)
}


# stochastic_recruitment()
# What it does: converts the deterministic reproduction rate into the probability
#   that an adult reproduces in a time step. Each adult that reproduces produces a
#   random clutch, so recruitment probability = (mean offspring per adult) /
#   (mean clutch size). This keeps the stochastic model's AVERAGE number of
#   offspring the same as the deterministic model's.
# Parameters:
#   reproduction_matrix - square matrix: reproduction rates only; entry [1, last]
#                         is the mean number of stage-1 offspring per adult per step
#   clutch_distribution - numeric vector: entry k = probability of a clutch of size k
# Returns: single number between 0 and 1: probability an adult reproduces in a step
#   (stops with an error if it would exceed 1, i.e. parameters are inconsistent)
stochastic_recruitment <- function(reproduction_matrix,clutch_distribution){
  recruitment_rate <- reproduction_matrix[1, ncol(reproduction_matrix)] # get recruitment rate
  expected_clutch_size <- sum(clutch_distribution * (1:length(clutch_distribution))) # get mean clutch size
  recruitment_probability <- recruitment_rate / expected_clutch_size # recruitment probability
  if (recruitment_probability > 1) { # check probability
    stop("Inconsistency in model parameters: Recruitment probability cannot exceed 1.")
  }
  return(recruitment_probability)
}


# offspring_calc()
# What it does: works out the total number of offspring produced in one step.
#   First draws how many adults reproduce (binomial: each adult reproduces with
#   recruitment_probability), then draws a random clutch size for each of those
#   adults with random_draw() and adds them up.
# Parameters:
#   state                   - integer vector: individuals per life stage (the last
#                             entry is the number of adults)
#   clutch_distribution     - numeric vector: entry k = probability of a clutch of size k
#   recruitment_probability - number in [0, 1]: probability an adult reproduces this
#                             step (from stochastic_recruitment())
# Returns: integer: total number of new offspring this step
offspring_calc <- function(state, clutch_distribution, recruitment_probability) {
  offspring = 0
  x = state[length(state)] # number of adults
  number_clutch = rbinom(1, x, recruitment_probability) # number of recruiting adults

  if (number_clutch > 0) { # check for population collapse
    for (i in 1:number_clutch) {
      clutch = random_draw(clutch_distribution) # get clutch size
      offspring = offspring + clutch # sum number of offspring
    }
  }

  return(offspring) # total number of offspring
}


# stochastic_step()
# What it does: advances the population by ONE time step stochastically.
#   1. survival_maturation(): individuals randomly survive / mature / die
#   2. offspring_calc(): adults randomly reproduce (based on the state at the
#      START of the step, matching the deterministic P %*% state)
#   3. the new offspring are added to the first life stage
# Parameters:
#   state                   - integer vector: individuals per life stage now
#   growth_matrix           - square matrix: survival/maturation probabilities
#   reproduction_matrix     - square matrix: reproduction rates (not used directly
#                             here; recruitment_probability already encodes it)
#   clutch_distribution     - numeric vector: entry k = probability of a clutch of size k
#   recruitment_probability - number in [0, 1]: probability an adult reproduces
# Returns: integer vector: individuals per life stage after one step
stochastic_step <- function(state,growth_matrix,reproduction_matrix,clutch_distribution,recruitment_probability){
  new_state = survival_maturation(state, growth_matrix) # survival and maturation
  total_offspring = offspring_calc(state, clutch_distribution, recruitment_probability) # number of offspring produced
  new_state[1] = new_state[1] + total_offspring # add to new state
  return(new_state)
}


# stochastic_simulation()
# What it does: runs the stochastic model for a number of time steps by calling
#   stochastic_step() repeatedly, recording the TOTAL population size each step.
#   If the population hits 0 (extinction) it stops early; the remaining entries
#   stay 0 because the vector is created full of zeros.
# Parameters:
#   initial_state       - integer vector: individuals per life stage at time 0
#   growth_matrix       - square matrix: survival/maturation probabilities
#   reproduction_matrix - square matrix: reproduction rates (entry [1, last])
#   clutch_distribution - numeric vector: entry k = probability of a clutch of size k
#   simulation_length   - integer: number of time steps to simulate
# Returns: numeric vector of length simulation_length + 1 with the total population
#   size at times 0, 1, ..., simulation_length (0 after extinction)
# NOTE: the final if-block does nothing (population_size is always full length and
#   the line inside doesn't assign anything); it is safe to remove.
stochastic_simulation <- function(initial_state,growth_matrix,reproduction_matrix,clutch_distribution,simulation_length){
  population_size <- numeric(simulation_length + 1) # population of length sim + 1
  population_size[1] = sum(initial_state) # first value sum of initial state
  recruitment_probability = stochastic_recruitment(reproduction_matrix, clutch_distribution) # recruitment probability

  for(i in 1:simulation_length){
    new_state = stochastic_step(initial_state, growth_matrix, reproduction_matrix, clutch_distribution, recruitment_probability) # one step of stochastic model
    population_size[i + 1] = sum(new_state) # update population time series
    if (sum(new_state) == 0){break} # stop if the population is zero
    initial_state = new_state # update for next iter
  }

  if (length(population_size) < simulation_length + 1){ # fill remaining entries with 0
    population_size[(length(population_size) + 1):(simulation_length + 1)]
  }

  return(population_size)
}

