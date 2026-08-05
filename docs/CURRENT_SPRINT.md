# Current Sprint — Game Time

Goal: replace Sprint 1's ad hoc per-rat `Timer` with real simulation-time infrastructure — a centralized game clock, staggered per-rat decision scheduling, and a new mechanism that actually applies a location's effect to a rat's needs over time (nothing in the codebase does this yet — `NeedsEvaluator` only picks a destination, it never touches `rat.mood`). See `docs/sprints/01-minimal-watchable-loop.md` for how this sprint's scope was arrived at.

Explicitly out of scope this sprint: the location "quality" tag-value scale, the new Location Quality resource, and any rename of `Location._personality_modifiers`. This sprint keeps reading the existing `nutrition` field as-is — only *when* and *how often* it gets applied to the rat is changing, not the values themselves.

## Design decisions locked this sprint

- **Game-time convention:** 1 game-hour = 60 real seconds at 1x `Engine.time_scale`. A 16-hour shift plays out in 16 real minutes.
- **Two systems, fully decoupled:**
  - **Decision-making** (`Rat.reevaluate_needs`) — the existing scoring/comparison that picks *where* a rat should go. Runs on a staggered per-rat schedule: each rat gets a fixed slot at generation (e.g. `rat.id % NUM_SLOTS`), and only re-evaluates when the clock's current tick matches its slot. This replaces `Rat`'s own `DecisionPeriod` Timer, whose only real job was avoiding N rats all re-evaluating in the same frame.
  - **Need application** — a new step that actually changes a rat's stat over time (e.g. `mood.nutrition` ticking upward while stood at the Pantry). Runs every tick, for every rat, unconditionally — except while a rat is mid-travel (`state == PROCEEDING_TO_LOCATION`), when nothing is applied at all, since the rat isn't at any location yet.
- **`RatManager` is the sole listener of the new `GameClock` tick signal**, and is the only thing that calls into individual rats (`reevaluate_needs` for rats in the current slot, a new per-tick stat-update call for everyone). Rats do not each subscribe to the clock independently — that would mean N live signal connections and the slot-matching logic duplicated across every rat instance instead of living in one place. This matches the existing manager-owns-iteration pattern already used by `JobManager` and `LocationManager`.
- **`Rat` owns both `current_location` and `destination`.** `_destination` already meant `Rat` held direct references to `Location` objects for movement — so tracking `current_location` there too doesn't cross a new encapsulation boundary, it just extends the existing one. `current_location` persists after arrival instead of being cleared, and updates whenever a new destination is chosen.
- **Deferred, explicitly not this sprint:** the -5..+5 location quality scale, the new Location Quality resource, and moving `Location._job` into `JobManager`. All flagged for future sprints.

## Tasks

### `GameClock`
- [ ] Create `GameClock` (decide: new autoload, or a node under `Main`) with a fixed real-time tick interval
- [ ] Decide the tick interval and derive `ticks_per_hour = 60.0 / tick_interval_seconds` from the game-time convention above
- [ ] Emits a single `tick(tick_count: int)` signal

### `RatManager` as central driver
- [ ] `RatManager` connects to `GameClock.tick` once (not per-rat)
- [ ] `RatManager` assigns each rat a slot at generation time (`rat.id % NUM_SLOTS`) — decide `NUM_SLOTS`
- [ ] On each tick: for rats whose slot matches `tick_count % NUM_SLOTS`, call `rat.reevaluate_needs(...)` (existing method, unchanged)
- [ ] On each tick: for every rat unconditionally, call a new per-tick stat-update method (e.g. `rat.apply_stat_tick()`) — no-ops internally while `state == PROCEEDING_TO_LOCATION`
- [ ] Remove `Rat`'s `DecisionPeriod` Timer node and `_on_decision_period_timeout()`

### `Rat` location tracking
- [ ] Add `current_location: Location`, set whenever a new `destination` is chosen and left set after arrival (don't clear it in `_arrive_at_destination()` the way `destination` itself gets cleared)

### Need application
- [ ] `Rat.apply_stat_tick()`: if stationary (`state` is `WORKING`/`IDLE`) and `current_location` is set, add `current_location._personality_modifiers.nutrition / ticks_per_hour` to `mood.nutrition` this tick
- [ ] If `state == PROCEEDING_TO_LOCATION`, apply nothing this tick

## Test scenarios

1. **Slot distribution:** Generate N rats. Confirm each is assigned a slot in `0..NUM_SLOTS-1` at generation, and that `reevaluate_needs` only fires for a given rat on ticks matching its slot (log to confirm).
2. **Continuous nutrition tick:** Place a rat at the Pantry, stationary. Over several ticks, confirm `mood.nutrition` increases every tick regardless of whether that tick happens to be the rat's decision slot.
3. **No nutrition while traveling:** Force a rat into `PROCEEDING_TO_LOCATION`. Confirm `mood.nutrition` doesn't change on any tick while traveling, even on the rat's own decision slot.
4. **Timer removal sanity check:** Confirm `Rat` no longer has a `DecisionPeriod` Timer child, and nothing still depends on `RatConstants.DECISION_PERIOD` for per-rat scheduling (it may be repurposed as `GameClock`'s own interval, or removed).
5. **Time-scale interaction:** Set `Engine.time_scale` to 10x via the existing debug button. Confirm `GameClock` ticks proportionally faster and nutrition climbs at the same *game-time* rate — just compressed into less real time, not a different rate entirely.

## Next sprint (not this one) — location quality scale

Codify the -5..+5 quality scale discussed alongside this sprint, build the dedicated Location Quality resource (replacing the borrowed `Mood` type on `Location`), and re-point the six locations to it. Then extend the tick/need-application system built this sprint to `energy`, `stimulation`, `social`, `vice_satisfaction`, making the score a genuine `sum(need_urgency[n] × quality[n])` across all five needs.
