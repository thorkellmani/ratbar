# Current Sprint — Full Need Wiring

Goal: extend `Location.pull` and `Location.modifiers` from the nutrition-only slice built in `docs/sprints/03-location-pull.md` to all five needs (`energy`, `social`, `stimulation`, `vice_satisfaction` join `nutrition`), and extend `NeedsEvaluator`'s formula from a single-need read into a genuine `sum(need_urgency[n] × pull[n])` across all five. This is the sprint every prior sprint's scope-limiting has been deferring to — see the "Next sprint" notes in both `docs/sprints/01-minimal-watchable-loop.md` and `docs/sprints/03-location-pull.md`.

## Open design questions this sprint needs to resolve

- **Combination logic.** The design doc's formula (`RAT_SIMULATION.md` → Action Selection → step 8) is a flat weighted sum: `sum(need_urgency[n] × modified_tag_value[n])`. Dave Mark's Infinite Axis Utility System (see `docs/RAT_SIMULATION_BACKLOG.md` References) argues for multiplying independently-normalized axes instead of summing them, specifically to avoid one need's urgency spike getting diluted or drowned out by four other lukewarm ones. Needs a real decision, not a default — re-derive rather than carry the single-need sprint's formula forward unexamined.
- **Curve shapes for the other four needs.** Only a `nutrition` `Curve` exists in `need_urgencies.tres` today. `RAT_SIMULATION.md`'s per-need curve-shape table (energy: broadly linear; stimulation: shallow throughout; social: progressively steepening; vice_satisfaction: scales with addiction level) needs four more `Curve` resources, each confirmed to output the same `0..1` range as `nutrition`'s — that comparability is load-bearing for whichever combination logic gets picked.

## Tasks

### `LocationPull` resource
- [ ] Add `energy`, `social`, `stimulation`, `vice_satisfaction` fields to `LocationPull`, same pattern as `nutrition`: clamped `-3..+3`, setter emits `stat_changed`

### `NeedUrgencies` / `MoodUrgency`
- [ ] Add `Curve` resources for `energy`, `stimulation`, `social`, `vice_satisfaction`, shaped per `RAT_SIMULATION.md`'s per-need description
- [ ] Confirm each curve's output range matches `nutrition`'s (`0..1`) — required for the needs to be comparable once summed/multiplied

### Location values
- [ ] Hand-author `pull` for all four new needs across all six locations (Pantry, three cook stations, Dishwasher, Bartender)
- [ ] Hand-author `modifiers` for all four new needs across all six locations (the physical per-hour rate — independent judgment from `pull`, same as nutrition's split)

### `NeedsEvaluator`
- [ ] Resolve the combination-logic question above, then implement it
- [ ] Extend `evaluate()` to score across all five needs instead of just `nutrition`
- [ ] Re-tune `JobConstants.EMPLOYMENT_PRESSURE` against the new multi-need formula — the nutrition-only crossover tuning (`0.376`) was solved for a single-term formula and is not guaranteed to hold once four more terms are added to every location's score

## Test scenarios

1. **Nutrition regression:** with all four new needs left neutral (`pull = 0`, urgency near baseline), the nutrition-only behavior from Sprint 3 still holds — same crossover, same location choices.
2. **A second need moves the needle:** change `pull.energy` (or any non-nutrition need) on a location and confirm `NeedsEvaluator`'s scores shift accordingly, without touching `nutrition`.
3. **Two urgent needs at once:** force two needs urgent simultaneously (e.g. `nutrition = -80`, `energy = -80`) with each best served by a different location. Confirm the chosen combination logic (sum vs. multiply) produces the intended winner — this is the real test of whichever design decision gets made above, not just a plumbing check.
4. **Curve sanity check:** sample each new curve at a few points per `RAT_SIMULATION.md`'s described shape (e.g. confirm `social`'s curve steepens progressively rather than having a single cliff like `nutrition`'s).
