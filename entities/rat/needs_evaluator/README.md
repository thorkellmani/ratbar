# entities/rat/needs_evaluator/

Utility-AI decision scoring for "which location should this rat go to."

- `NeedsEvaluator` — static `evaluate(rat, assigned_job: Job, locations) ->
  Location` (nullable — returns `null` if nothing scores, e.g. no location
  has any active `pull` axis; callers must handle that, see `Rat.
  reevaluate_needs()`). Scores across all five needs: for each need where
  `location.pull[need] > 0`, `urgency(needs[need]) ×
  location.pull.get_normalized_value(need)`. `employment_pressure` is added
  on top afterward — not folded into the combination — if `location` is in
  `assigned_job.locations`. `assigned_job` is a `Job` node reference or
  `null` (unassigned), not the old `JobConstants.JOB` enum — see
  `entities/job/README.md`.

  Active-axis scores use an equal-weight power mean with `p = 3`; see
  `docs/ALGORITHM_RESEARCH.md` for the design and observed crossover.

  A veto mechanism (hard override for genuine crisis needs, regardless of
  score) was deliberately deferred rather than built — see
  `docs/RAT_TURING_COMPLETE.md`.
- `NeedUrgencies` / `NeedUrgency` — per-need `Curve` resources mapping a raw
  need value to a normalized `0..1` urgency. All five curves are authored in
  `need_urgencies.tres` (`nutrition`, `energy`, `social`, `stimulation`,
  `vice_satisfaction`), and `NeedsEvaluator` now reads all five.
