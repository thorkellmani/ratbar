# Current Sprint — Minimal Watchable Loop

Goal: get something on screen worth watching, and lay the first real slice of the actual action-selection algorithm (`RAT_SIMULATION.md` → Decision-Making → Action Selection), rather than a throwaway placeholder. Scoped down hard: one need, one location type (`employment_pressure` only), no scoring competition between multiple options yet.

This sprint is a deliberate simplification of the full backlog (sections 2/5/6) and the full action-selection flow (10 steps in the design doc) — only step 1 (broadcast, reduced to a constant `employment_pressure`) and step 8 (urgency × tag value) are being built. Personality modifiers, adjacency, crisis-state suppression, repetition penalty, and variance all come later.

## Phase 1 (this sprint) — nutrition only

- **Need considered:** `nutrition` only. The full formula sums `need_urgency[n] × tag_value[n]` across all five needs — this sprint only builds the single-need case, since there's nothing to sum yet.
- **Location considered:** `employment_pressure` only, as a placeholder constant (no real location-broadcast system yet — that's backlog 5.1). No idle/vice/social tags competing against it yet, so there's no genuine multi-way scoring happening yet either — just gating a single value.
- **Urgency via `Curve` resource**, not a hardcoded threshold: one `Curve` for nutrition, shaped to match the design doc's description ("flat above +30, slow rise through neutral, steep exponential drop below -40"). Domain/range set to `-100..100` via `min_domain`/`max_domain`/`min_value`/`max_value` (need to verify these are actually editable in the Inspector in this Godot version, not just settable via code — check before committing to hand-tuning it visually).
- **Job station placement:** at least one location node in a test scene, positioned wherever the rat's `assigned_job` should send it.
- **Idle behavior:** rat stays wherever it currently is; `job_state` set to `IDLE`. No separate rest/idle spot yet.
- **Check cadence:** re-evaluate on a fixed interval via a `Timer`, not every `_process()` frame.

### Tasks

- [x] Build the nutrition `Curve` resource, matching the doc's described shape; confirm domain/range editability in the Inspector
- [x] Build a minimal test scene: one job-station location node (fixed position), one rat with an `assigned_job` set
- [x] Add a decision check (on a `Timer`) that samples the nutrition curve and combines it with the `employment_pressure` constant to decide work-vs-idle
- [x] Move the rat (teleport, existing placeholder) to the job station when the check resolves to "work"; set `job_state = WORKING` / `IDLE` accordingly
- [x] Some visible indicator of current `job_state` — the whole point is watchability

### Test scenarios

Use the debug panel's stat override (section 0.2) to drive these — no need for real decay yet.

1. **Baseline works:** default nutrition (0), `assigned_job` set, job station in scene → rat moves to the job station, `job_state` becomes `WORKING`.
2. **Deep hunger blocks work:** set `nutrition` well below `-40` (the curve's steep zone) → rat does not move; `job_state` becomes/stays `IDLE`.
3. **Recovery re-enables work:** from scenario 2, raise `nutrition` back above the curve's steep zone → rat transitions `IDLE → WORKING` on the next check.
4. **No job, no work:** fine nutrition but `assigned_job = UNASSIGNED` → rat stays `IDLE`, confirming idling isn't purely hunger-driven.
5. **Curve shape sanity check:** sample the curve directly at a few points (e.g. `+50`, `0`, `-20`, `-40`, `-70`) and print the results — confirm it's actually flat above `+30` and steep below `-40`, not just monotonically decreasing.

## Phase 2 (next, not this sprint) — remaining needs

Once nutrition's slice is working end-to-end: add `Curve` resources for `energy`, `stimulation`, `social`, `vice_satisfaction`, each shaped per the doc's per-need description. At that point the formula becomes a genuine sum across needs, not a single value — worth re-deriving the combination logic then rather than guessing ahead now.
