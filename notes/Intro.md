# Lecture 1 – Introduction to scientific computing and simulation for Ecology and Evolution
*James Rosindell*

## A brief history of computing power
| Machine | Date | Energy use | FLOPS | Space | Cost |
|---|---|---|---|---|---|
| Antikythera mechanism | 89 BCE | zero | zero | 0.0055 m³ | – |
| Difference engine | 1842 CE | zero | 1 | 3.6 m³ | £17,000 |
| Tianhe-2 (天河-2) supercomputer | 2013 | 24 MW | 4 × 10¹⁵ | 720 m² | $390 M |
| Nvidia Rubin GPU (named after Vera Rubin) | 2026 | 1.4 kW | 5 × 10¹⁶ | 38 cm² | $55,000 |

- Takeaway: a single 2026 GPU beats a 2013 supercomputer by >10× in FLOPS, at a tiny fraction of the energy, space and cost

## Module objectives
- High-throughput computing
- Demonstrate good programming practice in R
- Build simulations of populations and communities
- Evaluate stochastic and deterministic alternatives
- Create a simulation model to answer a question

## Module structure
1. Introduction
2. & 3. Populations (matrix population models + applications)
4. & 5. Communities (ecological neutral theory + applications)
6. Microproject
7. Coalescence algorithms
8. Database and web app

### Timetable highlights
- **Mon 16/11** – Lecture: introduction; Lecture: matrix population models; Interactive: using distributed computing; Lab pract.; Interactive: coding skills
- **Wed 18/11** – Drop-in lab; Lecture: applications of matrix population models; Lecture: ecological neutral theory
- **Thu 19/11** – Drop-in lab; Lecture: applications of neutral theory; Lab pract. (afternoon)
- **Mon 23/11** – Drop-in lab; Lecture: microproject introduction; Lab pract.; Interactive: project ideas brainstorm
- **Thu 26/11** – Drop-in lab; Lecture: coalescence; Interactive: peer group feedback (afternoon)
- **Fri 27/11** – Drop-in lab; Lecture: database and web app example; Lab pract.
- **Mon 30/11** – Drop-in lab; Interactive: peer group feedback; Lab pract.
- **Thu 03/12 & Fri 04/12** – Lab pract.

## The worksheet & AI
- Old (2021) worksheet questions (e.g. recursive `turtle` → `elbow` → `spiral` → `tree` → `fern` drawing functions in R) can now be solved by Copilot in seconds (tree in 16 s, fern in 3 prompts)
- So the **2026 worksheet** is different. Key points:
    - **Process not result**
        - GitHub history
        - Development diary
    - **Harder problems**
        - More thinking
        - More testing
        - More project-like
    - **Use AI (but…)**
        - Iteration is needed
    - **Come along in person!**

### Worksheet overview
- **Part 1 – Stochastic demographic population model**
    - Compare stochastic and deterministic versions of a demographic population model with different initial population sizes, and estimate extinction probability using high-throughput computing
    - Expected findings: smaller initial populations show much higher extinction risk; stochastic simulations vary widely, especially at low population sizes; the deterministic model predicts persistence → highlights the role of demographic stochasticity
- **Part 2 – Neutral model of an ecological community**
    - Simulate a neutral model, characterise community structure, and examine how initial conditions (max vs min initial richness) affect species richness and the species abundance distribution
    - Expected findings: richness rises from low initial richness and falls slightly from high, converging to a similar equilibrium; species abundance distributions are broadly similar at equilibrium
- **Part 3 – Individual-based model of community assembly**
    - Design, simulate and analyse an individual-based model inspired by neutral theory to address a clear biological question using HPC
    - Example: effect of habitat structure and niche preference on community assembly
- **Key parameters**
    - Part 1: initial population sizes 3, 10, 30, 100; time steps (time series) 24; extinction assessment at 120; cluster jobs 20; simulations per job 40
    - Part 2: community size J = 100; time series duration T = 200; speciation rate ν = 0.1
- **Computational workflow**: develop & test locally → submit array jobs to HPC cluster → run many simulations in parallel → save results (`.rda` files) → analyse and visualise → write report and document
- **Assessment checklist**
    - GitHub repo with code, README, tests, scripts and sample output files
    - Development diary (≥ 10 dated entries, AI use documented)
    - Final PDF with results from parts 1–3 (≤ 1500 words, 4 figures)
    - High-throughput computing used (parts 1 & 3)
    - Reproducible code that runs without errors
    - Clear figures with captions, titles and axis labels
    - Interpretation of results with biological insight
    - Literature references (part 3)

## High Performance Computing (HPC)
- Traditionally, HPC could include supercomputers or computer clusters
- Nowadays, a "supercomputer" is typically a parallel system – parallelisation is the most efficient way to increase power
- So HPC almost always refers to **parallel computing**
- Different forms:
    - A single computer with many processors
    - **A cluster of many ordinary computers** ← what we use
    - Many computers which access a shared memory

### What is parallel computing?
- When many computations are carried out simultaneously
- Variants:
    - One computer → several processors each running an independent task → results back to the computer
    - Processors run tasks (1a, 2a…) → write to **shared memory** → next round of tasks (1b, 2b…) → shared memory → …
    - On HPC: your remote command line on the HPC service → **nodes** each run a task → results land in your remote area

### Analogy: counting sheep
- Counting a flock of sheep alone is slow; split the flock into 6 groups, give each to a different counter, then add the results
- 43 + 14 + 30 + 17 + 19 + 17 = **140 sheep**
- That is parallel computing: split the job, work at the same time, combine at the end

### What kinds of tasks benefit from HPC?
- Some tasks lend themselves easily to parallelisation
    - "embarrassingly parallel" / "perfectly parallel"
    - 3D computer graphics rendering – every pixel is independent but there are **a lot** of pixels
    - Matrix multiplication (and AI!)
    - **Simulations which need to be run with many different parameters** ← us
    - **Stochastic simulations** ← us
- Some tasks are less well-suited to parallelisation
    - "inherently serial" – each step needs to run in series
    - Fluid dynamics (and solving other systems of differential equations)
    - Algorithms

### GPU vs many CPUs – an analogy
- **GPU** = an army marching in step: thousands of simple units all doing the *same* operation at once (great for matrix maths/graphics/AI)
- **Many CPUs** = a team of builders on a construction site: fewer workers, but each can do a *different*, more complex job independently

### More tasks that benefit from HPC
- Tasks where we need more memory than our local machine can handle
    - e.g. analysing or visualising very large data sets
- **Tasks where we need to do a relatively simple operation for a long time or with many different parameters** ← us
    - Called "high-throughput computing" or **HTC**
- **Tasks which can be automated** ← us
    - This frees up our own machine to do other things
- There is always a trade-off: getting jobs set up on the cluster is time-consuming in and of itself

## How do you parallelise your code?
- `as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))`
    - Use this in your code to give a **simulation number**
    - Before: one long simulation. Now: many simulations (1, 2, 3, …) running side by side

```r
# Using your PC: run simulations one after another
for (i in 1:10) {
  do_simulation(i)
}

# Using HPC: a shell script on the cluster launches 10 copies of this script,
# each getting a different PBS_ARRAY_INDEX
i <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))
do_simulation(i)
```

### Random seeds
- e.g. `sample(c("heads","tails"), 1)` – a coin flip
- Pseudorandom numbers
    - Appear random but aren't really
    - Given a certain random number seed, you get the **same sequence** of random numbers every time
    - Before (one simulation): any seed is fine. Now: if parallel simulations share a seed they produce identical "random" results!
    - **Each simulation should have a different seed** (e.g. seed = 1, 2, 3 for simulations 1, 2, 3)

```r
do_simulation <- function(i) {
  # set random seed as i
  # select your simulation parameters
  # do your simulation
  # save your output in a file named ...i...
  # include a timer
}
```

## The Imperial HPC cluster
- `login.hpc.imperial.ac.uk`
- Access via Login (ssh), RStudio, or Jupyter
- The **login node** is your portal to HPC → you submit jobs to a **queue** → the queue sends them to the compute nodes

### How jobs are run
- What we might think: all jobs start and finish at the same time
- What really happens: jobs start at staggered times depending on when nodes become free in the queue, so they finish at different times

## Handling memory
- Save your results in memory and then write to disk at the end
- Output your code to a series of files (e.g. `Output1.rda`, `Output2.rda`, `Output3.rda`)
- Write local code to read in your series of files automatically
- Use the array index to set both the seed **and** the parameters, e.g.:

| Seed (i) | X (parameter) | Output |
|---|---|---|
| 1 | 50 | Output1.rda |
| 2 | 50 | Output2.rda |
| 3 | 21 | Output3.rda |
| 4 | 21 | Output4.rda |

- Build a timer into your code
- Test your code locally to know your memory and time requirements
