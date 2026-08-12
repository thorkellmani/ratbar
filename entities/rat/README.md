# entities/rat/

`Rat extends Area2D` — one simulated rat. Holds its stat groups (`_mood`,
`_personality`, `_status`, `_vice`, `_job_skills`, `_camaraderie`, `_other`)
behind read-only getters, and its own movement/state (`_current_location`,
`_destination`, travels via `_process` on `PROCEEDING_TO_LOCATION`).

`RatManager` (see `managers/rat_manager/`) drives every rat from the outside:
`apply_location_modifiers()` runs every tick for every rat, `reevaluate_needs()`
only runs on the rat's assigned tick slot. A rat never ticks itself.

Subdirectories:
- `stats/` — the `BaseStatGroup` resource classes (`Mood`, `Personality`, etc.)
- `needs_evaluator/` — decision-scoring: which `Location` a rat should go to
- `generation_defaults/` — the `.tres` inspector defaults used at rat creation

`rat_constants.gd` holds the `CRISIS`, `STATUS`, and `STATE` enums.
