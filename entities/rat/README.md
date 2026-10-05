# Rat

`Rat extends Area2D` holds one rat's needs, personality, status, relationships,
and activity state. `RatManager` drives its simulation ticks and scheduled
decisions; the rat does not run its own timer.

## Need is condition; urgency is want

- **Need value** (`rat.needs`) records how fulfilled each of the five needs is,
  from `-100` (deprived) to `+100` (satisfied). It changes through baseline
  decay and applicable location or job effects. A need value is not a measure
  of how strongly the rat wants to act.
- **Urgency** is the rat's subjective level of want for that need. Its
  per-need `Curve` maps the current need value to a `0..1` urgency. The curves
  have different shapes because the same need value need not feel equally
  pressing for nutrition, social contact, stimulation, energy, and vice.
  Urgency may be nonzero when a need is neutral or positive.
- **Location pull** describes how appealing a location is for a need. The
  evaluator combines the rat's urgency with each location's pull to choose
  where to go. Pull is separate from the location's physical effect on the
  need; choosing a location does not itself satisfy a need.
- **Stress** is a mental state that changes over time with how the rat feels.
  Need conditions and the importance felt through urgency inform that response.
  In the stress calculation, a need whose net change is positive
  after decay and applicable modifiers samples its urgency as if fully
  satisfied (`+100`); the stored need and location-choice urgency still use
  the actual value. This does not add a
  separate independent "Current feeling" stat. `Rat` caches the resulting
  effective average urgency (`0..1`) for its stress tick and debug display.
  See `systems/stress/` for the tier calculation and tunable rates. Active work
  at a station for the assigned job adds a flat
  stress rate after the need-based tier is selected; assignment or travel alone
  does not.

For example, `social = 0` describes a neutral level of social fulfillment. It
does not imply that the rat has no desire to socialize. Read the social urgency
curve to find that desire.

## Runtime responsibilities

`apply_game_tick_effects(assigned_job)` is the rat's public tick entry point. It
applies per-hour baseline decay to all five needs, then updates stress from the
resulting urgency average. Need decay continues during travel. While the rat is at a
location, location modifiers offset that decay; job modifiers also apply when
it is working at one of its assigned job's stations. `reevaluate_needs()` runs
only on the rat's assigned decision slot and asks `NeedsEvaluator` to pick a
location. `Rat` travels toward it in `_process()` and records it as the current
location on arrival.

See `stats/` for the stat `Resource` classes, `needs_evaluator/` for urgency
curves and location scoring, and `generation_defaults/` for starting values.
`rat_constants.gd` holds the activity and crisis enums. Vice types and job
skills are deferred; see `stats/README.md`.
