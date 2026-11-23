# Part 1 panel b: running the simulations on the Imperial HPC

Notes from 23/11/2026, written down after running the Part 1 panel b simulations on the HPC (CX3) for the first time.

---

## 0. Quick recipe (read this first)

### The whole loop at a glance

```
   LAPTOP                        GITHUB                         HPC (CX3)
   ──────                        ──────                         ─────────
 ① write + test code
         │  git push
         └──────────────────────► repo ──────────────────┐
                                                         │  git pull
                                                         ▼
                                                ② qsub code/part1_hpc.sh
                                                         │
                                                         ▼
                                                ③ 20 jobs run (qstat)
                                                         │
                                                         ▼
                                                ④ tidy logs + git push
                                  repo ◄─────────────────┘
         ┌──────────────────────── │
         │  git pull
         ▼
 ⑤ Rscript code/part1_panel_b.R  →  results/part1_panel_b.pdf
```

### Step by step

**① LAPTOP: test, then push the code**
```bash
cd ~/Documents/SCSE
Rscript code/part1_hpc.R                              # quick local test (→ sandbox/)
Rscript code/part1_panel_b.R sandbox/part1_hpc_test   # analysis works on the test files?
git add code/ && git commit -m "..." && git push
```

**② HPC: log in, update, submit**
```bash
ssh nee26@login.cx3.hpc.imperial.ac.uk     # VPN on!  prompt → [nee26@login-x ~]$
cd ~/SciComp
git pull                                    # first time ever: git clone git@github.com:nicoesteva-Imperial/SciComp.git
qsub code/part1_hpc.sh                      # reply: 3055970[].pbs-8
```

**③ HPC: wait for the jobs**
```bash
qstat -u nee26 -t                           # Q = queued, R = running, X = done
```
```
   Q Q Q Q ...  →  R R R R ...  →  X X X X ...  →  (list empty) = all done
```

**④ HPC: check, tidy, push the results**
```bash
ls results/part1_hpc/ | wc -l               # should say 20
cat part1_hpc.e*                            # should print nothing
mkdir -p results/part1_hpc/logs && mv part1_hpc.[oe]* results/part1_hpc/logs/
git add results/part1_hpc && git commit -m "Part 1 HPC results (job <ID>)" && git push
exit                                        # back to the laptop
```

**⑤ LAPTOP: pull and make the figure**
```bash
cd ~/Documents/SCSE
git pull
Rscript code/part1_panel_b.R                # → results/part1_panel_b.pdf + _summary.rda
```

> **Always check the prompt before typing.**
> `nicolas-esteva@...EliteBook` = laptop · `[nee26@login-b ...]$` = HPC

### The automated version (steps ②–④ and ⑤ in one command each)

```
 HPC:     bash code/part1_submit.sh
            ├─ qsub part1_hpc.sh ─────────► 20 jobs   [1] [2] ... [20]
            │                                            │ all exit OK?
            └─ qsub -W depend=afterok ────► part1_combine.sh  (status H = held until then)
                                              ├─ move .o/.e → results/part1_hpc/logs/
                                              ├─ Rscript code/part1_panel_b.R
                                              └─ Rscript code/part1_figure.R
          then: git add results/ && git commit -m "Part 1 HPC results (job <ID>)" && git push

 LAPTOP:  git pull
          Rscript code/part1_run_all.R
            ├─ check results/part1_hpc/ has 20 files
            ├─ part1_panel_a.R   (panel a is always made locally, as the brief says)
            ├─ part1_panel_b.R
            └─ part1_figure.R  → results/part1_figure.pdf
```

| File | Runs on | Job |
|---|---|---|
| `code/part1_submit.sh` | HPC login node (`bash`, not `qsub`) | Submits the array job, then the combine job with `afterok` |
| `code/part1_hpc.sh` + `part1_hpc.R` | HPC compute nodes (×20) | Simulations |
| `code/part1_combine.sh` | HPC compute node (×1) | Tidies the logs, runs panel b and the figure, **only if all 20 jobs succeeded** |
| `code/part1_run_all.R` | Laptop | Rebuilds panel a, panel b and the figure, in that order |

`afterok` means that if **any** of the 20 jobs fails, the combine job never starts and no half-finished result appears. It stays in `qstat` with status `H`; delete it with `qdel <ID>`, fix the problem and resubmit.

---

## 0b. Making it reproducible

"Reproducible" means that someone else (or you, in a month) can get **exactly the same numbers** from the same code. Here's what makes that true in this project, and what to keep doing.

### What's already built in

```
 same code        +   same seeds          +   same parameters          =  same results
 (git commit)         (seed = job 1..20)      (demographic_parameters.R)
     │                     │                        │
     ▼                     ▼                        ▼
  git log shows       part1_hpc.R:            one file, sourced
  which version       set.seed(PBS_ARRAY_INDEX)  by every script
  ran                 → job 7 always gives
                        the same part1_hpc_7.rda
```

| Ingredient | Where | Why it matters |
|---|---|---|
| **Fixed seeds** | `part1_hpc.R`: `seed <- job_index` | Job *i* always uses seed *i*, so rerunning any job gives an identical `.rda`. Different seeds mean the 20 jobs are independent |
| **Parameters in one file** | `code/demographic_parameters.R` | Every script uses the same matrices. Change them in one place only |
| **Relative paths** | `code/...`, `results/...` | Works on any computer, provided you run from the project root (`SCSE.Rproj` in RStudio, `cd ~/SciComp` on the HPC) |
| **Code under git** | GitHub | The commit hash records exactly which code produced the results |
| **Raw results kept** | `results/part1_hpc/*.rda` | The figure can be remade without the HPC |
| **Logs kept** | `results/part1_hpc/logs/` | Proof of what ran, where, when and how long it took |
| **Test output kept apart** | `sandbox/` vs `results/` | Test runs can never be mistaken for real ones |

### Habits to keep each time you run it

1. **Commit before you submit.** Never run on the HPC with unpushed changes. The HPC should only run code that's on GitHub.
2. **Write the run in the diary**: date, job ID (for example `3055970`), number of jobs, commit hash (`git log --oneline -1` on the HPC), and any problems.
3. **Commit the results with the job ID** in the message: `"Part 1 HPC results (job 3055970)"`.
4. **Don't edit raw results by hand.** If something's wrong, fix the code and rerun.
5. **Clean the HPC copy** before the next `git pull` there (`rm part1_hpc.[oe]*` if any logs are left in the root), so the pull doesn't clash.

### Checking reproducibility yourself

Rerun one job on the laptop and compare its results with the HPC file:
```bash
# on the laptop, from ~/Documents/SCSE
PBS_ARRAY_INDEX=7 Rscript code/part1_hpc.R          # overwrites results/part1_hpc/part1_hpc_7.rda
```
```r
# in R, from the project root
hpc <- new.env(); local <- new.env()
system("git show HEAD:results/part1_hpc/part1_hpc_7.rda > /tmp/hpc_7.rda")  # the HPC version from git
load("/tmp/hpc_7.rda", envir = hpc)
load("results/part1_hpc/part1_hpc_7.rda", envir = local)
identical(hpc$extinct, local$extinct)               # TRUE = reproducible
```
```bash
git checkout results/part1_hpc/part1_hpc_7.rda      # put the HPC version back afterwards
```
Only compare `extinct`. `run_time` always differs between machines, so the whole file is never byte-for-byte identical.

### Reusing this for another HPC job (for example, Part 3)

Copy the **four** files (`part1_submit.sh`, `part1_hpc.sh`, `part1_hpc.R`, `part1_combine.sh`), plus `part1_run_all.R` for the laptop side, and rename `part1` → `part3` everywhere. In `part3_submit.sh`, change the three names at the top (`array_script`, `combine_script`, `log_dir`). In `part3_combine.sh`, list the analysis scripts to run. The pair of simulation files needs these changes:

```
code/part1_hpc.sh  →  code/part3_hpc.sh          code/part1_hpc.R  →  code/part3_hpc.R
  #PBS -N part3_hpc        ← job name               the simulation itself
  #PBS -J 1-<N>            ← number of jobs          output_dir <- "results/part3_hpc"
  #PBS -l walltime=...     ← time per job            sandbox dir <- "sandbox/part3_hpc_test"
  Rscript code/part3_hpc.R ← which script
```
Then follow the same five steps (①–⑤), with `part3` in place of `part1`.

---

## 1. What we did, in one paragraph

Panel b needs **800 stochastic simulations × 4 initial sizes**, run for 120 months each. Rather than run them all on the laptop, the work was split into **20 jobs** (40 simulations per size each) that run **at the same time** on the Imperial HPC. The code was moved from the laptop to the HPC **through GitHub**. The jobs were submitted with `qsub`, and each one saved a small `.rda` file of results. These files are then brought back to the laptop, where `part1_panel_b.R` pools them and draws the plot.

---

## 2. The big picture

```
 ┌──────────────────────────┐        git push         ┌──────────────┐
 │  LAPTOP                  │ ──────────────────────► │   GITHUB     │
 │  ~/Documents/SCSE        │                         │  SciComp     │
 │                          │ ◄────────────────────── │  repository  │
 │  write + test code       │        git pull         └──────┬───────┘
 │  make the final figure   │                                │  ▲
 └────────────┬─────────────┘                     git clone/ │  │ git push
              │                                   git pull   ▼  │ (results)
              │  ssh  (log in)                    ┌─────────────┴────────────┐
              │  sftp (copy files)                │  HPC LOGIN NODE (CX3)    │
              └─────────────────────────────────► │  login.cx3.hpc...        │
                                                  │  ~/SciComp               │
                                                  │  you type commands here  │
                                                  └─────────────┬────────────┘
                                                                │ qsub
                                                                ▼
                                    ┌──────────────────────────────────────────┐
                                    │  COMPUTE NODES (you never log in here)   │
                                    │  job 1   job 2   job 3   ...   job 20    │
                                    │  seed 1  seed 2  seed 3  ...   seed 20   │
                                    │  each writes results/part1_hpc/*.rda     │
                                    └──────────────────────────────────────────┘
```

Three separate computers are involved, and each one holds **its own copy** of the files:

| Where | What it's for | Your copy of the project |
|---|---|---|
| Laptop | Writing code, testing, making figures | `~/Documents/SCSE` |
| GitHub | Moving the code between the other two, and keeping its history | `github.com/nicoesteva-Imperial/SciComp` |
| HPC | Running the heavy simulations | `~/SciComp` (that is, `/rds/general/user/nee26/home/SciComp`) |

> Changing a file on one computer does **not** change it on the others. The changes have to be moved: `git push` + `git pull`, or `sftp`.

---

## 3. How SSH works

SSH (Secure SHell) gives you an encrypted connection to another computer. It's used **twice** in this workflow:

1. **Laptop → HPC**: to log in and type commands there (`ssh`), or to copy files (`sftp`).
2. **Computer → GitHub**: when you `git clone`, `git push` or `git pull` with a `git@github.com:...` address.

### Logging in to the HPC

```bash
ssh nee26@login.cx3.hpc.imperial.ac.uk
#   │     └── which computer (the CX3 login node)
#   └── your Imperial username
```

- You must be **on the Imperial network or the VPN**, otherwise it just hangs.
- The login uses your Imperial password.
- You land on one of several login nodes (`login-b`, `login-bi`, …). They all share the **same home folder**, so the node doesn't matter.
- The prompt changes to show where you are: `[nee26@login-b SciComp]$` means user `nee26`, node `login-b`, folder `SciComp`.
- `exit` logs out and takes you back to the laptop.

### SSH keys (how GitHub knows it's you)

GitHub doesn't use a password for `git@github.com:` addresses. It uses a **key pair**:

```
   private key  ~/.ssh/id_ed25519       ── stays on its own computer, NEVER shared
   public key   ~/.ssh/id_ed25519.pub   ── copied to GitHub (Settings → SSH keys)

   When you connect, GitHub sends a challenge that only the private key can answer.
   If the answer matches a public key on your account → "Hi nicoesteva-Imperial!"
```

**Each computer needs its own key.** That was the cause of today's first error:

```
 LAPTOP  ── key SHA256:2vug1x...  ── on GitHub since 1 Oct ──► ✅ works
 HPC     ── no key yet            ───────────────────────────► ❌ Permission denied (publickey)
```

What fixed it, on the HPC:

```bash
ssh-keygen -t ed25519 -C "imperial-hpc"   # press Enter at every prompt (default file, no passphrase)
cat ~/.ssh/id_ed25519.pub                 # copy this line → GitHub → Settings → SSH and GPG keys → New SSH key
ssh -T git@github.com                     # test: "Hi nicoesteva-Imperial! You've successfully authenticated"
```

"GitHub does not provide shell access" in that message is normal.

### The "authenticity of host can't be established" question

The first time you connect to a new server, SSH shows its **fingerprint** and asks whether to trust it. You answer `yes` once, and it's saved in `~/.ssh/known_hosts`. Next time, if the server's fingerprint ever changes, SSH warns you, because that could mean someone is pretending to be the server. "Permanently added ... to the list of known hosts" is just SSH confirming that it saved the fingerprint.

---

## 4. The process, step by step

### On the laptop
| # | Command | Why |
|---|---|---|
| 1 | `Rscript code/part1_hpc.R` | Local test. With no job number set, it runs as job 1 and saves to `sandbox/part1_hpc_test/` so test output never mixes with real results |
| 2 | `Rscript code/part1_panel_b.R sandbox/part1_hpc_test` | Checks that the analysis script can read and pool the test files |
| 3 | `git add code/ ...`, `git commit`, `git push` | Puts the scripts on GitHub so the HPC can get them |

### On the HPC
| # | Command | Why |
|---|---|---|
| 4 | `ssh nee26@login.cx3.hpc.imperial.ac.uk` | Log in |
| 5 | `ssh-keygen ...` + add the key to GitHub | Lets the HPC talk to GitHub (only needed once) |
| 6 | `git clone git@github.com:nicoesteva-Imperial/SciComp.git` | Copies the repository to `~/SciComp` (only needed once; afterwards, use `git pull`) |
| 7 | `cd ~/SciComp` | **Always submit from the project root**, because the scripts use relative paths like `code/...` and `results/...` |
| 8 | `qsub code/part1_hpc.sh` | Submits the array job. Reply: `3055970[].pbs-8` |
| 9 | `qstat -u nee26 -t` | Shows **your** jobs only. Plain `qstat` lists everyone's |

### What `qsub code/part1_hpc.sh` does

```
part1_hpc.sh
 ├─ #PBS -J 1-20                → make 20 copies of this job (an "array job")
 ├─ #PBS -l walltime=00:30:00   → each copy may run for up to 30 min
 ├─ #PBS -l select=1:ncpus=1:mem=1gb → 1 CPU and 1 GB of memory each
 ├─ cd $PBS_O_WORKDIR           → go to the folder qsub was run from (~/SciComp)
 ├─ module load R               → make R available on the compute node
 └─ Rscript code/part1_hpc.R    → run the simulations

part1_hpc.R  (inside copy i, where PBS_ARRAY_INDEX = i)
 ├─ set.seed(i)                 → different random numbers in every job, reproducible
 ├─ 40 sims × sizes 3, 10, 30, 100, each 120 steps
 ├─ extinct[size, sim] = TRUE/FALSE
 └─ save → results/part1_hpc/part1_hpc_i.rda
```

### Reading `qstat -u nee26 -t`

```
Job ID          ...  Jobname    ...  S  Time
3055970[1].pbs* ...  part1_hpc  ...  X  00:01    ← finished
3055970[6].pbs* ...  part1_hpc  ...  R  00:00    ← running
```

| Status `S` | Meaning |
|---|---|
| `Q` | Waiting in the queue |
| `R` | Running |
| `X` | Finished (it doesn't say whether it **succeeded**; check the `.o`/`.e` files) |
| `H` | Held (waiting for something) |
| `B` | The array job as a whole has started (seen without `-t`) |

---

## 5. Where every file ends up

```
HPC: ~/SciComp/
├── code/
│   ├── part1_hpc.sh          ← what you qsub
│   └── part1_hpc.R           ← what each job runs
├── results/
│   └── part1_hpc/            ← created by the first job that runs
│       ├── part1_hpc_1.rda   ← extinct table for seed 1 (4 sizes × 40 sims)
│       ├── ...
│       └── part1_hpc_20.rda
├── part1_hpc.o3055970.1      ← job 1's printed output ("Job 1 | seed 1 | run time ...")
├── part1_hpc.e3055970.1      ← job 1's error messages (ideally empty)
├── ...                          (one .o and one .e per job; the brief wants these in the repo)
└── part1_hpc.e3055970.20        → TIDY UP: move them into results/part1_hpc/logs/ (see below)

LAPTOP: ~/Documents/SCSE/
├── sandbox/part1_hpc_test/   ← local TEST runs only (3 jobs), not used in the report
└── results/
    ├── part1_hpc/            ← the 20 .rda files must be copied HERE
    ├── part1_panel_b_summary.rda   ← made by part1_panel_b.R
    └── part1_panel_b.pdf           ← made by part1_panel_b.R
```

The `.o`/`.e` files are written to the folder `qsub` was run from (`~/SciComp`), not to `results/`. Once **all** jobs have finished, move them next to the results they belong to, **before** committing:

```bash
mkdir -p results/part1_hpc/logs
mv part1_hpc.[oe]* results/part1_hpc/logs/
```

Final layout in the repository:

```
results/
├── part1_panel_a.pdf / .rda
├── part1_panel_b.pdf / part1_panel_b_summary.rda
└── part1_hpc/
    ├── part1_hpc_1.rda ... part1_hpc_20.rda   ← raw HPC output
    └── logs/
        ├── part1_hpc.o3055970.1 ... .20       ← printed output
        └── part1_hpc.e3055970.1 ... .20       ← errors (all empty for run 3055970)
```

(For run 3055970 the logs were first pushed to the project root, then moved with `git mv` on the laptop.)

---

## 6. Getting the results back to the laptop

There are two ways to do this. Use **one** of them.

### Option A: through GitHub (keeps everything in the repository)

On the HPC:
```bash
cd ~/SciComp
mkdir -p results/part1_hpc/logs && mv part1_hpc.[oe]* results/part1_hpc/logs/
git add results/part1_hpc
git commit -m "Part 1 HPC results"
git push
```
On the laptop:
```bash
cd ~/Documents/SCSE
git pull
```

### Option B: `sftp` (copy files directly between laptop and HPC)

`sftp` (SSH File Transfer Protocol) uses the same login as `ssh`, but gives you a **file-copying prompt** instead of a normal shell. **Start it from the laptop**, not from inside the HPC.

```bash
# on the LAPTOP terminal:
sftp nee26@login.cx3.hpc.imperial.ac.uk
#    │     └── the same server as ssh
#    └── your Imperial username
```

The prompt changes to `sftp>`. You are now in **two places at once**:

```
                 sftp>  commands
   ┌─────────────────────────┐        ┌──────────────────────────┐
   │ LOCAL (laptop)          │        │ REMOTE (HPC)             │
   │ commands start with "l" │  get   │ normal commands          │
   │   lpwd  lls  lcd        │ ◄───── │   pwd  ls  cd            │
   │                         │ ─────► │                          │
   │                         │  put   │                          │
   └─────────────────────────┘        └──────────────────────────┘
```

| Command | Does | Side |
|---|---|---|
| `pwd` / `lpwd` | Show the current folder | HPC / laptop |
| `ls` / `lls` | List files | HPC / laptop |
| `cd folder` / `lcd folder` | Change folder | HPC / laptop |
| `get file` | **Download** a file from the HPC to the laptop | HPC → laptop |
| `get -r folder` | Download a whole folder | HPC → laptop |
| `put file` | **Upload** a file from the laptop to the HPC | laptop → HPC |
| `put -r folder` | Upload a whole folder | laptop → HPC |
| `mkdir folder` / `lmkdir folder` | Make a folder | HPC / laptop |
| `exit` or `bye` | Quit sftp | — |

**Example: download the Part 1 results**

```
sftp> lcd ~/Documents/SCSE/results     # laptop: go to the results folder
sftp> cd SciComp/results               # HPC: go to the results folder
sftp> get -r part1_hpc                 # copy the whole part1_hpc folder → laptop
sftp> cd ~/SciComp                     # HPC: back to the project root
sftp> lcd ~/Documents/SCSE             # laptop: project root
sftp> get part1_hpc.o3055970.*         # the .o files (wildcards work)
sftp> get part1_hpc.e3055970.*         # the .e files
sftp> exit
```

Then check on the laptop: `ls ~/Documents/SCSE/results/part1_hpc` should list 20 files.

**Tips**
- `get`/`put` always copy **into the current folder on the other side**, so set `cd`/`lcd` first.
- Tab completion works for remote paths.
- `~` on the HPC side means `/rds/general/user/nee26/home`. When sftp starts, you are already in this folder.
- One-line alternative without the interactive prompt (`scp`, run on the laptop):
  ```bash
  scp -r nee26@login.cx3.hpc.imperial.ac.uk:SciComp/results/part1_hpc ~/Documents/SCSE/results/
  ```
- If you use sftp, the `.o`/`.e` files still need to go into the repository. Commit them from the laptop afterwards with `git add results/part1_hpc part1_hpc.o* part1_hpc.e*`.

---

## 7. Problems hit today and what they meant

| Symptom | Cause | Fix |
|---|---|---|
| `No part1_hpc_<i>.rda files found in results/part1_hpc` (laptop) | The HPC hadn't run yet, so there was nothing to analyse | Run the HPC jobs and copy the results back |
| VS Code showed an empty `part1_hpc.` | Opened a file name with a missing `sh`, so VS Code opened a new blank file | Open `part1_hpc.sh` |
| `Permission denied (publickey)` on `git clone` | The HPC had no SSH key registered on GitHub | `ssh-keygen` on the HPC, add the `.pub` file to GitHub |
| `cd: ~/SciComp: No such file or directory` | The clone had never succeeded | Clone again after adding the key |
| The terminal wouldn't accept typing | Stuck in a pager or a running command, or a frozen SSH connection | `q`, then `Ctrl+C`, then `Enter ~ .` (kills a frozen SSH); or open a new terminal and log in again |
| `module avail R` takes ages | It searches the whole software library | Wait about a minute, or `Ctrl+C` and skip it (the `.e` files show whether `module load R` worked) |
| `qstat` showed lots of jobs that weren't mine | Plain `qstat` lists all users | `qstat -u nee26 -t` |
| `ls results/part1_hpc/` showed nothing | Checked before any job had finished | Wait until `qstat` shows `X`/nothing |

---

## 8. Still to do

1. Check that all 20 jobs succeeded: `ls results/part1_hpc/` (20 files) and `cat part1_hpc.e*` (empty).
2. Bring the results to the laptop (section 6).
3. On the laptop, in RStudio with `SCSE.Rproj` open: `source("code/part1_panel_b.R")` → `results/part1_panel_b.pdf`.
4. Make sure the `.o`/`.e` files and results are committed (the brief requires the `.o`/`.e` files).
5. Diary entry: HPC run, job ID 3055970, 20 jobs, any problems.
