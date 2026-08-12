# Current Sprint — Full Need Wiring

Goal: extend `Location.pull` and `Location.modifiers` from the nutrition-only slice built in `docs/sprints/03-location-pull.md` to all five needs (`energy`, `social`, `stimulation`, `vice_satisfaction` join `nutrition`), and extend `NeedsEvaluator`'s formula from a single-need read into a genuine `sum(need_urgency[n] × pull[n])` across all five. This is the sprint every prior sprint's scope-limiting has been deferring to — see the "Next sprint" notes in both `docs/sprints/01-minimal-watchable-loop.md` and `docs/sprints/03-location-pull.md`.

## Open design questions this sprint needs to resolve

- **Combination logic.** The design doc's formula (`RAT_SIMULATION.md` → Action Selection → step 8) is a flat weighted sum: `sum(need_urgency[n] × modified_tag_value[n])`. Dave Mark's Infinite Axis Utility System (see `docs/RAT_SIMULATION_BACKLOG.md` References) argues for multiplying independently-normalized axes instead of summing them, specifically to avoid one need's urgency spike getting diluted or drowned out by four other lukewarm ones. Needs a real decision, not a default — re-derive rather than carry the single-need sprint's formula forward unexamined.
- **Curve shapes for the other four needs.** Only a `nutrition` `Curve` exists in `need_urgencies.tres` today. `RAT_SIMULATION.md`'s per-need curve-shape table (energy: broadly linear; stimulation: shallow throughout; social: progressively steepening; vice_satisfaction: scales with addiction level) needs four more `Curve` resources, each confirmed to output the same `0..1` range as `nutrition`'s — that comparability is load-bearing for whichever combination logic gets picked.

## Design decisions locked this sprint

- **`modifiers` stays job-agnostic; job exertion gets its own owned modifiers, summed with the location's.** A job's inherent physical cost/benefit (e.g. "dishwashing burns energy") is a fact about the *role*, not the *place*, and must not be smuggled into a location's per-need `modifiers` field as a same-need or cross-need proxy. It's authored on a separate job-owned modifiers structure and added to `location.modifiers` each tick — see the new `Job Modifiers` task below. Each need's `modifiers` field (location- or job-owned) stays literal to its own domain: `modifiers.nutrition` is strictly "does this affect food in the rat," `modifiers.energy` is strictly "does this tire the rat out," etc. No clamping is needed on the summed value itself — it only ever feeds into `mood.*`'s own already-clamped setter.
- **`pull` stays location-only; jobs have no `pull`, only `employment_pressure`.** Jobs are owner-assigned, never chosen by the rat's own action-selection, so there's no scenario where a job needs to compete for attention via an appeal signal the way locations do via `pull`. `employment_pressure` (already built) is the correct and only job-side scoring mechanism — no job-level `pull` field is needed or planned.
- **`LocationPull`'s scale changes from `-3..+3` to `0..7`, with `0` now strictly meaning "not a factor for this need at this location" — never a real judgment.** This replaces the prior meaning of `0` ("unbothered," a real Likert point) and removes negative values entirely. Reasons, from working through concrete scenarios: (1) `urgency × pull` with negative `pull` made desperation *amplify rejection* of a repulsive-but-real option instead of eventually overriding it — the "hungry enough to eat a dusty nutritional cube" case needs `pull` to only ever grow toward mattering as urgency rises, never shrink further negative; (2) `pull` was never meant to encode raw nutritional value (that's `modifiers`) — it encodes preference, and a location having *any* real value for a need should always demand an explicit, non-zero `pull` judgment, which needs `0` to unambiguously mean "excluded" so the omission is detectable (`modifiers[need] != 0` but `pull[need] == 0` is now a real error condition, not a legitimate authored state); (3) as a side effect, this also matches IAUS's "only score considerations that actually apply" pattern if multiply is ever adopted later. All six locations' existing `pull.nutrition` values (Pantry `+3`, cook stations `+1`, Dishwasher `-1`, Bartender `0`) predate this change and need re-authoring under the new scale, not a mechanical shift — see task below.
- **Job↔Location assignment moves from `Location.job` to a `JobManager`-owned mapping.** `Location` becomes purely a physical/appeal/modifiers carrier — job-assignment bookkeeping centralizes in `JobManager`, mirroring how rat↔job assignment already works there (`_ASSIGNED_JOBS: Dictionary[int, JOB]`). Shape: `Dictionary[JobConstants.JOB, Array[Location]]`, plural per job — multiple physical stations can serve the same job (matches `LocationManager.get_job_locations()`'s existing `Array[Vector2]` return, and the backlog's job-slots/pods design). See the new task below for touch points.

## Tasks

### `LocationPull` resource
- [ ] Add `energy`, `social`, `stimulation`, `vice_satisfaction` fields to `LocationPull`, same pattern as `nutrition`: clamped `-3..+3`, setter emits `stat_changed`

### `NeedUrgencies` / `MoodUrgency`
- [ ] Add `Curve` resources for `energy`, `stimulation`, `social`, `vice_satisfaction`, shaped per `RAT_SIMULATION.md`'s per-need description
- [ ] Confirm each curve's output range matches `nutrition`'s (`0..1`) — required for the needs to be comparable once summed/multiplied

### Location values
- [ ] Reclassify all six locations' existing `pull.nutrition` values under the new `0..7` scale (`0` = not a factor) — a fresh judgment call per location, not a mechanical shift of the old `-3..+3` numbers
- [ ] Hand-author `pull` for all four new needs across all six locations (Pantry, three cook stations, Dishwasher, Bartender)
- [ ] Hand-author `modifiers` for all four new needs across all six locations (the physical per-hour rate — independent judgment from `pull`, same as nutrition's split)

### `NeedsEvaluator`
- [ ] Resolve the combination-logic question above, then implement it
- [ ] Extend `evaluate()` to score across all five needs instead of just `nutrition`
- [ ] Re-tune `JobConstants.EMPLOYMENT_PRESSURE` against the new multi-need formula — the nutrition-only crossover tuning (`0.376`) was solved for a single-term formula and is not guaranteed to hold once four more terms are added to every location's score

### Job↔Location assignment (new this sprint)
- [ ] Remove `Location.job`
- [ ] Add the job↔location mapping to `JobManager`: `Dictionary[JobConstants.JOB, Array[Location]]`
- [ ] Open question — how is this dictionary populated: does `Location` keep a design-time-only field `JobManager` reads once at `_ready` to seed it, or does `JobManager` author the mapping directly via exported `Location` references, with no job-identity field on `Location` at all? Decide before implementing, not while implementing.
- [ ] Update `LocationManager.get_job_locations()` — delegate to (or get replaced by) `JobManager`'s mapping instead of filtering `Location` children by a field that no longer exists
- [ ] Update `NeedsEvaluator.evaluate()`'s `employment_pressure` check to query `JobManager` instead of reading `location.job`
- [ ] Update `Rat._arrive_at_destination()`'s `WORKING`/`IDLE` decision to query `JobManager` instead of reading `_destination.job`

### Job Modifiers (new this sprint)
- [ ] Create a job-owned modifiers structure — a `Mood`-shaped resource per `JobConstants.JOB`, holding each job's inherent per-need physical effect, independent of which station it happens to be performed at
- [ ] Hand-author job modifiers for the five existing jobs (`HEAD_COOK`, `LINE_COOK`, `PREP_COOK`, `DISHWASHER`, `BARTENDER`) — at minimum for the needs already in scope this sprint; extend to all five if it's cheap to do while the values are already being reasoned about
- [ ] Update `apply_stat_tick` (section 2.4, already built) to sum `location.modifiers[need] + job_modifiers[assigned_job][need]` while the rat is stationary and actively assigned to the job matching its current location, instead of reading `location.modifiers` alone

## Test scenarios

1. **Nutrition regression:** with all four new needs left neutral (`pull = 0`, urgency near baseline), the nutrition-only behavior from Sprint 3 still holds — same crossover, same location choices.
2. **A second need moves the needle:** change `pull.energy` (or any non-nutrition need) on a location and confirm `NeedsEvaluator`'s scores shift accordingly, without touching `nutrition`.
3. **Two urgent needs at once:** force two needs urgent simultaneously (e.g. `nutrition = -80`, `energy = -80`) with each best served by a different location. Confirm the chosen combination logic (sum vs. multiply) produces the intended winner — this is the real test of whichever design decision gets made above, not just a plumbing check.
4. **Curve sanity check:** sample each new curve at a few points per `RAT_SIMULATION.md`'s described shape (e.g. confirm `social`'s curve steepens progressively rather than having a single cliff like `nutrition`'s).
5. **Job modifier stacks with location modifier:** a rat assigned to a job with a nonzero job-modifier on some need (e.g. energy) shows a visibly different decay/gain rate for that need while working its station than an otherwise-identical rat idling at the same station unassigned — confirming the two sources combine rather than one silently overriding the other.
6. **Job↔location reassignment doesn't touch `Location`:** reassigning which `Location`(s) serve a given job via `JobManager`'s mapping requires no change to the `Location` node itself — confirm `NeedsEvaluator`'s `employment_pressure` check and `Rat`'s `WORKING`/`IDLE` decision both follow the updated `JobManager` mapping immediately, not a stale value read from `Location`.

## Notes for later sprints

- **Byproduct: `Location.job` could become decouplable from `Location.modifiers`/`pull`.** Once every need's physical effect is authored as a literal, job-agnostic fact about the *place* rather than the *job* (this sprint's job-modifiers split, below), `Location.job` stops being load-bearing for stat effects — it becomes pure metadata (employment_pressure eligibility, which `job_skills[]` entry progresses while working there). That's a real precondition for dynamic job-to-location assignment later, but it's only a partial enabler: `job_skills` progression and `employment_pressure` still need *some* current job↔location resolution mechanism beyond the fixed 1:1 `Location.job` field, which doesn't exist yet and is out of scope for this sprint. Worth a real design pass in a future sprint, not something to build now.
