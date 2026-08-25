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

  **Combining the active-axis scores is currently IAUS's compensated
  average (`1 - 1/k` boost, `k` = active axis count), but this is being
  replaced with a weighted power mean (`p > 1`) — see
  `docs/ALGORITHM_RESEARCH.md` for the full research trail.** The
  compensated average couldn't let one dominant, urgent need decisively
  outweigh other active-but-currently-irrelevant axes at the same
  location; the power mean's effective per-axis weight grows with that
  axis's own urgency, which is what's actually needed here. Implementation
  of the replacement is still open, see `docs/CURRENT_SPRINT.md`.

  A veto mechanism (hard override for genuine crisis needs, regardless of
  score) was deliberately deferred rather than built — see
  `docs/RAT_TURING_COMPLETE.md` and `docs/CURRENT_SPRINT.md`.
- `NeedUrgencies` / `NeedUrgency` — per-need `Curve` resources mapping a raw
  need value to a normalized `0..1` urgency. All five curves are authored in
  `need_urgencies.tres` (`nutrition`, `energy`, `social`, `stimulation`,
  `vice_satisfaction`), and `NeedsEvaluator` now reads all five.
