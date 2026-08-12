# entities/rat/needs_evaluator/

Utility-AI decision scoring for "which location should this rat go to."

- `NeedsEvaluator` — static `evaluate(rat, assigned_job, locations)`, currently
  scores only `nutrition` (`urgency(mood.nutrition) × location.pull.nutrition`,
  plus `EMPLOYMENT_PRESSURE` if the location matches the rat's job); picks the
  highest-scoring `Location`. Extending to all five needs is this sprint's
  main task — see `docs/CURRENT_SPRINT.md`.
- `NeedUrgencies` / `MoodUrgency` — per-need `Curve` resources mapping a raw
  mood value to a normalized `0..1` urgency (only `nutrition`'s curve exists
  so far, in `need_urgencies.tres`).
