# entities/location/

`Location extends Marker2D` — a place a rat can travel to (job stations, Pantry,
Bartender, etc.). Two independent per-need fields, deliberately decoupled:

- `modifiers: LocationModifiers` — the physical per-hour effect on a rat's
  needs while stationary here, `-20..20`, one field per need. Deliberately its
  own class rather than reusing `Needs` — a location's effect on a rat isn't
  the same kind of value as the rat's own need level. Rescaled this sprint
  from the original `0..200` — the huge range was pointlessly fiddly to
  author against; `-20..20` matches the Football Manager-style attribute
  range already used elsewhere and allows locations to actively drain a need,
  not just boost it.
- `pull: LocationPull` — hand-authored decision-scoring appeal, `0..7`. `0`
  means "not a factor for this need at this location" (excluded from scoring,
  not a real judgment); `1..7` is a real appeal judgment. See
  `docs/CURRENT_SPRINT.md` for why the scale is `0..7` and not signed.

`Location` no longer knows what job (if any) it belongs to — `job:
JobConstants.JOB` was removed. That link now lives on the other side: `Job`
(see `entities/job/README.md`) holds `locations: Array[Location]`, and
`JobManager` is what a rat/`NeedsEvaluator` asks "is this location one of my
job's stations." Jobs still have no `pull` of their own, only
`employment_pressure`, since jobs are owner-assigned, never chosen by the
rat's own action-selection.
