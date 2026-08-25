# entities/job/

`Job extends Node2D` — a job is now a real entity, not a label on a
`Location`. `title: String`, `modifiers: JobModifiers` (the job's own
inherent per-need physical effect, independent of which station it's
performed at — its own dedicated class, `JobModifiers extends NeedFields`,
range `-20..20`, matching `LocationModifiers`' scale for consistency rather
than a distinct tighter job-only range), and `locations: Array[Location]`
(the stations that serve this job, hand-wired in the inspector via
`node_paths`, same mechanism `Location` uses for its own exported fields).

`Job` instances live as children of `JobManager` in the scene
(`managers/job_manager/`), which discovers them by scanning its own children
(`get_jobs()`) — same pattern `LocationManager.get_location_data()` already
used for `Location`. Adding a new job type is just adding a `Job` node under
`JobManager` and wiring its `locations`; nothing else needs to be told about
it.

All five jobs now exist in `main.tscn` (`HeadChef`, `SousChef`, `LineCook`,
`Dishwasher`, `Bartender`), each with one `Location` wired into `locations`
and its own distinct `modifiers` values — Head Chef's most physically
draining and isolating (highest-authority, on-call all shift), Bartender's
the most social and vice-adjacent, Dishwasher the most isolated and
tedious. **First-pass/temp values, not tuned** — see `docs/CURRENT_SPRINT.md`
and `docs/ALGORITHM_RESEARCH.md`; nothing in the sim is meaningfully tunable
yet since need decay isn't implemented.

**`JobConstants.JOB` (the old fixed enum) has been removed entirely.** It
used to be the identity for "which job" everywhere — rat assignment,
`NeedsEvaluator`'s `employment_pressure` check, the debug panel's
job-assignment buttons — but every one of those actually just needed *some*
stable identity per job, and a `Job` node reference already is one. The one
thing that used to force a fixed enum to exist was `JobSkills` needing a
hand-declared field per job type; `JobSkills` has since been removed too
(deferred, not abandoned — see `entities/rat/stats/README.md`), so nothing
requires the enum anymore. `JobConstants` itself still exists, now holding
only `EMPLOYMENT_PRESSURE` (a single global constant, not per-job, for now).

Unassigned is `null`, not a sentinel enum value — `Job` is a `Node`-derived
type, and object references in GDScript default to `null` when unset, same
as `Rat._destination`/`_current_location` before a rat has one.
`JobManager.assign_job(rat, job: Job)` requires a real, non-null `Job`;
clearing a rat's job goes through the separate `unassign_job(rat)` instead
of passing `null` into `assign_job` — one less branch for `assign_job` to
handle, since callers that mean "clear it" call the method that means that.

Note `Other.assigned_job: Job` is **not** `@export`ed, even though it's a
`Job` reference. `@export`ing a `Node`-typed field relies on Godot's
node-path resolution, which works for `Node`-derived classes with a real
position in the scene tree (like `Job.locations` on `Job` itself) but not
for `Resource`-derived classes like `Other` — there's no scene-relative path
to resolve. `assigned_job` is also purely runtime-set by
`JobManager.assign_job()` anyway, never hand-authored in the inspector, so
`@export` wasn't buying anything here regardless.
