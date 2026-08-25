# Current Sprint — Need Decay

Goal: give all five needs a passive, flat baseline decay every tick — the missing layer that's been blocking real tuning last sprint (job/location modifiers, `pull` values, `NeedsEvaluator`'s power mean were all authored/verified against a rat whose needs never move unless a location actively pushes them). Location and job `modifiers` (built last sprint) become an *offset* against this baseline instead of the only thing moving a need at all. Once needs are continuously drifting rather than static, several downstream problems become real for the first time — this sprint also covers those.

Pulls from `docs/RAT_SIMULATION_BACKLOG.md` sections 1.7, 3, 6.5, 6.6b, 11.

## Design decisions locked this sprint

- **Baseline decay is flat and uniform across all five needs — no per-need state or personality-trait branching.** The backlog's original spec had energy decay faster while `WORKING`, social decay scaled by `socialness`, and vice_satisfaction decay scaled by `stress`/`addiction`. Rejected as inconsistent — building dynamic behavior for only one or two needs while the rest stay flat is arbitrary. All five needs get one flat per-tick rate (individually tuned for magnitude, structurally identical treatment). State-dependent variation (a job draining energy faster, a location boosting nutrition) stays entirely in the existing `LocationModifiers`/`JobModifiers` layer, which already gates on `WORKING`/stationary — adding a second, separate state-conditional inside decay itself would be two mechanisms pointed at the same knob.
- **`vice_satisfaction`'s stress/addiction-coupling (backlog 3.5) is dropped, not just deferred.** Addiction was removed entirely last sprint (vice simplified to a plain need); Stress System (backlog section 4) isn't built. Revisit only once Stress System exists as its own sprint — don't reach into it early.
- **Stimulation's "repetitive/unstimulating periods" condition (backlog 3.4) becomes flat baseline decay, not a repetition tracker.** Consistent with the flat-decay decision above.

## Open design questions this sprint needs to resolve

- **Switching inertia mechanism (backlog 6.6b).** Continuous decay means two near-tied locations' scores will drift across each other repeatedly; without a threshold, a rat near a tie could flicker its destination every reevaluation. Needs deciding: what counts as "near-tied" (fixed score-gap threshold vs. relative to the scores involved); whether the threshold only guards switching away from a *current* destination or also applies when picking between options from idle; whether `employment_pressure`'s flat additive bonus needs special handling so it doesn't create a permanent thumb on the scale that defeats the threshold for job locations specifically.
- **Repetition penalty shape (backlog 6.5, 1.7).** Needs deciding: which "source" fields to track (the backlog sketches `last_nutrition_source`, `last_stimulation_source`, `last_social_activity`/`last_social_partner_id` — do all four apply now that some of these needs work differently than originally designed, e.g. `social` no longer has a partner-selection mechanic built); how the penalty decays/resets (backlog: resets after visiting a different source in between); how it interacts with `pull` vs. `modifiers` (is the penalty a `pull` reduction — decision-scoring only — or does it also reduce the actual `modifiers` payout?).
- **Baseline decay's scope while traveling.** Does baseline decay apply during `PROCEEDING_TO_LOCATION`/`PROCEEDING_TO_WORK` (mid-travel), same as it does while stationary? Location/job `modifiers` currently only apply while stationary — baseline decay, as "natural entropy," should probably run regardless of travel state, but confirm before implementing.

## Tasks

### 1. Baseline decay
- [ ] Add a flat per-tick decay rate for each of the five needs, applied in `Rat.apply_stat_tick()` alongside the existing location/job modifier summing
- [ ] Resolve the traveling-state open question above, then implement accordingly
- [ ] Tune each need's rate individually for magnitude (structure stays identical across all five — see locked decision above)

### 2. Re-verify/retune against live decay
- [ ] Re-run last sprint's nutrition-slide test (`docs/ALGORITHM_RESEARCH.md`) with baseline decay active — confirm the starvation crossover (Pantry overtaking work around `nutrition ≈ -52`) still holds, or retune if baseline decay shifts it
- [ ] Confirm last sprint's location/job `modifiers` values still read sensibly as *offsets* against the new baseline (e.g. Pantry's `nutrition=20` should now visibly outpace baseline decay, not just be the only source of movement)

### 3. Debug panel decay visibility
- [ ] Expose the five baseline decay rates for live tuning (values visible/editable without a code change per test)
- [ ] A way to isolate baseline decay from location/job modifiers for testing (e.g. a toggle to zero out modifiers temporarily), so decay's own magnitude can be verified in isolation before re-adding modifiers on top

### 4. Switching inertia
- [ ] Resolve the open design question above
- [ ] Implement the agreed threshold mechanism in `NeedsEvaluator`/`Rat.reevaluate_needs()`

### 5. Repetition penalty + fulfillment history
- [ ] Resolve the open design question above
- [ ] Add last-source tracking per the resolved shape (backlog 1.7)
- [ ] Apply the penalty per the resolved shape (backlog 6.5)

### 6. Owner pressure spike
- [ ] Owner-triggered action temporarily boosts `employment_pressure` (backlog 11.1)
- [ ] Spike decays back to base over time
- [ ] Spike costs `owner_relationship` per rat, scaled so rats at lower relationship take a larger hit (backlog 11.2)
- [ ] Consecutive spikes in quick succession apply escalating relationship damage (backlog 11.3)

## Test scenarios

1. **Nutrition regression:** rat doing nothing — `nutrition` drops meaningfully below baseline over an extended run, at a rate matching the tuned constant.
2. **Per-job nutrition modifier still holds:** Head Chef vs. Dishwasher, identical starting nutrition, baseline decay active — Head Chef decays slower (its modifiers partially offset baseline), Dishwasher decays faster than baseline alone.
3. **Switching inertia:** two near-tied locations — confirm no flicker between reevaluations; widen the gap past the threshold — confirm the rat switches cleanly.
4. **Repetition penalty:** repeated consecutive use of the same source reduces its effective score; using a different source in between resets the penalty.
5. **Owner pressure spike:** trigger a spike — job location scores rise, decay back to base over time; `owner_relationship` drops per rat, more for already-low-relationship rats; rapid repeated spikes escalate the relationship cost.

## Notes for later sprints

- Stress System (backlog section 4) is the natural next sprint after this one — it's what `vice_satisfaction`'s dropped stress-coupling (3.5) and nutrition/energy's eventual stress-accumulation feedback (4.1) both need. Don't pull it in early just because this sprint touches decay.
- Job Modifiers values authored last sprint are still first-pass/temp — expect another tuning pass once baseline decay gives them something real to offset against (see task 2 above).
