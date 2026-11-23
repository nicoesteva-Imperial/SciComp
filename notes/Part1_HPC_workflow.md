# Part 1 panel b: running the simulations on the Imperial HPC

Notes from 23/11/2026, written down after running the Part 1 panel b simulations on the HPC (CX3) for the first time.

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
