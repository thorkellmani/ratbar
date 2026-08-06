# Current Sprint — Location Pull

Goal: split the one field `NeedsEvaluator` and `apply_stat_tick` currently share (`Location.modifiers`) into two — a physical per-hour rate (stays as `modifiers`, unchanged) and a new hand-authored, normalized decision-scoring signal (`Location.pull`). See `docs/sprints/02-game-time.md`'s "Findings during development" for how this need surfaced: once location modifiers were rescoped to real per-hour values, the same field could no longer honestly serve both "how fast does this physically work" and "how good a choice is this, compared to other locations" — those are different questions that only coincidentally shared a scale before.

This is the "smart object advertising" pattern (see `docs/RAT_SIMULATION_BACKLOG.md` References) done properly: locations advertise their appeal per need on a shared, comparable scale, decoupled from the physical simulation detail of how fast that appeal is actually delivered.

## Design decisions locked this sprint

- **`pull` is hand-authored, not computed from `modifiers`.** A location can be physically effective at satisfying a need while being unappealing, or vice versa (a nutritious broccoli basket vs. a bucket of crisps) — appeal and physical efficacy are independent facts about a location, so `pull` can't be a normalization formula over `modifiers`.
- **Scale: `-5..+5`**, matching the existing `-5..+5` convention floated earlier for personality/quality-style values.
- **Shape: a new `Resource` subclass, `Pull extends BaseStatGroup`**, mirroring `Mood`'s shape — one field per need (`nutrition`, `energy`, `social`, `stimulation`, `vice_satisfaction`), clamped to `-5..+5` via the existing `BaseStatGroup` min/max mechanism. A drop-in sibling to `Mood`, not a new kind of thing.
- **`Location.modifiers` is untouched** — stays exactly as rescoped in the Game Time sprint, feeding only `apply_stat_tick`. `NeedsEvaluator` switches to reading `Location.pull` instead.
- **Scope stays nutrition-only**, matching every prior sprint's scope-limiting — only `pull.nutrition` needs real hand-authored values this sprint; the other four fields exist on the resource but stay at defaults until their own needs get wired into scoring (Phase 2, same deferral as always).

## Tasks

### `Pull` resource
- [ ] Create `Pull extends BaseStatGroup` with `nutrition`, `energy`, `social`, `stimulation`, `vice_satisfaction` fields, clamped `-5..+5`
- [ ] Add `pull: Pull = Pull.new()` as a new `@export` field on `Location`, alongside the existing `modifiers`

### Rederive location values
- [ ] Hand-author `pull.nutrition` for all six locations (Pantry, three cook stations, Dishwasher, Bartender) — a fresh judgment call per location, not derived from their `modifiers.nutrition` values
- [ ] Rederive `JobConstants.EMPLOYMENT_PRESSURE` against the new `-5..+5`-scale scoring formula (it was tuned to `33.84` against the old `0..200` `modifiers`-based formula — that value is now meaningless)
- [ ] Re-check the nutrition urgency curve's crossover point (previously tuned to `-40`) against the new scale — confirm it still lands where intended, retune if not

### `NeedsEvaluator`
- [ ] Change `evaluate()` to read `location.pull.nutrition` instead of `location.modifiers.nutrition`

## Test scenarios

1. **Modifiers untouched:** Confirm `apply_stat_tick`'s nutrition-per-tick math is unaffected by this sprint — same behavior as the end of the Game Time sprint.
2. **Scoring uses the new field:** Change `pull.nutrition` on a location and confirm `NeedsEvaluator`'s scores move accordingly; changing `modifiers.nutrition` should no longer affect scoring at all.
3. **Crossover sanity check:** With the rederived `EMPLOYMENT_PRESSURE` and curve, re-run the earlier debug-panel test (override `nutrition` to `-40`) and confirm the job-vs-Pantry crossover still lands where intended.
4. **Broccoli/crisps case:** Set up two locations with inverted `modifiers`/`pull` relationships (one high-`modifiers`/low-`pull`, one low-`modifiers`/high-`pull`) and confirm `NeedsEvaluator` picks based on `pull`, not `modifiers`.

## Next sprint (not this one)

Wire the remaining four needs (`energy`, `stimulation`, `social`, `vice_satisfaction`) into both `pull` and `modifiers` across all locations, and extend `NeedsEvaluator`'s formula to a genuine `sum(need_urgency[n] × pull[n])` across all five needs — worth re-deriving the combination logic then (weighted sum vs. multiplicative, per Dave Mark's discussion of combining considerations) rather than guessing ahead now.
