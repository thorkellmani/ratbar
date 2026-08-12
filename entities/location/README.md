# entities/location/

`Location extends Marker2D` — a place a rat can travel to (job stations, Pantry,
Bartender, etc.). Two independent per-need fields, deliberately decoupled:

- `modifiers: Mood` — the physical per-hour effect on a rat's stats while
  stationary here. Real units, unbounded scale (e.g. Pantry nutrition `= 200`).
- `pull: LocationPull` — hand-authored decision-scoring appeal, `0..7`. `0`
  means "not a factor for this need at this location" (excluded from scoring,
  not a real judgment); `1..7` is a real appeal judgment. See
  `docs/CURRENT_SPRINT.md` for why the scale is `0..7` and not signed.

`job: JobConstants.JOB` ties a location to a job type for `employment_pressure`
and (eventually) `job_skills` progression — jobs have no `pull` of their own,
only `employment_pressure`, since jobs are owner-assigned, never chosen by the
rat's own action-selection.
