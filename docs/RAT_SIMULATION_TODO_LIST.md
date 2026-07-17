# Rat Simulation — Implementation TODO

Each task is broken into atomic parts. Each part has a verification test.
Godot has no automated test runner — verification is done by running the scene and observing the described outcome.

## 0. Debug Suite

### 0.1 Rat inspector overlay
- [x] Clicking a rat in the scene opens a debug panel showing all internal stats in real time
- [x] Panel updates each tick (no manual refresh needed)
- [ ] Panel displays:
  - [x] greed
  - [x] temper
  - [x] socialness
  - [x] ambition
  - [x] laziness
  - [x] nutrition
  - [x] energy
  - [x] stimulation
  - [x] social
  - [x] vice_satisfaction
  - [x] stress
  - [x] health
  - [x] inebriation
  - [x] radicalization
  - [x] extra_stress
  - [x] owner_relationship
  - [ ] primary_vice
  - [ ] addiction per vice
  - [x] crisis_state
  - [x] assigned_job
  - [x] job_skills per job
- [x] Clicking another rat switches the panel to that rat; clicking the same rat closes it

**Test:** Run the scene. Click a rat. Panel appears with readable stat values that update live. Change a stat via a cheat input or direct GDScript — panel reflects the change immediately. Click a second rat — panel switches. Click empty space or same rat — panel closes.

### 0.2 Rat stat override (cheat input)
- [x] LineEdit `text_submitted` signal connected for each stat row
- [x] On submission, look up which stat the LineEdit belongs to (accessor + enum key)
- [x] Write new value back to the rat via the appropriate update function
- [x] Clamp submitted value to the valid range for that stat before writing

**Test:** Set `stress` to 100 via the override input. Confirm the rat's `crisis_state` changes to BURNOUT or REBELLION. Set `nutrition` to -80. Confirm the need decay and action selection reflect the new value immediately.

### 0.3 Simulation speed control
- [ ] A debug control allows time-scaling the simulation (0.5×, 1×, 2×, 5×, 10×) so decay and stress tests can be verified in a reasonable amount of real time

**Test:** Set time scale to 10×. One in-game shift should complete in roughly 1/10th of normal wall-clock time. Stats (nutrition, energy, stress) should decay at the same in-game rate as normal speed — just faster in real time.

---

## 1. Rat Data Model

### 1.1 Personality stats
- [x] Add five personality fields to `Rat`: `greed`, `temper`, `socialness`, `ambition`, `laziness` (int, -100 to 100)
- [x] Randomise on `_ready()` using default bias from the design doc (greed +40, temper +10, socialness +60, ambition -20, laziness +20)

**Test:** Print all five stats for a freshly generated rat. Confirm they are within -100/100 and cluster around their intended defaults across 10 generated rats.

### 1.2 Need stats
- [x] Add five need fields: `nutrition`, `energy`, `stimulation`, `social`, `vice_satisfaction` (float, -100 to 100, default 0)

**Test:** Inspect a rat immediately after generation. All five needs read 0.

### 1.3 Status stats
- [x] Add: `stress` (0–100), `health` (0–100, default 100), `inebriation` (0–100), `owner_relationship` (-100 to 100), `radicalization` (0–100), `extra_stress` (0–100), `currency` (float, ≥ 0)

**Test:** New rat has stress=0, health=100, inebriation=0, owner_relationship=0, radicalization=0, extra_stress=0.

### 1.4 Job skills dictionary
- [x] Add `job_skills: Dictionary[Constants.JOB, float]` (0–10 per job)
- [ ] Populate on generation with a random roll seeded by personality fit
  - [ ] High ambition → higher head cook and line cook rolls
  - [ ] High socialness → higher bartender rolls

**Test:** Generate 20 rats. High-ambition rats (ambition > 50) should average higher cook skill than low-ambition rats (ambition < -50). Print comparison.

### 1.5 Vice and addiction
- [ ] Add `primary_vice: Constants.VICE`
- [ ] Add `addiction: Dictionary[Constants.VICE, float]` (0–100 per vice, starts 0)
- [ ] Assign primary vice on generation weighted by personality

**Test:** Generate 10 rats. Every rat has exactly one primary_vice. All addiction values are 0. High-stress rats rerolled with higher temper should skew toward fighting/drugs — test by forcing temper=100 on 10 rats and checking the vice distribution.

### 1.6 Camaraderie
- [ ] Add `camaraderie: Dictionary[int, float]` (rat_id → -100 to 100)
- [ ] First meeting seeds value near 0 with slight positive bias (+5 to +15)

**Test:** Create two rats. Trigger a first-meeting between them. Both rats' camaraderie dictionaries contain the other's ID with a value between +5 and +15.

### 1.7 Fulfillment history
- [ ] Add per-need last-source tracking:
  - [ ] `last_nutrition_source`
  - [ ] `last_stimulation_source`
  - [ ] `last_social_activity`
  - [ ] `last_social_partner_id`

**Test:** After a rat eats at a specific food location, `last_nutrition_source` is set to that location's ID.

---

## 2. Need Decay

### 2.1 Nutrition decay
- [ ] Nutrition decays at a baseline rate each tick while the rat is awake (target: roughly hungry twice per shift)

**Test:** Run the simulation for one in-game shift with a rat doing nothing. Confirm `nutrition` drops from 0 to below -40 by end of shift.

### 2.2 Energy decay
- [ ] Energy decays while awake; faster while working

**Test:** Run one rat with JOB_STATE=WORKING and another with JOB_STATE=IDLE for the same duration. Working rat's energy should be lower by a clear margin (>20% faster decay).

### 2.3 Social decay
- [ ] Social decays while awake
- [ ] Decay rate scaled by `socialness` stat (high socialness → faster decay)

**Test:** Run two rats with identical needs but socialness=100 and socialness=-100 for the same duration. Socialness=100 rat should have meaningfully lower social need.

### 2.4 Stimulation decay
- [ ] Stimulation decays during repetitive/unstimulating periods

**Test:** Rat stuck in a dishwasher job for a full shift: stimulation should be negative by end of shift. Same rat given varied activities: stimulation should stay closer to 0.

### 2.5 Vice satisfaction decay
- [ ] `vice_satisfaction` decays proportional to stress level (high stress → faster decay)
- [ ] Addiction level amplifies the decay rate

**Test 1:** Two rats, same stress. One has addiction=0, one has addiction=80 for their vice. Addiction=80 rat should lose vice_satisfaction faster.
**Test 2:** Same rat, stress=10 vs stress=80. High-stress condition produces faster vice_satisfaction decay.

---

## 3. Stress System

### 3.1 Stress accumulation from unmet needs
- [ ] Each tick, unmet needs (negative values) add to stress, weighted by severity

**Test:** Set a rat's nutrition to -80. Over 5 seconds of simulation, stress should climb. A rat with nutrition=10 should not gain stress from nutrition alone.

### 3.2 Temper multiplier
- [ ] High-`temper` rats accumulate stress faster from the same conditions

**Test:** Two rats, identical unmet needs, temper=100 vs temper=-100. After 10 seconds, temper=100 rat has higher stress.

### 3.3 Owner relationship effect on accumulation
- [ ] Low `owner_relationship` → faster stress accumulation

**Test:** Same rat, same unmet needs, set owner_relationship=-80 vs owner_relationship=+80. -80 condition produces faster stress gain.

### 3.4 Stress decay from met needs
- [ ] Positive need values reduce stress over time

**Test:** Set a rat's stress to 60, all needs to +50. Stress should decrease over 10 seconds.

### 3.5 Vice as stress relief
- [ ] Using a vice is the fastest stress relief

**Test:** Two stressed rats (stress=70). One uses vice, one does nothing. After the same time window, vice-user has lower stress.

### 3.6 Breaking point roll
- [ ] When stress hits 100, trigger a roll for crisis state (burnout or rebellion)
- [ ] High temper + low owner_relationship → skews toward rebellion
- [ ] Prolonged overwork → skews toward burnout

**Test:** Force stress to 100 on a rat with temper=100 and owner_relationship=-80. Run 10 trials. At least 6/10 should result in REBELLION. Force stress to 100 on an overworked rat with owner_relationship=+60. At least 6/10 should result in BURNOUT.

---

## 4. Crisis States

### 4.1 Burnout entry and visibility
- [ ] Enter BURNOUT state when breaking point roll resolves to burnout
- [ ] Burnout should be visually obvious (animation or indicator)

**Test:** Trigger burnout on a rat. Confirm the rat's `crisis_state` is BURNOUT. Confirm a visible change in the rat's appearance or animation.

### 4.2 Burnout effects
- [ ] Stress locked at 100 while in burnout
- [ ] `vice_satisfaction` decays faster
- [ ] `energy` decays faster
- [ ] Job performance multiplier severely reduced

**Test:** Rat in BURNOUT. Stress cannot be reduced below 100. Compare energy decay rate to same rat not in burnout: burnout rat decays meaningfully faster. Measure job performance output — burnout rat should be well below baseline.

### 4.3 Extra stress in burnout
- [ ] If owner assigns work to a burned-out rat, `extra_stress` increments
- [ ] `extra_stress` at 100 kills the rat

**Test:** Put a rat in BURNOUT. Assign it a job. Confirm `extra_stress` is incrementing. Force `extra_stress` to 100, confirm rat is removed from RATS dictionary and a colony-wide owner_relationship penalty is applied.

### 4.4 Rebellion entry and concealment
- [ ] Enter REBELLION when breaking point roll resolves to rebellion
- [ ] Rat's `mood` signal is suppressed (rat appears fine externally)

**Test:** Rat enters REBELLION. Its displayed mood reads neutral or positive despite internal stats. Internally, `crisis_state` is REBELLION.

### 4.5 Organizer behavior
- [ ] Rebellious rat continues working (so as not to flag)
- [ ] Each tick, it broadcasts an organizer signal to nearby rats
- [ ] Target rats' `radicalization` increments based on susceptibility

**Test:** Place an organizer rat next to three target rats. After 30 seconds, all three target rats have `radicalization` > 0. Rats with high socialness/ambition/temper should gain more radicalization than low-stat rats.

### 4.6 Radicalization escalation and environmental tells
- [ ] As radicalization spreads, environmental tells appear in the scene (pamphlets, ribbons, propaganda objects)
- [ ] Tells scale with average colony radicalization

**Test:** Push average colony radicalization above 30. At least one environmental tell should appear in the scene. Push above 60 — tells should be unmistakable (multiple objects or a prominent indicator).

---

## 5. Action Selection

### 5.1 Location broadcasts
- [ ] Each location node emits a tag dictionary:
  - [ ] `nutrition`
  - [ ] `energy`
  - [ ] `stimulation`
  - [ ] `social`
  - [ ] `vice_satisfaction`
  - [ ] `stress`
  - [ ] `health`
  - [ ] `inebriation`
  - [ ] `skill_progression`
  - [ ] `employment_pressure`

**Test:** Print all broadcast values from at least three different location types (food, job, vice). Confirm each has a non-zero value for at least the tags relevant to that location type.

### 5.2 Personality modifier
- [ ] Raw tag values are modified per rat based on personality stats before scoring
- [ ] Lazy rats amplify rest/idle tags
- [ ] Social rats amplify social tags
- [ ] Ambitious rats amplify `employment_pressure` if `owner_relationship` is positive

**Test:** Two rats: one laziness=100, one laziness=-100. Both evaluate the same idle location. Lazy rat assigns higher score to the idle location. Social rats should score social locations higher than anti-social rats.

### 5.3 Adjacency modifier
- [ ] When scoring a location, check who else is there
- [ ] Apply camaraderie toward each adjacent rat as a modifier
- [ ] Scale with evaluating rat's `socialness`

**Test:** Two rats with camaraderie=80 toward each other. Social rat (socialness=80) should score the location higher when friend is present vs when a stranger is present. Anti-social rat (socialness=-80) should show less difference.

### 5.4 Stress distortion
- [ ] High stress boosts vice tags and suppresses work tags globally

**Test:** Same rat, same locations. Stress=10 vs stress=80. At stress=80, the vice location score is higher and the job location score is lower compared to stress=10.

### 5.5 Repetition penalty
- [ ] If the rat uses the same need-satisfaction source consecutively, reduce that source's tag values

**Test:** Rat eats at food_stall_A twice in a row. On the third evaluation, food_stall_A's nutrition tag value is reduced compared to the first visit. After eating at food_stall_B in between, the penalty on food_stall_A resets.

### 5.6 Final score calculation and selection
- [ ] Score = sum(need_urgency[n] × modified_tag_value[n]) + small random variance
- [ ] Rat moves toward highest-scoring location

**Test:** Force a rat to have nutrition=-80 (urgent hunger) and place a food source nearby. The rat should select the food location on the next tick. Print scores for all locations — food location score should be highest by a clear margin.

### 5.7 Employment pressure
- [ ] Job locations always emit a base `employment_pressure` tag
- [ ] Owner can spike employment_pressure (temporary boost to all job location scores)
- [ ] Spike decays back to base; costs owner_relationship per rat

**Test:** Set all rats to idle with moderate needs. Trigger an owner pressure spike. Confirm rats move toward job locations. 30 seconds after spike: owner_relationship of each rat should be slightly lower than before the spike.

---

## 6. Job System

### 6.1 Job slots and pods
- [ ] Track how many rats are assigned to each job (fixed slots per the design doc)
- [ ] Rats in the same job form a pod

**Test:** Assign 4 rats to LINE_COOK (max 3). The fourth assignment should be rejected or queued. Print pod members — exactly 3 rats listed.

### 6.2 Personality fit modifier
- [ ] Calculate `personality_fit_modifier` per job per rat based on stat match

**Test:** Create a high-ambition low-laziness rat and a high-laziness rat. Both do HEAD_COOK. High-ambition rat's personality_fit_modifier should be significantly higher.

### 6.3 Job performance formula
- [ ] `performance = job_skill × personality_fit_modifier × current_state_modifier`
- [ ] `current_state_modifier` reduced by:
  - [ ] Negative needs
  - [ ] Stress
  - [ ] Inebriation
  - [ ] Low health
  - [ ] Burnout

**Test:** Same rat, max needs vs depleted needs. Performance should be measurably lower with depleted needs. Add stress=80 — performance drops further.

### 6.4 Pod performance
- [ ] `pod_performance` = average individual performance, modified by group dynamics
- [ ] Inebriated pod-mates degrade the overall pod score

**Test:** Pod of 3 rats, all performing at baseline. Add one rat with inebriation=80. Pod performance should decrease. Camaraderie=90 between two pod-mates should provide a small bonus relative to the same pod with camaraderie=0.

### 6.5 Job skill progression
- [ ] `job_skills[job]` increments slowly while rat is actively working that job
- [ ] Skills never decay

**Test:** Run a rat on the same job for a full shift. `job_skills[job]` at end of shift should be slightly higher than at start. Swap to a different job — original job skill does not change.

### 6.6 Job variety requirement
- [ ] Prolonged assignment to the same job adds a cumulative stress penalty (separate from other stress sources)

**Test:** Keep a rat on the same job for 3 in-game shifts. Stress should be rising from the job variety penalty alone, even if all needs are met.

---

## 7. Rat-to-Rat Interactions

### 7.1 Social broadcasts
- [ ] When a rat's `social` need is negative, it emits a social broadcast
- [ ] Nearby rats score the broadcast in action selection

**Test:** Rat A has social=-60. Rat B (socialness=80, camaraderie toward A = 60) is nearby. Rat B should move toward Rat A. Rat C (socialness=-80, camaraderie=0) should not be pulled toward Rat A.

### 7.2 Camaraderie change over time
- [ ] Neutral/good interactions increment camaraderie slightly
- [ ] Bad interactions decrement camaraderie
- [ ] Slow decay without interaction

**Test:** Two rats interact positively 5 times. Camaraderie should be higher than starting value. Simulate 5 bad interactions — camaraderie should drop. Leave two rats without interaction for a full shift — camaraderie should decrease slightly.

### 7.3 Conflict and fighting
- [ ] If one rat has FIGHTING as their vice and camaraderie toward another rat is sufficiently negative, it may broadcast a fight
- [ ] High-temper, low-stimulation, low-social recipient is more likely to accept

**Test:** Set up: Rat A has fighting vice, camaraderie toward Rat B = -70. Rat B has temper=80, stimulation=-50. Run for 20 seconds. A fight should trigger. Confirm both rats' `health` decreases. Confirm camaraderie between them worsens further.

### 7.4 Proximity effects
- [ ] High-socialness rats increase social fulfillment for nearby rats during interaction
- [ ] Low-socialness rats contribute less to others' fulfillment

**Test:** Rat A (socialness=90) and Rat B (socialness=-90) each interact socially with Rat C. After the same interaction duration, Rat C's social need should be more fulfilled from the interaction with Rat A.

---

## 8. Vice System

### 8.1 Vice usage fulfills vice_satisfaction and increases addiction
- [ ] Using a vice:
  - [ ] Raises `vice_satisfaction`
  - [ ] Decreases stress
  - [ ] Increases `addiction[primary_vice]`
- [ ] Inebriation-inducing vices (drinking, drugs) also raise `inebriation`

**Test:** Rat uses their vice. Before/after: `vice_satisfaction` increases, `stress` decreases, `addiction[primary_vice]` increases. If vice is drinking/drugs, `inebriation` also increases.

### 8.2 Addiction decay during abstinence
- [ ] `addiction` decays over time without use, at vice-specific rates
- [ ] Drugs decay very slowly, fighting decays moderately

**Test:** Set addiction=50 for a rat's primary vice. Leave the rat without access to the vice for two full shifts. Addiction should be lower. Run the same test for two vice types with different decay rates (e.g. smoking vs drugs) — drugs should decay less.

### 8.3 Withholding vice raises stress and degrades owner_relationship
- [ ] When a rat cannot access their vice, `vice_satisfaction` drops below 0, which contributes to stress
- [ ] Owner_relationship worsens proportional to deprivation duration

**Test:** Addicted rat (addiction=60). Remove access to their vice for one full shift. Confirm `vice_satisfaction` is negative, `stress` has increased, `owner_relationship` is lower than at shift start.

### 8.4 Inebriation degrades job performance
- [ ] `inebriation` is a negative factor in `current_state_modifier`

**Test:** Rat at inebriation=0 vs inebriation=80. Same job, same needs, same stats otherwise. Inebriation=80 rat has measurably lower job performance.

### 8.5 Smoking location affects food quality
- [ ] Rat smoking near cooking location applies a `food_quality_penalty` flag to that location's output

**Test:** Place a smoking rat adjacent to the cook station. Pod output from cook station should have a food_quality_penalty applied. Remove the smoking rat — penalty lifts.

---

## 9. Owner Relationship

### 9.1 Relationship increases from met needs
- [ ] Each tick where the rat's needs are met and job fit is good, owner_relationship trends upward (slowly)

**Test:** Rat with all positive needs and good job assignment. After one full shift, owner_relationship should be slightly higher than at start.

### 9.2 Relationship decreases from unmet needs / overwork
- [ ] Chronically unmet needs and burnout state degrade owner_relationship each tick

**Test:** Rat with nutrition=-60 for a full shift. owner_relationship should be lower at end of shift. Rat in BURNOUT assigned to a job — owner_relationship should drop faster.

### 9.3 Colony relationship
- [ ] `colony_relationship` is the simple average of all individual `owner_relationship` scores

**Test:** Set three rats' owner_relationship to 60, -20, 40. `colony_relationship` should read 26.67 (or ≈27 if integer). Changing one rat's relationship should update the colony figure.

---

## 10. Owner Pressure Spike

### 10.1 Spike raises employment_pressure temporarily
- [ ] Owner triggers a pressure event; all job location scores are boosted for a short window; decays back to base

**Test:** Trigger a spike. Measure job location score before, during, and 30 seconds after. During: measurably higher. After: back to approximately baseline.

### 10.2 Relationship cost scales with current relationship
- [ ] Spike costs owner_relationship per rat; rats at lower relationship take a larger hit

**Test:** Two rats: owner_relationship=+60 and owner_relationship=-40. Trigger a spike. Measure owner_relationship change for each. The -40 rat should lose more points than the +60 rat from the same spike.

### 10.3 Overuse stacks damage
- [ ] Consecutive spikes in quick succession apply escalating relationship damage

**Test:** Trigger 5 pressure spikes in rapid succession on the same rats. Relationship damage per spike should increase across the series. Stress on rats should also be escalating.

---

## 11. Colony Observability

### 11.1 Rat mood signal
- [ ] Each rat exposes a `mood` signal derived from stress and need levels
- [ ] Rats in REBELLION suppress this signal (appear fine)

**Test:** Rat with stress=80 and nutrition=-60: mood signal should read negative/distressed. Same rat in REBELLION: mood signal reads neutral or positive despite identical internal stats.

### 11.2 Pod indicators
- [ ] Each pod generates 1–2 descriptive indicator strings based on group dynamics, inebriation, camaraderie, and presence of vices

**Test:** Pod with one heavy drinker (inebriation=80): indicator should mention drinking or erratic behavior. Pod with high camaraderie rats: indicator should describe smooth function or good energy.

### 11.3 Colony appetite
- [ ] `appetite` = total consumption rate of food and vices across all rats in the current tick window

**Test:** Add a rat with high addiction (addiction=80). Colony `appetite` for that vice should be measurably higher than a colony with no addicted rats. Print appetite values before and after adding the addicted rat.

---

## Deferred / Out of Scope for Now

- Pathfinding (currently teleporting — known placeholder)
- Rat economy / currency system (design TBD)
- Full UI for owner-facing stats
- Art/animations for crisis states and environmental tells
- Health inspector and reviews
- Rat Man ending trigger conditions
