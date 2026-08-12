# entities/rat/stats/

`Resource` subclasses of `shared/base_stat_group.gd` (`_min`/`_max`/
`_clamp_value()`/`stat_changed`). Each field is a typed `@export` with a
clamped setter that emits `stat_changed`; `get_keys()` lists field names for
generic reflection (used by the debug panel).

- `mood/` — `Mood` (needs: nutrition, energy, stimulation, social,
  vice_satisfaction, `-100..100`), `MoodUrgency` (per-need `Curve`, not a stat
  group — maps a mood value to `0..1` urgency)
- `personality/` — `Personality` (greed, temper, socialness, ambition,
  laziness, `-100..100`)
- `status/` — `Status` (stress, health, inebriation, radicalization,
  extra_stress, `0..100`)
- `vice/` — `Vice` (smoking, drinking, drugs, sex, gambling, fighting, `0..100`)
- `job_skills/` — `JobSkills` (one field per `JobConstants.JOB`, `0..10`)
- `camaraderie/` — `Camaraderie`, a `Dictionary[int, float]` keyed by rat id,
  not a fixed schema — uses `add/remove/update_relationship()` instead of
  `get_keys()` + generic get/set
- `other/` — `Other` (owner_relationship, currency, crisis, state,
  assigned_job) — everything that doesn't fit the four categories above
