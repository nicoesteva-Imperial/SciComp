# Lecture 2 – Populations (first part)
*James Rosindell*

## Lecture outline
1. Population modelling overview and stochastic vs deterministic
2. Demographic population models and matrix population models
3. Stochastic adaptation

---

# 1. Population modelling overview

## What is a population model?
- Models how a population (or population**s**) changes over time
- We might be interested in...
    - The effect of different parameters on the population dynamics
    - Identifying an appropriate control or conservation strategy
    - The likelihood of extinction or recovery
- We can make different assumptions:
    - **Homogeneous** – every individual is the same
    - **Heterogeneous** – individuals can be different
        1. **Compartmental** – there are different compartments and every individual in the same compartment is the same
        2. **Individual-based** – we explicitly model every single individual and all their traits

## Stochastic vs deterministic modelling
- **Deterministic = determined**
    - Assumes that outcomes follow determined paths
    - Can be simulated once to observe modelled behaviour
- **Stochastic = random**
    - Assumes that outcomes are drawn from random distributions
    - Must be simulated many times to observe modelled behaviour, since every simulation can be different
    - Typically closer to reality as life is inherently random!

## Example: Exponential population model
- **Deterministic** (black line): every time step, the bacterial population multiplies by 1.1
    - $p_{t+1} = 1.1\,p_t$
- **Stochastic** (coloured lines): every time step, there is a 10% chance of each individual bacterium reproducing
    - $p_{t+1} = p_t + N_{t+1}$
    - $N_{t+1} \sim \text{Bin}(p_t,\ 0.1)$

```r
# Deterministic model: p[t+1] = 1.1 * p[t]
deterministic <- function(p0, t_max) {
  p <- numeric(t_max + 1)
  p[1] <- p0
  for (t in 1:t_max) {
    p[t + 1] <- 1.1 * p[t]
  }
  p
}

# Stochastic model: p[t+1] = p[t] + N[t+1], where N[t+1] ~ Bin(p[t], 0.1)
stochastic <- function(p0, t_max) {
  p <- numeric(t_max + 1)
  p[1] <- p0
  for (t in 1:t_max) {
    births <- rbinom(1, p[t], 0.1)
    p[t + 1] <- p[t] + births
  }
  p
}

set.seed(1)
p0 <- 10
t_max <- 30
time <- 0:t_max

det <- deterministic(p0, t_max)
sims <- replicate(5, stochastic(p0, t_max))   # 5 stochastic runs

png("images/exponential_model.png", width = 800, height = 550)
matplot(time, sims, type = "l", lty = 1, lwd = 1.5, col = rainbow(5),
        ylim = range(c(sims, det)),
        xlab = "Time step (t)", ylab = "Bacterial population (p)",
        main = "Exponential population model: deterministic vs stochastic")
lines(time, det, col = "black", lwd = 3)
legend("topleft", legend = c("Deterministic", "Stochastic (5 runs)"),
       col = c("black", "red"), lwd = c(3, 1.5))
dev.off()

cat("Deterministic p at t = 30:", round(det[t_max + 1], 1), "\n")
cat("Stochastic p at t = 30:", sims[t_max + 1, ], "\n")
```

**Output:**
```
Deterministic p at t = 30: 174.5 
Stochastic p at t = 30: 200 169 199 175 186
```

![Exponential population model: deterministic vs stochastic](images/exponential_model.png)

### Lecture output table (p₀ = 10, 7 stochastic runs)
| model_type | sim | t0 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| deterministic | NA | 10 | 11 | 12.1 | 13.31 | 14.64 | 16.11 | 17.72 | 19.49 | 21.44 | 23.58 |
| stochastic | 1 | 10 | 12 | 13 | 14 | 17 | 19 | 20 | 22 | 24 | 26 |
| stochastic | 2 | 10 | 11 | 11 | 14 | 15 | 15 | 16 | 20 | 24 | 29 |
| stochastic | 3 | 10 | 11 | 12 | 15 | 16 | 19 | 20 | 22 | 25 | 27 |
| stochastic | 4 | 10 | 11 | 13 | 14 | 16 | 19 | 20 | 22 | 24 | 26 |
| stochastic | 5 | 10 | 11 | 13 | 13 | 15 | 17 | 18 | 19 | 20 | 22 |
| stochastic | 6 | 10 | 11 | 12 | 12 | 12 | 12 | 12 | 12 | 12 | 14 |
| stochastic | 7 | 10 | 10 | 11 | 12 | 13 | 14 | 16 | 18 | 18 | 19 |

- The deterministic simulation is based on **averages** → gives **continuous**, not discrete, outputs
    - If we were modelling number of bacteria, this is biologically unrealistic (you can't have 16.11 bacteria)
- In this particular situation, the deterministic simulation reflects the **average behaviour** of the stochastic model

### When do the two agree?
- **Good approximation:** in some situations deterministic and stochastic models give very similar outcomes
    - e.g. with initial population **1000** instead of 10, all stochastic runs hug the deterministic line (≈1000 → ≈2300 over 10 steps). Large populations → randomness averages out
- **Average behaviour:** the deterministic model can match the *mean* of many stochastic runs
    - e.g. averaging the 7 stochastic runs (p₀ = 10) at each time point gives a line almost on top of the deterministic one

## Stochastic modelling – why bother?
- Enables us to include realistic probability distributions (rather than assuming everything follows the "average" outcome)
- Can handle **discrete outcomes**
    - e.g. whole numbers of organisms; not 16.11 bacteria
- Most important in situations where:
    - Stochastic events can make a substantial difference
    - Future changes are sensitive to the current value
    - We want some certainty bounds around our results
- Should be **run many times** to get an overall sense of model behaviour → this is where **cluster computing** is useful
- Trade-off: **biological realism vs computational effort**

---

# 2. Demographic & matrix population models

## Demographic population models
- Describe how a population changes in terms of, and in response to, a **demographic structure** in the population
- The demographic structure is typically a set of traits which affect **life history processes** (i.e. birth and death)
- A simple demographic trait to structure a model is **age**
- Other traits: body weight, sex, sexual maturity
- Can also incorporate evolutionary processes ("**evolutionary demography**") → used to explore evolution of life history "strategies"

## Matrix population models
- Usually means an **age-** or **stage-structured matrix population model**
- The population is divided into **discrete life stages** or **age classes**
- Each **stage/class has a set of parameters** describing **demographic processes** (survival, maturation, recruitment)
- The population is represented by a **state vector**: the number of individuals in each stage/class
- The parameters go into a **projection matrix**, which is applied to the state vector to project the population forwards in time
- Matrix population models are typically **deterministic**

*(Slide aside: xkcd comic of "the right response to the wrong emergency" – a grid of situations × responses where only the diagonal works. A way to picture a matrix: rows × columns, each cell = one combination.)*

## Matrix multiplication refresher
- To get entry (row *i*, column *j*) of **A·B**: take row *i* of A, column *j* of B, multiply pairwise and sum

$$
\begin{pmatrix} a_{11} & a_{12} & a_{13} \\ a_{21} & a_{22} & a_{23} \\ a_{31} & a_{32} & a_{33} \end{pmatrix}
\begin{pmatrix} b_{11} & b_{12} \\ b_{21} & b_{22} \\ b_{31} & b_{32} \end{pmatrix}
$$

- e.g. entry (2,2) $= a_{21}b_{12} + a_{22}b_{22} + a_{23}b_{32}$
- Matrix × vector works the same way (a vector is a 1-column matrix): entry 2 $= a_{21}b_{11} + a_{22}b_{21} + a_{23}b_{31}$
- (3×3)·(3×2) → 3×2; (3×3)·(3×1) → 3×1. Inner dimensions must match.
- In R: `A %*% B` (not `A * B`, which is element-wise)

## Example: coursework as a matrix model
- **Columns = current state**, **rows = next state**. Each cell = probability of moving from the column's state to the row's state in one time step

| Next ↓ \ Current → | Assigned | Started | Finished |
|---|---|---|---|
| **Assigned** | 0.2 (laziness or too busy) | 0.1 (data loss disaster without a backup) | 0 (impossible) |
| **Started** | 0.8 (do work) | 0.5 (keep working but not done yet) | 0 (impossible) |
| **Finished** | 0 (cheating) | 0.4 (do work) | 1 (celebrate! it's all done) |

- Each column sums to 1 (everyone has to end up somewhere)
- Current state vector: 40 assigned, 10 started, 10 finished
- Next state:
    - Assigned: 0.2·40 + 0.1·10 + 0·10 = 8 + 1 = **9**
    - Started: 0.8·40 + 0.5·10 + 0·10 = 32 + 5 = **37**
    - Finished: 0·40 + 0.4·10 + 1·10 = 4 + 10 = **14**

## Atlantic salmon life cycle
- **River:** Egg → Alevin → Parr → Smolt (1–7 years in the river)
- **Sea:** Smolt → Adult (1–2 years at sea) → adults return to the river to spawn eggs

## Atlantic salmon toy matrix population model
- 3 stages: eggs, juveniles, adults

$$
P = \begin{pmatrix} 0.2 & 0 & 10 \\ 0.2 & 0.3 & 0 \\ 0 & 0.1 & 0.4 \end{pmatrix}
\qquad
n_0 = \begin{pmatrix} 0 \\ 0 \\ 100 \end{pmatrix}
$$

- How to read P:
    - Row 1: eggs stay as eggs with 0.2, each adult produces **10** eggs (fecundity / recruitment)
    - Row 2: 0.2 of eggs become juveniles, 0.3 of juveniles stay juveniles
    - Row 3: 0.1 of juveniles mature into adults, 0.4 of adults survive
- After 1 time step: $P n_0 = (1000,\ 0,\ 40)$
- After 2 time steps: $P^2 n_0 = (600,\ 200,\ 16)$

```r
P <- matrix(c(0.2, 0,   10,
              0.2, 0.3, 0,
              0,   0.1, 0.4), nrow = 3, byrow = TRUE)
n0 <- c(0, 0, 100)
n1 <- P %*% n0   # 1000, 0, 40
n2 <- P %*% n1   # 600, 200, 16
```

## Matrix population models – deterministic use
- In a **deterministic** application we assume population changes follow the "average" (the parameters in the projection matrix)
- Compute the changes by multiplying the **state vector** by the **projection matrix** (matrix multiplication), each time step: $n_{t+1} = P\,n_t$

## Mathematical shortcuts
- The population **growth rate** is the (dominant) **eigenvalue** of the matrix
- The **eigenvector** gives the eventual (stable) proportions of individuals in each stage

### What are eigenvalues and eigenvectors?
- Multiplying a vector by a matrix usually changes both its **size** and its **direction** (i.e. the *mix* of numbers in it)
- An **eigenvector** $v$ is a special vector whose direction **doesn't change** when you multiply by the matrix – it just gets scaled:

$$
P\,v = \lambda\,v
$$

- The scaling factor $\lambda$ (lambda) is the **eigenvalue** belonging to that eigenvector
- A 3×3 matrix has 3 eigenvalues (some may be complex numbers); each has its own eigenvector
- Toy example: $A = \begin{pmatrix} 2 & 0 \\ 0 & 0.5 \end{pmatrix}$
    - $A\begin{pmatrix}1\\0\end{pmatrix} = \begin{pmatrix}2\\0\end{pmatrix}$ → same direction, doubled → eigenvector $(1,0)$, eigenvalue **2**
    - $A\begin{pmatrix}1\\1\end{pmatrix} = \begin{pmatrix}2\\0.5\end{pmatrix}$ → the mix changed → **not** an eigenvector

### What they mean for a population
- Think of the state vector as "**how many** individuals" (size) × "**what mix** of stages" (direction)
- If the population is already in the eigenvector's mix, one time step keeps the **same proportions** in every stage and just multiplies everyone by $\lambda$
    - Each stage grows/shrinks by the same factor → the whole population grows by $\lambda$
- **Dominant eigenvalue** = the one with the largest absolute value. That's the one that matters long-term:
    - Any starting population can be written as a mix of eigenvectors
    - Each time step, each piece gets multiplied by its own $\lambda$
    - After many steps, the piece with the biggest $\lambda$ outgrows (or out-survives) all the others → it takes over
- So, in the long run:
    - Population size changes by a factor of $\lambda$ per step → **asymptotic growth rate**
    - Stage proportions settle to the dominant eigenvector → **stable stage distribution**
- Interpreting $\lambda$:

| Dominant eigenvalue | Long-term behaviour |
|---|---|
| $\lambda > 1$ | Population grows (e.g. λ = 1.05 → +5% per step) |
| $\lambda = 1$ | Population stays the same size |
| $\lambda < 1$ | Population declines (e.g. λ = 0.89 → −11% per step) |

- The eigenvector from R can be any length (and even all negative), so **rescale it to sum to 1** to read it as proportions
- The **shortcut**: instead of simulating many steps to see what happens, one `eigen()` call gives you the long-term growth rate and stage structure directly
- Caveat: this is the **long-term** behaviour. In the first few steps (the **transient** phase) the population can do something quite different, depending on where it started

### Salmon example
```r
e <- eigen(P)
e$values                              # 0.891, then two complex ones with size ~0.50
lambda <- e$values[1]                 # 0.891 → < 1, population declines ~11% per step
v <- Re(e$vectors[, 1]); v / sum(v)   # ≈ 0.710 eggs, 0.241 juveniles, 0.049 adults

# Check: P %*% v equals lambda * v
w <- v / sum(v)
P %*% w        # 0.633, 0.214, 0.044
lambda * w     # 0.633, 0.214, 0.044  ✓ same
```

- Watch it happen by simulating from 100 adults ($n_0 = (0, 0, 100)$):

| Step | Eggs | Juveniles | Adults | Total | Total ÷ previous total | Proportions (E, J, A) |
|---|---|---|---|---|---|---|
| 1 | 1000 | 0 | 40 | 1040 | 10.4 | 0.96, 0, 0.04 |
| 2 | 600 | 200 | 16 | 816 | 0.785 | 0.74, 0.25, 0.02 |
| 3 | 280 | 180 | 26.4 | 486.4 | 0.596 | 0.58, 0.37, 0.05 |
| 5 | 349.6 | 97 | 22.4 | 469.0 | 1.023 | 0.75, 0.21, 0.05 |
| 10 | 179.4 | 60.7 | 12.3 | 252.4 | 0.889 | 0.71, 0.24, 0.05 |
| 20 | 56.0 | 19.0 | 3.9 | 78.9 | 0.891 | 0.71, 0.24, 0.05 |
| 30 | 17.6 | 6.0 | 1.2 | 24.7 | 0.891 | 0.71, 0.24, 0.05 |

- Early steps jump around (the transient phase: a big egg pulse, then a crash)
- By ~step 10, the ratio between steps settles at **0.891 = λ**, and the proportions settle at **(0.71, 0.24, 0.05) = the eigenvector**
- Note the numbers never hit 0, they just keep shrinking by ×0.891 per step (see Limitations below)

### Coursework example
- The coursework matrix has a dominant eigenvalue of exactly **1**, with eigenvector (0, 0, 1)
- Long term: total number of students stays the same (λ = 1), and eventually everyone is in "finished" (the absorbing state, since finished → finished has probability 1)

## Limitations
- Random outcomes such as **random extinction cannot occur**
- Technically the population can **never reach zero** – it only gets closer and closer – so we'd need to define an **extinction threshold** if modelling extinction

### Matrix population models – no extinction?
- Example: a projection matrix shrinking the population from ~10.4 over 80 time steps
    - 10.38, 9.65, 8.98, … 1.02 (t≈33), 0.57 (t≈41), … 0.034 (t≈80)
- It keeps shrinking but **never actually hits zero** → you'd have "0.03 of a fish"

---

# 3. Stochastic adaptation

## Stochastic version
- Deterministic models don't always reflect reality
- We'll run the same kind of age-structured model, but **processes will be stochastic**
- Lets us compare the deterministic and stochastic equivalents
- Question: how do we convert biological parameters inferred from field studies into a stochastic formulation?
- **Think about every process involved/assumed in the model and what probability distribution it is drawn from**

## Dice game – a stochastic salmon model
- Projection matrix (probabilities as dice outcomes) and starting state:

$$
P = \begin{pmatrix} 2/6 & 0 & 3.5 \\ 2/6 & 3/6 & 0 \\ 0 & 1/6 & 4/6 \end{pmatrix}
\qquad
n_0 = \begin{pmatrix} 20 \\ 0 \\ 0 \end{pmatrix}
$$

- Each die = one individual. Each turn, every keeper rolls their dice:
- **Keeper of the eggs**
    - 1 or 2 → die (return to bag)
    - 3 or 4 → stay as eggs (keep them) → 2/6
    - 5 or 6 → mature: give to the keeper of juveniles at end of turn → 2/6
- **Keeper of the juveniles**
    - 1 or 2 → die (return to bag)
    - 3–5 → stay juveniles → 3/6
    - 6 → mature: give to the keeper of adults at end of turn → 1/6
- **Keeper of the adults**
    - Sum the numbers on all your dice (whether they die or not) and give that many dice from the bag to the keeper of eggs → average roll = **3.5** eggs per adult
    - 1 or 2 → die (return to bag); 3–6 survive → 4/6
- Same *average* behaviour as the deterministic matrix, but now outcomes are whole numbers, vary between runs, and the population **can actually go extinct**

---
---

# Lecture 3 – Populations (second part)

## Lecture outline
1. Making a deterministic matrix model stochastic: survival & maturation, recruitment, applying processes in turn
2. The resulting stochastic demographic model: pros and cons
3. Eigenvectors and eigenvalues, why they give the long-term behaviour
4. Real-world examples: bog turtle, Chinese mitten crab, Atlantic salmon

> **Coursework link:** sections 1–2 are *exactly* how the provided `code/Demographic.R` works (Part 1). See also [Part1_Demographic_model.md](Part1_Demographic_model.md).

---

# 1. Making a deterministic model stochastic

Example matrix used throughout (3 stages; column = from, row = to):

$$
P = \begin{pmatrix} 0.1 & 0 & 3.5 \\ 0.5 & 0.4 & 0 \\ 0 & 0.3 & 0.6 \end{pmatrix}
$$

- Survival/maturation probabilities: every entry except the 3.5
- Recruitment rate: 3.5 = mean offspring per adult per time step (top-right)

## Survival and maturation

### What the deterministic model says (expectation)
Suppose there are **10 individuals in stage 2**. Column 2 of the matrix tells us that at the next time step **we expect**:
- a proportion **0.4** to still be in stage 2 → **4 stay**
- a proportion **0.3** to have matured into stage 3 → **3 mature**
- the remaining proportion **0.3** (= 1 − 0.4 − 0.3) to have died → **3 die**

### What the stochastic model does (probability)
Instead of exact proportions, we consider the **probability** of each of the three events (stay, mature, die) for **every individual**:

$$P(\text{stay in stage 2}) = 0.4 \qquad P(\text{mature into stage 3}) = 0.3 \qquad P(\text{die}) = 0.3$$

So with 10 individuals in stage 2 we draw the outcomes from a **multinomial distribution**:

$$(N_\text{stay},\ N_\text{mature},\ N_\text{die}) \sim \text{Multinomial}(n = 10,\ p = (0.4, 0.3, 0.3))$$

- The three counts always add up to 10 (every individual has exactly one fate)
- On average we get (4, 3, 3), but we could get e.g. (5, 1, 4) or (2, 4, 4)
- **Compare with stochastic population growth (Lecture 2):** each bacterium reproduces with probability 0.1, so $n_{t+1} = n_t + \text{Binomial}(n = n_t,\ p = 0.1)$
    - Binomial = **2** possible outcomes per individual (reproduce or not)
    - Multinomial = **more than 2** outcomes per individual (stay / mature / die). The binomial is the special case with 2 outcomes.

### Applying it to all life stages
Do the same draw for **each stage**, using that stage's **column**, then add the results into the right **rows** of the new state vector:

| Stage (column) | Probabilities used | Example draw | Goes into |
|---|---|---|---|
| Stage 1 | stay 0.1, mature 0.5 (die 0.4) | $N_\text{stay} = 5$, $N_\text{mature} = 27$ | 5 → stage 1, 27 → stage 2 |
| Stage 2 | stay 0.4, mature 0.3 (die 0.3) | $N_\text{stay} = 10$, $N_\text{mature} = 8$ | 10 → stage 2, 8 → stage 3 |
| Stage 3 | stay (survive) 0.6 (die 0.4), **cannot mature** | $N_\text{stay} = 14$ | 14 → stage 3 |

$$
n_{t+1} \text{ (before recruitment)} = \begin{pmatrix} 5 \\ 27 + 10 \\ 8 + 14 \end{pmatrix} = \begin{pmatrix} 5 \\ 37 \\ 22 \end{pmatrix}
$$

- This **doesn't include recruitment yet**: the 3.5 was ignored because it is not survival or maturation
- In the code: `survival_maturation()` loops over stages, calls `multinomial()` on each column and adds the results (`new_state + individuals_count`)

## Recruitment

### What the deterministic model says
Suppose there are **5 individuals in stage 3** (adults). The matrix says we **expect** each to produce **3.5** new offspring (in stage 1):

$$5 \times 3.5 = 17.5 \text{ offspring}$$

### The problem
In a stochastic model we need two separate things:
1. the **probability that a given adult recruits** (reproduces or not), and
2. the **probability distribution of clutch/litter size** (how many offspring when it does)

But the matrix has **conflated** them into one number, 3.5, the **recruitment rate**. We need to know them **separately**, so we need **extra data**.

### The fix: use a clutch-size distribution from field studies
Suppose field studies give the clutch size distribution (sizes 1 to 9):

$$(0.06,\ 0.08,\ 0.13,\ 0.15,\ 0.16,\ 0.18,\ 0.15,\ 0.06,\ 0.03)$$

(This is the same distribution as the coursework's default `clutch_distribution`.)

1. **Expected clutch size** (the mean of the distribution):
$$E(\text{clutch size}) = \sum_n n \, P(\text{clutch size} = n)$$
   - For this distribution: $1(0.06) + 2(0.08) + \dots + 9(0.03) = 4.89$
2. **Individual recruitment probability**:
$$P(\text{recruit}) = \frac{3.5}{E(\text{clutch size})}$$
   - Chosen so that $P(\text{recruit}) \times E(\text{clutch size}) = 3.5$, so the stochastic model has the **same average** as the deterministic one
   - Must be ≤ 1, otherwise the parameters are inconsistent
   - (With 3.5 and 4.89 this gives 0.716. For the coursework, 2.6/4.89 = 0.532.)

### Worked example (from the slides)
Suppose $E(\text{clutch size}) = 7$, so $P(\text{recruit}) = 3.5 / 7 = 0.5$.
1. Draw the **number of adults that recruit**: $N_\text{recruit} \sim \text{Bin}(n = 5,\ p = 0.5)$ → suppose $N_\text{recruit} = 2$
2. For **each** recruiting adult, draw a clutch size from the distribution → suppose **9** and **4**
3. Total offspring = 9 + 4 = **13** (the deterministic model says 17.5; on average they agree)

In the code, `stochastic_recruitment()` computes $P(\text{recruit})$ and `offspring_calc()` does steps 1–3 (`rbinom` + `random_draw` per clutch).

## Applying processes in turn
- **Challenge:** in a stochastic simulation the processes must be applied **one by one**. This feels counterintuitive, because in the deterministic model everything happens **at the same time** (one matrix multiplication).
- The trick is that both processes are computed from the **current** population:

```
                    current population
                    /                \
  offspring produced by          current population after
  CURRENT population       +     survival & maturation applied     =   new population
  (recruitment)                  (multinomial per stage)
```

- Recruitment uses the adults at the **start** of the step (even those that die during the step still breed), which matches the deterministic $P\,n_t$
- In the code: `stochastic_step()` calls `survival_maturation(state, …)` and `offspring_calc(state, …)` on the **same** `state`, then adds the offspring to stage 1

---

# 2. The resulting model: a stochastic demographic population model

- **Stochastic** because processes are drawn from random distributions
- **Demographic** because the population is structured by life stage (a demographic trait)

| Pros | Cons |
|---|---|
| In general a **better reflection of reality** than the deterministic model (as long as we run it many times to observe outcomes) | Needs to be **run many times** to see a representative sample of outcomes (hence HPC) |
| We can observe **random extinction**: the population can reach zero, so we can compute **extinction probability** | **More awkward to code** than the deterministic matrix model |
| | Requires **additional data** to simulate correctly (the clutch size distribution) |

> Coursework Part 1: panel a = deterministic vs stochastic runs; panel b = extinction probability from many runs on the HPC. Both follow from this pros/cons table.

---

# 3. Eigenvectors and eigenvalues, revisited

## Recap: salmon toy model
Stages: eggs, juveniles, adults.

$$
A = \begin{pmatrix} 0.2 & 0 & 10 \\ 0.2 & 0.3 & 0 \\ 0 & 0.1 & 0.4 \end{pmatrix}
\qquad
v = \begin{pmatrix} 0 \\ 0 \\ 100 \end{pmatrix}
\qquad
Av = \begin{pmatrix} 1000 \\ 0 \\ 40 \end{pmatrix}
\qquad
A^2 v = \begin{pmatrix} 600 \\ 200 \\ 16 \end{pmatrix}
$$

- After $t$ time steps the state is $A^t v$

## Definition

$$A v = \lambda v$$

- $A$ = the **matrix**, $v$ = an **eigenvector**, $\lambda$ = its **eigenvalue** (a single number)
- Multiplying an eigenvector by the matrix gives back the **same vector, just scaled** by $\lambda$

## Why this matters for populations
If the population **starts** as an eigenvector $v$:

| Time step | State | Simplifies to |
|---|---|---|
| 1 | $v$ | $= v$ |
| 2 | $Av$ | $= \lambda v$ |
| 3 | $A \lambda v$ | $= \lambda A v = \lambda^2 v$ |
| 4 | $A \lambda^2 v$ | $= \lambda^2 A v = \lambda^3 v$ |
| 5 | $A \lambda^3 v$ | $= \lambda^3 A v = \lambda^4 v$ |

- The **proportions in each stage never change**; the whole population is just multiplied by $\lambda$ every step
- $\lambda > 1$: grows, $\lambda = 1$: stable, $\lambda < 1$: shrinks

## Any starting population
A 3-stage matrix has **3 eigenvectors**, each with its own eigenvalue:

$$A v_1 = \lambda_1 v_1 \qquad A v_2 = \lambda_2 v_2 \qquad A v_3 = \lambda_3 v_3$$

**Any** starting state $v$ can be written as a mix of them:

$$v = x v_1 + y v_2 + z v_3$$

Apply the matrix (it can be applied to each part separately):

$$
\begin{aligned}
Av &= A(x v_1 + y v_2 + z v_3) \\
   &= x A v_1 + y A v_2 + z A v_3 \\
   &= x \lambda_1 v_1 + y \lambda_2 v_2 + z \lambda_3 v_3
\end{aligned}
$$

and after $t$ steps:

$$A^t v = x \lambda_1^{\,t} v_1 + y \lambda_2^{\,t} v_2 + z \lambda_3^{\,t} v_3$$

**Key consequence:** raising to the power $t$ makes the term with the **largest** eigenvalue ($\lambda_1$, the *dominant* eigenvalue) grow fastest, so for large $t$ it **swamps** the others:

$$A^t v \approx x \lambda_1^{\,t} v_1$$

- $\lambda_1$ = **long-term growth rate** of the population
- $v_1$ = **stable stage distribution** (long-term proportions in each stage)
- The other terms explain the **transient** behaviour at the start (e.g. the early dip in the coursework model before adults are replaced)
- Coursework default matrix: $\lambda_1 \approx 1.039$, so ≈ 3.9 % growth per month in the long run (`eigen(projection_matrix)`)

---

# 4. Matrix population models in the real world

## Why use them?
- They model **population dynamics** (hard to observe) from **individual-level processes** (easier to observe: who survives, who matures, how many offspring)
- Parameters can be inferred from field studies such as **capture–mark–recapture**
- **Online databases of matrices** give field-based evidence for many populations:
    - **COMPADRE** (plants): v6.22.5.0, 760 species, 643 publications, 8851 matrix models
    - **COMADRE** (animals): v4.21.8.0, 415 species, 395 publications, 3317 matrix models

## Example 1: Bog turtle (*Glyptemys muhlenbergii*) conservation, USA
*Knoerr et al. (2022), Population models reveal the importance of early life-stages for population stability of an imperiled turtle species, Animal Conservation 25: 53–64. https://doi.org/10.1111/acv.12718*

$$
A = \begin{pmatrix} 0 & 0 & F_3 \\ P_{21} & P_{22} & 0 \\ 0 & P_{32} & P_{33} \end{pmatrix}
\qquad
F_3 = (\text{avg. clutch size}) \times (\text{avg. clutch frequency}) \times (\text{adult survival}) \times 0.5
$$

- 3-stage model; $P_{ij}$ = survival/transition probabilities, $F_3$ = adult fecundity
- The 0.5 counts only female offspring (a female-only model)
- Like the 3.5 in the lecture, $F_3$ combines several processes into **one rate**
- They compared **λ at different sites** under management scenarios: site-specific egg survival, regional average egg survival, caged nests, artificial incubation with immediate release, and **head-starting**
- Most sites have λ < 1 (declining). Protecting **early life stages** (especially head-starting) pushes λ up, above 1 at several sites
- Lesson: λ is used as a single summary of whether a population will grow or decline, and to **rank conservation actions**

## Example 2: Invasive Chinese mitten crab control, North America & Europe
*Zhang, Yokota & Strüssmann (2019), A periodic matrix population model to predict growth potential of the invasive Chinese mitten crab Eriocheir sinensis, J. Crustac. Biol. 39(1): 28–35. https://doi.org/10.1093/jcbiol/ruy090*

- **Periodic** matrix model: separate **summer** and **winter** matrices, applied alternately (seasonal life cycle)
- Stages: juvenile (larvae), small, mid-size, large
- Simulated removal (harvesting) from year 20:
    - **S2** = proportion of mid-size crabs removed during summer
    - **W3** = proportion of large crabs removed before reproduction in winter
- With low removal the population keeps growing exponentially. Higher S2 and W3 make it **decline**.
- Lesson: the model can find **how much control effort** is needed to stop an invasion

## Example 3: Atlantic salmon thermal niche modelling
*Morris, Bárðarson, González-Ferreras, Lauridsen, Pawar, Rosindell & Woodward, Climatic limits to Atlantic salmon population fitness at continental scales (bioRxiv preprint).*

- A **MIPM** (metabolic integral projection model): like a matrix model, but the population is structured by **continuous body mass** instead of discrete stages
- **Temperature** (daily thermal regime, including seasonal fluctuations) drives **growth**, **survival** and **fecundity**, which depend on body mass
- Output: $r_\text{max}$ (population growth potential) vs temperature, for different **resource levels**
    - Hump-shaped: an optimum temperature (~15 °C), with fitness falling at higher temperatures
    - Less food (25 % or 50 % reduction) gives lower $r_\text{max}$ and a narrower thermal niche
    - **Fluctuating** temperatures (dashed) do worse than constant mean temperatures (solid), especially when warm
- Lesson: individual physiology can be scaled up to population fitness, which allows **predictions under climate change**

---

# Summary
- Stochastic version of a matrix population model:
    - survival/maturation: **multinomial** draw per stage
    - recruitment: **binomial** number of breeders × random clutch sizes
    - both computed from the current population, then combined
- Eigenvectors and eigenvalues: the dominant eigenvalue = long-term growth rate, its eigenvector = stable stage distribution
- Real-world uses: conservation (bog turtle), invasive species control (mitten crab), climate change (salmon)