# Current Sprint

## Need Decay and Choice Commitment

Make needs drift continuously, then keep a rat at its chosen location until its main need is satisfied or another need becomes critical. See the [historical decision log](sprints/04-need-decay-decisions.md) for the reasoning and superseded proposals.

### Decisions made

- All five needs start with flat, independently configurable decay of `-5` per game-hour, including during travel. Location and job modifiers offset it while stationary.
- On choosing a destination, the rat commits to the most urgent active need at that location until it reaches its `GenerationDefaults` baseline.
- Any need crossing below the shared `DEAD_BAND_FLOOR` interrupts the commitment immediately, without waiting for the next decision slot.

### Tasks

- [x] Apply baseline decay to all five needs on every game tick, including during travel.
  **Test scenario:** With no location effect, all five needs fall at their configured rates while idle and while traveling.

- [x] Recheck the nutrition crossover and modifier offsets with decay active.
  **Test scenario:** Pantry overtakes Head Chef around `nutrition = -52`, and Pantry's `+20` nutrition modifier raises nutrition despite the `-5` baseline decay.

- [ ] Track the highest curve-sampled urgency among the chosen location's active needs and hold the destination until that need reaches its generation baseline.
  **Test scenario:** A rat stays committed through scheduled decision ticks, then reevaluates when its primary need reaches its baseline.

- [ ] Interrupt commitment when any need crosses below `DEAD_BAND_FLOOR` and reevaluate immediately.
  **Test scenario:** Push a different need below the floor between scheduled decision ticks; the rat reevaluates on the crossing rather than waiting for its slot.

### Retrospective

#### Findings so far

- Baseline decay left the observed Pantry crossover around `nutrition = -52` unchanged.
- Location and job modifiers now offset a continuous baseline; their values remain first-pass tuning.

#### Notes for later sprints

- Build the Stress System after this sprint; revisit stress-driven vice effects then.
- Tune decay rates and per-need crisis floors after observing commitment behavior.
- Define a fulfillment event before adding fulfillment history or repetition penalties. Location effects currently apply every tick.
- Revisit owner pressure spikes when relationship and stress costs can affect behavior. Add live decay controls or modifier isolation only if testing calls for them.
