# AGENTS.md – Rules for AI Coding Agents Working on Clod

**This file is mandatory reading before any work begins.**

You are an AI coding agent helping build **Clod**, an offline-first, credit-native business operations platform for Windows and Android.  
Your job is to implement the system correctly, cleanly, and incrementally.  
You do **not** own the project. The human owns the architecture, the quality bar, and the merge decisions.

---

## 1. Core Identity of the Project

Clod is an offline-first, single-user, credit-native business management and execution platform.

Key Pillars:
- **Offline-First Reality:** 100% of core operations (sales, credit ledger, catalogue, stock, expenses, reports, PDF generation) execute locally without internet dependency.
- **Credit-Native Ledger:** Customer credit and repayment tracking is a first-class citizen, maintaining rock-solid financial balance integrity.
- **Single Source of Truth:** Drift SQLite database with strictly typed DAOs, reactive streams, and transactional consistency.
- **Integer Money Standard:** All monetary values are strictly stored and calculated as integers (cents / smallest currency unit)—never floating-point.
- **Cross-Platform Parity:** Clean responsive user interface operating seamlessly on Windows Desktop and Android Mobile/Tablet.

Correctness, data durability, and ledger integrity always win over flashy shortcuts.

---

## 2. Absolute Rules (Never Violate)

1. **Never work directly on `production`, `main`, `staging`, or `development`.**  
   You may only commit to the current feature/milestone branch (`feat/mXX-...`).

2. **Never implement more than the current milestone allows.**  
   Do not jump ahead to later milestones, back-office, cloud sync, or packaging unless the current milestone contract explicitly includes it.

3. **Never use floating-point numbers (`double`, `float`) for money.**  
   All prices, balances, limits, discounts, line totals, and expenses must be stored and calculated in integer cents. The display layer handles decimal formatting.

4. **Never perform multi-table mutations outside a database transaction.**  
   Sales, repayments, stock issues, and purchase receives must always execute inside a single Drift transaction to prevent partial state corruption.

5. **Never require network connectivity for core operations.**  
   Internet access is strictly optional and restricted to cloud backup synchronization (e.g. Google Drive).

6. **Never invent fake functionality or mock data in production code.**  
   If a feature is not yet part of the active milestone, return or raise a clear "Not implemented".

7. **Never log or commit secrets or unencrypted customer data.**  
   All backup archives must use AES encryption (`.clodbackup`).

8. **All timestamps must be stored as Unix milliseconds in UTC.**  
   Never store localized, non-standardized string dates in the database layer.

9. **PDF generation must be dynamic and self-contained.**  
   Receipts, invoices, quotes, and statements must pull live business profiles, logos, and line items without external server dependencies.

10. **The UI must be responsive and adaptive.**  
    Desktop/Tablet layouts use sidebar/navigation rail architectures; mobile layouts adapt to bottom bars and fluid touch surfaces.

---

## 3. How You Receive Work

- The human will give you **one milestone at a time**.
- You will receive:
  - The current milestone contract (from `PROGRESS.md`)
  - The current state of the codebase on the feature branch
- You must **not** request or assume the entire specification unless the human explicitly provides it.
- Completed milestones remain in `PROGRESS.md` so you accumulate context over time.  
  You still work **only** on the newest (in-progress) milestone unless the human explicitly tells you otherwise.

---

## 4. How You Must Work

- Create **one atomic commit per task** listed in the milestone.
- Write tests together with (or before) the implementation.
- Prefer clean, readable, well-typed Dart code adhering to effective Dart guidelines.
- Follow the package and directory structure defined in the architecture specification.
- When a task is finished, mark it done in `PROGRESS.md` (see Section 10) and commit the progress update.
- When all tasks in a milestone are finished, push the feature branch to origin, open a Pull Request targeting `development` using `gh pr create` with the mandatory PR format (see Section 6), and notify the human.

---

## 5. Commit Message Rules (Mandatory)

When creating commits you must follow this exact format.  
Do not wait for the user to provide a diff — inspect the changes yourself with `git status` and `git diff`.

### Header Format

```
<type>(`<path>`): <short description with backticked filename>
```

- `<type>` must be one of: `feat`, `fix`, `refactor`, `style`, `chore`, `perf`, `test`, `docs`, `build`, `ci`
- `<path>` must be the full relative directory path wrapped in backticks
- The primary filename in the description must also be wrapped in backticks
- Keep the entire header under 100 characters
- Use present tense

### Body Format

Exactly two paragraphs, each written as a single unbroken line:

```
<header>

<first paragraph – what was done>

<second paragraph – why it was done>
```

- Blank line after the header
- Blank line between the two paragraphs
- No bullet points, no lists, no line wrapping inside paragraphs

### Workflow

1. Run `git status` and `git diff` (or `git diff --cached`)
2. Stage the relevant changes with `git add`
3. Create exactly one conventional commit following the format above
4. Repeat until the working tree is clean
5. **Never push**

Example:

```
feat(`/lib/data/database`): implement customer credit table in `app_database.dart`

Added customers and credit_transactions Drift schema definitions with integer cents constraints in `app_database.dart`.

Provides the foundational local SQLite schema required for credit-native ledger tracking.
```

---

## 6. Pull Request & Merge Message Rules (Mandatory)

The AI agent is responsible for creating Pull Requests (PRs) via the GitHub CLI (`gh pr create`) when a milestone is completed.

When creating a PR or generating a squash merge commit message, you must follow this exact format:

### Exact Format

```
pr(`/`): <short description with backticked filename>

<first paragraph summarizing what was done>

<second paragraph explaining why it was done>
```

- Type is always `pr`
- Scope is always `` `/` ``
- Exactly two single-line paragraphs
- No bullet points or lists
- Synthesize the entire PR / Milestone into one coherent summary
- When merging via GitHub or locally, the pull request title and description will serve directly as the merge commit message.

---

## 7. Definition of Done for Any Task

A task is only done when:
- The code is implemented
- Tests covering the happy path and important edge cases pass
- The change is committed with a message that strictly follows the rules in Section 5
- The corresponding checkbox in `PROGRESS.md` has been marked as done
- You have not introduced code that belongs to a future milestone

---

## 8. Where to Find the Current Work

All milestones, branch names, tasks, and human review checklists live in:

→ **`PROGRESS.md`**

Start there.  
Read the Global Working Rules, then locate the milestone marked **🔄 IN PROGRESS**. That is the only milestone you are allowed to work on unless the human says otherwise.

---

## 9. When You Are Unsure

If the specification is ambiguous, or if a requested change would violate any rule above:
- Stop
- Explain the conflict clearly
- Wait for human guidance

Do not guess on matters of financial calculation, database schema integrity, or ledger balance consistency.

---

## 10. How to Update PROGRESS.md (Mandatory)

You must keep `PROGRESS.md` accurate as you work. Follow this exact format.

### Marking a single task complete

Change:

```markdown
- [ ] Define customers Drift table and DAO
```

To:

```markdown
- [x] Define customers Drift table and DAO
```

Do this as soon as the task is finished and committed.  
Then commit the progress update itself:

```
chore(`/`): mark customer table task complete in `PROGRESS.md`

Marked the customer Drift table task as done in PROGRESS.md after the implementation and tests were committed.

Keeps the milestone tracker accurate for the human reviewer.
```

### Milestone status markers

Use exactly these markers in the milestone heading:

- While work is ongoing:

```markdown
### M00 – Project Setup & Responsive Shell 🔄 IN PROGRESS
```

- When every task is done and you believe the milestone is ready for human review, you may note it, but **do not** mark the whole milestone complete yourself. Only the human changes it to:

```markdown
### M00 – Project Setup & Responsive Shell ✅ COMPLETE
```

and updates the status line to something like:

```markdown
**Status:** Merged into `development`
```

### Status line

Under the branch name keep a clear status line:

- Active work:

```markdown
**Branch:** `feat/m00-project-setup`  
**Status:** Active – agent is working here
```

- After the human has merged:

```markdown
**Branch:** `feat/m00-project-setup`  
**Status:** Merged into `development`
```

---

**End of AGENTS.md**  
Now open `PROGRESS.md` and begin only the milestone marked 🔄 IN PROGRESS.
