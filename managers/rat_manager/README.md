# managers/rat_manager/

`RatManager` — owns the sim's tick loop. On every `GameClock.tick`:
- every rat gets `apply_location_modifiers()` (needs-application, unconditional)
- only rats whose assigned tick slot matches this tick get `reevaluate_needs()`
  (decision-making, throttled)

`_assign_slot()` gives each new rat a weighted-random slot out of
`GameConstants.GAME_TICK_SLOTS`, biased toward less-occupied slots — this is
what staggers rats instead of having them all decide in lockstep.

`TickSlotRegistry` (`rat_registry.gd`) is the small per-slot struct
(`idx`, `rats: Array[Rat]`) backing that assignment.
