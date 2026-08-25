# managers/job_manager/

- `JobConstants` — the `JOB` enum has been removed entirely; all that's left
  is `EMPLOYMENT_PRESSURE` (currently `0.376`, solved for the old `pull`
  scale and the old single-need formula — the IAUS combination formula is
  now implemented in `NeedsEvaluator`, but this constant hasn't been
  re-derived against it yet, see `docs/CURRENT_SPRINT.md`). See
  `entities/job/README.md` for why the enum went away.
- `JobManager` — owner-driven rat ↔ job assignment (`_ASSIGNED_JOBS:
  Dictionary[int, Job]`, keyed by rat id, values are `Job` node references or
  absent — no `null` stored, `unassign_job()` erases the entry).
  `get_jobs()` discovers `Job` children the same way
  `LocationManager.get_location_data()` discovers `Location` children. A rat
  never assigns itself a job — jobs have no `pull`, only
  `employment_pressure`.
