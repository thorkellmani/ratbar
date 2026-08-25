# entities/rat/

`Rat extends Area2D` — one simulated rat. Holds its stat groups (`_needs`,
`_personality`, `_status`, `_camaraderie`, `_other`)
behind read-only getters, and its own movement/state (`_current_location`,
`_destination`, travels via `_process` on `PROCEEDING_TO_LOCATION`).

Both `Vice` and `JobSkills` have been removed (see `stats/README.md`) — not
abandoned designs, just deferred until the sim actually needs them.
`apply_location_modifiers()` currently only applies
`modifiers.nutrition` to `_needs.nutrition`, even though `LocationModifiers`
now carries all five needs — extending it to all five is still open.

`reevaluate_needs(job: Job, locations)` and `_arrive_at_destination()` now
work off a `Job` node reference (or `null`) instead of `JobConstants.JOB` —
see `entities/job/README.md`. `RatConstants.STATE.VICING` was replaced with
`PROCEEDING_TO_WORK`, distinguishing "traveling to the assigned job's
station" from "traveling to any other location."

`RatManager` (see `managers/rat_manager/`) drives every rat from the outside:
`apply_location_modifiers()` runs every tick for every rat, `reevaluate_needs()`
only runs on the rat's assigned tick slot. A rat never ticks itself.

Subdirectories:
- `stats/` — the `BaseStatGroup` resource classes (`Needs`, `Personality`, etc.)
- `needs_evaluator/` — decision-scoring: which `Location` a rat should go to
- `generation_defaults/` — the `.tres` inspector defaults used at rat creation

`rat_constants.gd` holds the `CRISIS`, `STATUS`, and `STATE` enums.
