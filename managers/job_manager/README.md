# managers/job_manager/

- `JobConstants` — the `JOB` enum (`HEAD_COOK`, `LINE_COOK`, `PREP_COOK`,
  `DISHWASHER`, `BARTENDER`, `UNASSIGNED`) and `EMPLOYMENT_PRESSURE` (currently
  `0.376`, solved for the old `pull` scale — needs re-derivation this sprint,
  see `docs/CURRENT_SPRINT.md`).
- `JobManager` — owner-driven rat ↔ job assignment (`_ASSIGNED_JOBS:
  Dictionary[int, JOB]`, keyed by rat id). A rat never assigns itself a job —
  jobs have no `pull`, only `employment_pressure`.
