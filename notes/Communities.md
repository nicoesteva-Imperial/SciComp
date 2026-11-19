# Lecture 4 – Communities (first part): Ecological Neutral Theory

*James Rosindell*

## Lecture outline
1. What is neutral theory?
2. Example neutral models (voter model, the basic neutral model, variations)
3. Uses of neutral theory: understanding vs predicting

> **Coursework link:** Part 2 of the coursework is a **neutral model of an ecological community** (own code, must run in ≤ 1 min). The slide marked "Your exercise questions" (section 2) is exactly that model: **zero-sum + point-mutation speciation + non-spatial**. Species abundances binned in powers of 2 (**octaves**, section 3) are also used in Part 2.

---

# 1. What is neutral theory?

## Definition
**Ecological neutral theory assumes all individuals are ecologically equivalent.**

Key references: Caswell 1976; Hubbell 1979, 1997, 2001; Bell 2000, 2001.

## Madness or misunderstood?
Neutral theory has been controversial:
- *"This flies in the face of years of ecological theory (supported by data) maintaining that species are not ecologically equivalent"* – Jerry Coyne
- *"A preoccupation with neutral theory could marginalize biodiversity science, competing for resources with process-based studies, while having little to offer conservation and policy."* – Jim Clark
- *"It's probably the most misunderstood theory in contemporary ecology"* – Arne Schröder

## What "theory" means: physics vs ecology
- **Physics:** a scientific theory conforms with empirical data **and** puts forward an **explanation** for observed phenomena
    - e.g. Newton's law of gravitation $F = G \dfrac{m_1 m_2}{r^2}$
- **Ecology:** "theory" often means **any ecological work that uses mathematical formulas or a computer**
    - It is often **not an explanation** but a **description or generalisation**

## What neutral theory is, and isn't
- It **assumes** all individuals are ecologically equivalent
- It is **not a claim** that all individuals *are* ecologically equivalent
- It is about **making some assumptions and seeing where they get us**

## Common misconceptions
All three of these are **wrong** (crossed out on the slides):

| ✗ Misconception | Why it's wrong |
|---|---|
| "Neutral model" can be used interchangeably with "null model" | A neutral model is a specific kind of model; a null model is any baseline model for comparison. Neutral models *can* be used as null models, but the terms aren't synonyms. |
| Neutral models assume all species are the same | They assume **individuals** have the same demographic rules, whatever their species. Species can still differ in abundance, range, etc. as an *outcome*. |
| A model in which species are interchangeable is neutral | Interchangeable species is not enough; neutrality is about **individuals' demographic properties** not depending on species. |

✓ **Correct definition:** *the demographic properties of an individual (birth, death, dispersal, speciation) are independent of its species identity.*

---

# 2. Example neutral models

## The voter model (Holley & Liggett 1975)
A model from social science / statistical physics:
- Pick a random neighbour
- You take their view or they take yours
- Keep going for a while and see what happens

**Relating it to biology:**
- Political view → **species identity**
- People → **places in space where an individual could live**
- Dispersal is over **very short distances** (only neighbours)

**What we found (in the class exercise):**
- Some **impenetrable clumps** form
- There are **edge effects**
- **Eventually everyone in each connected group holds the same view**, so diversity is lost (one species takes over)
- **Hence we introduced mutation** (= speciation), which brings in new species and keeps diversity going

## The neutral model rules in brief
Picture a community as a grid of sites, each holding exactly one individual (tree) of some species:

1. **Death:** pick a random individual; it **dies**, leaving an empty site
2. **Replacement**, either:
    - **Birth/dispersal** (most of the time): the gap is filled by the **offspring of another randomly chosen individual**. The new individual is the parent's species.
    - **Speciation** (with a small probability, the speciation rate ν): the gap is filled by an individual of a **brand-new species** never seen before
3. Repeat many times

- No species has any advantage: who dies and who reproduces is **random**, independent of species (the neutral assumption)
- Species abundances change only by **ecological drift** (chance), like genetic drift in population genetics
- Species are lost by drift (extinction) and gained by speciation, which gives a **dynamic equilibrium** of species richness

## Variations on the theme
Neutral models differ in three main choices:

### 1. The zero-sum assumption
- **Non-zero-sum:** the total number of individuals can fluctuate
- **Zero-sum:** the community is always **full** (a fixed number of individuals, *J*). Every death is immediately followed by a birth into the gap, so the total never changes.
    - This is the version drawn as a grid with one empty (blue) site being refilled

### 2. Speciation mode
How do new species arise?

| Mode | How it works | References |
|---|---|---|
| **None** | No speciation: diversity can only decline (like the voter model) | Caswell 1976; Bell 2000, 2001 |
| **Point mutation** | A **single individual** becomes a new species instantly | Hubbell 1997, 2001 |
| **Random fission** | A **group** of individuals splits off as a new species at once | Hubbell 2001; Hubbell & Lake 2002 |
| **Protracted** | Speciation **takes time**: an incipient lineage only counts as a new species after a number of generations | Rosindell et al. 2010 |

### 3. Spatial structure
| Structure | Description | References |
|---|---|---|
| **Non-spatial** | One well-mixed community, just counts per species (e.g. 5, 4, 8, 3) | Caswell 1976 |
| **Spatially implicit** | A large **metacommunity** (e.g. 215, 454, 428, 233) supplies immigrants by **dispersal** into a small **local community** (5, 4, 8, 3), like island biogeography | MacArthur & Wilson 1963; Hubbell 2001 |
| **Spatially explicit network** | Several local communities (patches) connected by dispersal links | Economo & Keitt 2008; Muneepeerakul et al. 2008; Warren 2010; Vanpeteghem & Haegeman 2010 |
| **Fully spatially explicit** | Individuals have positions in continuous space; offspring disperse according to a **dispersal kernel** (probability decreasing with distance) | Holley & Liggett 1975; Durrett & Levin 1996; Bramson et al. 1998; Hubbell 2001; Chave et al. 2002; Chave & Leigh 2002; Zillio et al. 2005; Rosindell & Cornell 2007, 2009; Pigolotti & Cencini 2009; O'Dwyer & Green 2010; Etienne & Rosindell 2011 |

### Which combination is which?
- **Hubbell's (2001) model:** zero-sum + point mutation + spatially implicit (metacommunity → local community) (Hubbell 2001; Leigh 2007; Leigh et al. 2010)
- **Your exercise questions (coursework Part 2):** **zero-sum + point mutation + non-spatial**

*(Slides 35–36 are photos of a cheese stall and some plain crackers, with no text. My guess: many rich variants vs the plain, simple basic model. Check what was said in the lecture.)*

---

# 3. Uses of neutral theory

> *"Essentially, all models are wrong, but some are useful."* – George E. P. Box (Box & Draper 1987)

- All models can fail when challenged with data, and **that's OK**
- Models are useful in two ways:
    1. **Helping to understand**
    2. **Helping to predict**

## Useful for understanding
- **Data** come from a **mixture of processes**; a **model** is a mixture of processes that we **can tweak**
- Approach: compare several candidate models (A, B, C) with the data
    - Models that **don't fit** the data are **rejected** (✗)
    - The **neutral model** is a natural candidate: the simplest model with no species differences
- If the neutral model fails with some data, it tells us **which non-neutral process matters**
- With **more and different data**, models get refined (e.g. Model A → A+), and the neutral model can be **revised** too (e.g. a new speciation mode)
- Understanding comes from this **cycle of comparing models with data, rejecting and revising**

### Example data comparison 1: species abundance distributions (SADs)
*Hubbell 2001, tropical forest trees*
- **x-axis:** number of individuals per species, binned in **powers of 2** (1, 2, 4, 8, …, 512) = **octaves**
- **y-axis:** number of species in each bin
- **Observed** data (bars) compared with:
    - a **lognormal** distribution (dashed): underestimates the **rare** species (the 1–2 individual bins)
    - Hubbell's **unified neutral theory** (solid, θ = 180, m = 0.15): fits well, including the rare species
- θ = fundamental biodiversity number (linked to speciation rate × metacommunity size); m = immigration probability *(these definitions come from Hubbell 2001; they aren't on the slide)*
- So neutral theory can **reproduce real abundance patterns** with very few parameters

### Example data comparison 2: species lifetimes
- Problem: with **point mutation** speciation, the neutral model predicts **mean species lifetimes that are far too short** compared with the fossil record (Ricklefs 2003, 2006; Nee 2005)
- **But that was for point mutation speciation**, so the neutral model was revised →

### Protracted speciation (Rosindell et al. 2010)
- Speciation is **not an instantaneous event**
- The slides show a row of lizards (one species): a small change appears in one individual, spreads to a few individuals, and builds up gradually until a **group** becomes a fully distinct new species
- In the model, a new lineage must survive a **period of time** before it counts as a species

### Tropical forest tree data (BCI = Barro Colorado Island, Panama)
*(The slide has no legend; the colours below are my reading, based on the previous slide's point that point mutation gives lifetimes that are too short.)*
- **SAD (left):** both the point-mutation and the protracted model fit the abundance data well
- **Species lifetimes (right), vs metacommunity size:**
    - **Point mutation** (red): lifetimes stay short (~10–20) whatever the metacommunity size
    - **Protracted** (green): lifetimes are **much longer** and increase strongly with metacommunity size, so they are **more realistic**
- Lesson: data that look the same (SAD) can't tell models apart, but **other data** (lifetimes) can. Revising the speciation mode fixed the problem while keeping the good SAD fit.

## Useful for predicting
- A model takes the current state (a forest now) and predicts a future or unobserved one
- A predictive model can be built from:
    - **processes that mean something** (mechanistic), and/or
    - **phenomenological / pure statistics** (curve fitting)
- A **neutral model** is built **only from processes that mean something** (birth, death, dispersal, speciation), so its parameters are interpretable

### Example: species–area relationships (SARs)
- Plot **log number of species vs log area**: the curve has **three phases**
    1. **Small areas** (a forest plot): richness rises steeply
    2. **Intermediate areas** (a region/landscape): a shallower, roughly straight line (classic power law)
    3. **Very large areas** (continents): steep again, as you include different biogeographic regions
- A **spatially explicit neutral model** produces this **triphasic** SAR (Rosindell & Cornell 2009)
    - On rescaled axes the curves collapse onto one line at small/intermediate scales and fan out at large scales depending on parameters
- So neutral theory **explains species–area relationships** and other spatial biodiversity patterns, from first principles

## The real issues
- The link between **pattern and process**: the same pattern can come from different processes
- The **realism vs instrumentalism** perspectives: should a model be *true* (realism) or just *useful* for prediction (instrumentalism)?
- The **trade-off between simplicity and complexity**

---

# What have we learned about modelling?
- John von Neumann: *"Give me four parameters, and I can fit an elephant. Give me five, and I can wiggle its trunk."*
    - Mayer, Khairy & Howard (2010) actually did it: "Drawing an elephant with four complex parameters", *Am. J. Phys.* 78, 648, doi:10.1119/1.3254017
    - Lesson: with enough parameters **anything fits**, so a good fit alone proves nothing
- **Theories in biology and in physics are very different**
- Modelling for **making predictions** and for **gaining understanding** are **two different types of exercise**
- **Not all data are very informative** (e.g. the SAD couldn't distinguish speciation modes)
- **Simplicity vs complexity:** only add complexity when it's needed; use computers when needed
- **Start with the end in mind**

# Neutral theory: conclusions
- Neutral theory is a **collection of neutral models** assuming the **demographic properties of an individual are independent of its species identity**
- Useful for **understanding** and **predicting**, but **not both at the same time**
- **Explains species–area relationships** and other spatial biodiversity patterns
- Makes rich predictions about **biodiversity and endemicity on islands**
- Neutral theory is **one of many useful tools** in your toolbox

---
---

# Lecture 5 – Communities (second part): Applications of neutral theory in ecology and evolution

*James Rosindell*

## Lecture outline
1. Recap of the model rules
2. Islands: dynamic equilibrium, island biogeography, protracted speciation on islands
3. Radiation cascades (mainland–archipelago)
4. How many species go extinct when habitat is lost? (extinction debt, fragmentation, effective area, effective connectivity)

> **Coursework link:** this lecture is mainly useful for **Part 3 (microproject)**. The brief's list of project ideas includes **habitat loss & extinction**, **spatial structure** and **protracted/variable speciation**, and all three come up here. The model recap (section 1) is the same neutral step as in **Part 2**.

---

# 1. Recap: the model rules in brief (slides 2–7)
The same grid of trees as in Lecture 4, shown step by step:
1. A random individual **dies**, leaving an empty site (blue square)
2. The gap is filled either by:
    - the **offspring of another individual** (blue arrow from a parent tree), so the new tree is the parent's species, **or**
    - **speciation** (blue lightning bolt): a tree of a **brand-new species** appears
3. Repeat

---

# 2. Islands and neutral theory

## Dynamic equilibrium (slides 8–10)
- **Without speciation (an island fed by a mainland):** species richness is a **balance between immigration and extinction**
- **With speciation:** a **balance between speciation (+ immigration) and extinction**
- In both cases **the species themselves keep changing** (turnover): the *number* of species settles, but *which* species are present doesn't
- Slide 10 shows species richness through time:
    - **red** shading = richness still climbing towards equilibrium
    - **green** shading = at equilibrium (fluctuating around a constant level)
    - top: the system is repeatedly knocked back and has to climb again; bottom: one climb, then a long equilibrium
    - *(no legend on the slide; this is my reading of the colours)*
- **Link to Part 2:** this is exactly why you need a **burn-in** before collecting octave data. Panel a's richness time series should show this climb (or fall) to a dynamic equilibrium.

## Two theories of islands (slides 11–12)
| Theory | Processes | Notes |
|---|---|---|
| **MacArthur & Wilson's Theory of Island Biogeography (1967)** | **Immigration** onto the island and **extinction** on it | No speciation: all island species come from the mainland |
| **Hubbell's Unified Neutral Theory of Biodiversity and Biogeography (2001)** | **Immigration**, **extinction** and **speciation** (on both the mainland and the island) | Speciation is added in **both** places |

## Protracted speciation on islands (slides 13–17)
Lizard diagrams (green = original species, red = new form, blue funnel = a lineage diverging over time):
- **Unstructured** (one big population): a new form appears in one individual and **spreads gradually** until it is a separate species (protracted speciation, as in Lecture 4)
- **Mainland + island:** a small population on the island starts diverging from the mainland form
    - if **immigration** from the mainland keeps arriving (green arrow), the island population is pulled back towards the mainland form
    - only if divergence **outpaces immigration** does the island population become a new species
- So with protracted speciation, **isolation (low immigration) and island size** decide whether new species form on an island

Three kinds of island species:
| Type | Meaning |
|---|---|
| **Immigrant** | Same species as on the mainland (arrived and hasn't diverged) |
| **Anagenetic** | Diverged into a new species on the island **without splitting** (one mainland species → one island species) |
| **Cladogenetic** | Diverged **and split** on the island into several species (an in-situ radiation, e.g. Darwin's finches) |

## Empirical data: island birds (slide 18)
3-D plots of **ln(S + 1)** (number of species) vs **ln(A)** (island area) and **ln(D)** (distance from the mainland, i.e. isolation), with a fitted surface for each species type:
- **Immigrant species:** increase with **area** and decrease with **distance** (classic island biogeography)
- **Anagenetic species:** appear mostly on **larger, more isolated** islands
- **Cladogenetic species:** only on the **largest, most isolated** islands; most islands have none
- *(The slide has no written conclusions; this is my reading of the plots.)*

## Neutral simulations of mainland → island (slide 19, Rosindell & Phillimore 2011)
- A 3×3 grid of panels: **proportion of species** in each **abundance class** (octave-like bins), coloured **red = immigrant**, **green = anagenetic**, **blue = cladogenetic** (same colours as slide 18)
- Moving through the panels (top-left → bottom-right), the island community shifts from **all immigrant species** to **mostly cladogenetic species**
- My reading: the panels go from **high immigration** (close to the mainland) to **very isolated** islands (the slide doesn't label the gradient)
- **The point:** a simple neutral model with protracted speciation reproduces the pattern in real island birds: radiations only happen on isolated islands

---

# 3. Radiation cascades (slides 20–21)

## Neutral simulations of mainland → archipelago (Tao et al. 2021)
- **Radiation size** (number of species from one radiation) vs **log10(immigration rate)**, for 4 or 8 patches (islands) and J = 500 or 1000 individuals per patch (G = 5 is a model parameter not explained on the slide)
- As immigration falls, radiation size **rises sharply**, then above a threshold (vertical line) it **collapses to 1** (no radiation: gene flow keeps everyone one species)
- The time series below show radiations happen **suddenly**: radiation size jumps from 1 to ~45 almost instantly, then stays there (or never happens)

## The radiation cascade concept (slide 21)
A feedback loop (from the flow diagram):
1. **One species** covers all patches and is stable, with ongoing gene flow between them
2. A **period of unusually low gene flow** triggers the cascade
3. **Speciation in allopatry** (isolated patches) under restricted gene flow, so each species has **lower abundance**
4. Lower abundance → **less gene flow per species** between patches than before
5. → **more speciation** → yet lower abundance → … (**positive feedback = the cascade**)
6. Species **disperse to colonise new patches**
7. The loop stops when abundances get **so low that extinction risk rises**, which leaves a **dynamic equilibrium between extinction and speciation**

---

# 4. How many species will go extinct when habitat is lost? (slides 22–62)

## Species–area relationships and extinction debt (slides 22–23)
- Classic approach: use the **species–area relationship (SAR)**. Less area → read off fewer species (Brown 1984; Thomas et al. 2004)
- **Extinction debt:** after habitat loss, species don't vanish immediately. The community has **more species than the new area can support in the long term**; the excess will be lost over time
    - On the slide: points on the SAR, habitat area shrinks (arrow left), and the gap between the current richness and the new equilibrium (the green band) is the "debt"

## Is fragmentation bad? (slides 24–26)
The slides show the same forest with a black **block** of habitat removed vs the same area removed as **several smaller pieces**. Two opposing views:
- *"Habitat fragmentation is bad. We need connected habitats."* (Fletcher et al. 2018)
- *"If we keep habitat area constant, habitat fragmentation more often leads to increased numbers of species."* (Fahrig 2017)
- Definition: fragmentation = *"breaking or being broken into fragments"* (Oxford Languages)
- Neutral models can help settle this, because you can change **only the arrangement** of the habitat and keep everything else fixed

## Spatially explicit neutral model (slides 27–32)
Building the model used to answer the question (Hubbell 2001; Durrett & Levin 1996):
1. Grid of individuals; one dies
2. The gap is filled by offspring from a parent chosen by a **dispersal kernel**: probability **decreasing with distance**, so nearby parents are more likely
3. Or by **speciation**
4. Then **remove habitat** (grey cells): no individuals can live there, which gives a fragmented landscape

## Four numbers to predict (slides 33–34)
| Quantity | Meaning |
|---|---|
| **Original** number of species | Before any habitat loss |
| **Short-term best case** | Right after loss, the most species that could survive |
| **Short-term worst case** | Right after loss, the fewest |
| **Long-term equilibrium** | After the extinction debt is paid: a new speciation–extinction balance |

## Parameters (slides 35–36)
- **Original area A_max:** the **total number of individuals** in the original habitat (area measured in units of individual organisms)
- **Intrinsic dispersal σ:** from the variance σ² of the **normal (Gaussian) dispersal kernel**: roughly how far offspring move
- **ν:** speciation rate

## Original richness: the species–area relationship (slides 37–43)
- The neutral model gives a **triphasic SAR** (as in Lecture 4): steep at small areas, flatter at intermediate, steep again at continental scales
- Curves for many σ values (5 < σ < 128) **collapse onto one curve** when rescaled, giving the formula:

$$S \approx \sigma^2\, \Psi\!\left(\frac{A}{\sigma^2},\, \nu\right)$$

- **Ψ = the Preston function** (Rosindell & Cornell 2007; O'Dwyer & Cornell 2018; Chisholm et al. 2018)
    - Read it as: measure area in units of "dispersal neighbourhoods" (A/σ²), look up the richness, then scale back up by σ²
- It matches real data across 10 orders of magnitude of area (Preston 1960; Rosindell & Chisholm 2021)

So the **original number of species** is $\sigma^2 \Psi\!\left(\frac{A_{max}}{\sigma^2}, \nu\right)$.

## Which landscape is more fragmented? (slides 46–47)
Three landscapes with the **same total habitat**:
- **□ square:** habitat scattered as fine random speckles
- **△ triangle:** a real fragmented landscape (some big patches, some small)
- **○ circle:** a regular grid of separate round patches

Two audience votes: *which is more fragmented?* and *which will support more species?* The answer comes on slide 60 (below).

## Effective area A_e (slide 48)
- **A_e = the total number of individuals in the remaining habitat** (what's left after the loss)

## The three formulas (slides 49–51, Chisholm et al. 2018)
| Quantity | Formula | Idea |
|---|---|---|
| Original | $\sigma^2 \Psi\!\left(\frac{A_{max}}{\sigma^2}, \nu\right)$ | Full habitat |
| **Short-term best case** | $\sigma^2 \Psi\!\left(\frac{A_e}{\sigma^2},\ 1-(1-\nu)^{A_{max}/A_e}\right)$ | Remaining habitat as **scattered points** across the original area: it is a random **sample** of the original community, so it keeps as many species as possible. The modified speciation term accounts for sampling the old, larger community |
| **Short-term worst case** | $\sigma^2 \Psi\!\left(\frac{A_e}{\sigma^2}, \nu\right)$ | Remaining habitat is **one compact block** (a circle on the slide): just a smaller version of the original |
| **Long-term equilibrium** | depends on **connectivity** (below) | After extinction debt is paid |

## Effective connectivity C_e (slides 52–57, Thompson et al. 2019)
- **Of a cell:** the **squared mean dispersal per hop**, over **multiple hops** starting in that cell
    - Picture a lineage hopping from patch to patch across generations: if hops can easily reach other habitat, connectivity is high; if habitat around is gone, it's low
- **Of the landscape:** the **mean effective connectivity of all cells** (cells with no habitat get 0)

## Long-term formula (slide 58)
$$S_{\text{long-term}} \approx C_e^2\, \Psi\!\left(\frac{A_e}{C_e^2},\, \nu\right)$$

- It has the same shape as the original formula but with **σ replaced by C_e**: in the long term the landscape behaves like a continuous habitat of area A_e whose "effective dispersal" is C_e
- So **effective area and effective connectivity** together set the long-term richness

## Results: real and simulated landscapes (slides 59–60, Thompson et al. 2019)
- y-axis: **% of original species richness at equilibrium**; x-axis: **total area A_max**; colour = **effective connectivity C_e** (yellow high, black low)
- All points lie between a **theoretical upper limit** (dashed, ~20%) and a **lower limit** (dotted)
- **High connectivity** (yellow) → near the upper limit; **low connectivity** (dark) → near the lower limit
- The answer to the audience vote (slide 60):
    - **□ fine speckles** → **highest** connectivity → **most** species (near the upper limit)
    - **△ real landscape** → intermediate
    - **○ separated round patches** → **lowest** connectivity → **fewest** species
    - So the most "fragmented-looking" landscape supports the **most** species, because what matters is whether lineages can still move between habitat cells, not how broken up it looks
    - *(The ~20% upper limit presumably matches the fraction of habitat kept in these simulations; that isn't stated on the slide.)*

## Power law vs neutral prediction (slide 61)
- Traditional approach: power-law SAR $S = cA^z$, with typical z = 0.1, 0.2, 0.3
- Plot: % species richness at equilibrium vs % habitat remaining
    - The power-law curves predict you keep **most species** even after losing a lot of habitat (e.g. z = 0.2 with 25% habitat left → ~75% of species)
    - The **long-term Preston function (best case)** is the **diagonal**: % species ≈ % habitat remaining
- So **traditional SARs under-predict long-term species loss**

## Answer to "how many species will go extinct?" (slide 62)
- There are formulas for the **short term** (best and worst case) and the **long term**
- **Effective area and effective connectivity** matter in the long term
- **Traditional species–area relationships under-predict long-term loss**

---

# Lecture 5: Summary and conclusions
- **Island biogeography:** speciation (immigrant / anagenetic / cladogenetic species) depends on island size and isolation
- **Radiation cascades:** low gene flow → speciation → lower abundance → even less gene flow → more speciation (positive feedback)
- **Extinction debt:** species lost after habitat loss keep disappearing for a long time
- **Habitat fragmentation:** at the same total area, what matters is **effective connectivity**; scattered habitat can hold more species than isolated blocks

### Possible Part 3 project angles from this lecture (my suggestions, not from the slides)
- Extend the Part 2 model to **two communities (mainland + island)** with an immigration rate, and track immigrant vs new species
- **Habitat loss:** shrink J part-way through a run and measure how richness decays (extinction debt) to the new equilibrium
- **Protracted speciation:** require a new lineage to persist for some number of generations before it counts as a species, and compare SADs with point mutation
- Keep it simple first: these all add **one** feature to the Part 2 code
