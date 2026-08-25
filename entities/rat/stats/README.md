# entities/rat/stats/

`Resource` subclasses of `shared/base_stat_group.gd` (`_get_min()`/
`_get_max()`/`_clamp_value()`/`stat_changed`). Most stat groups now extend a
shared field-set base from `shared/field_groups/` (`NeedFields`,
`PersonalityFields`, `StatusFields`, `CamaraderieFields`)
which owns the `@export` fields and `get_keys()`; the concrete class here
just overrides `_get_min()`/`_get_max()` for its scale. Each field's setter
is clamped and emits `stat_changed`; `get_keys()` lists field names for
generic reflection (used by the debug panel).

- `need/` — `Needs` (nutrition, energy, stimulation, social,
  vice_satisfaction, `-100..100`), `NeedUrgency` (per-need `Curve`, not a stat
  group — maps a raw need value to `0..1` urgency). `vice_satisfaction`'s
  curve is keyed on its own raw value like the rest, not on addiction.
- `personality/` — `Personality` (greed, temper, socialness, ambition,
  laziness, `-100..100`)
- `status/` — `Status` (stress, health, inebriation, radicalization,
  extra_stress, `0..100`)
- `vice/` — removed. Per-vice tracking (`smoking`/`drinking`/`drugs`/`sex`/
  `gambling`/`fighting`) and addiction are replaced by the single abstracted
  `vice_satisfaction` need above. Fully cleaned up: `Rat`, `GenerationDefaults`,
  `debug_panel.gd`, and `shared/field_groups/vice.gd` (`ViceFields`) are all
  gone/clean. One stale spot remains: `generation_defaults.tres` still has
  an `ext_resource` pointing at the deleted `vice.gd` and a `default_vice`
  line with no matching property — cosmetic, harmless, worth a re-save next
  time that file is opened.
- `job_skills/` — removed, deferred rather than abandoned ("we aren't there
  yet that we need it"). `Rat`, `GenerationDefaults`, `debug_panel.gd`, and
  `shared/field_groups/job_skills.gd` (`JobSkillsFields`) are all clean. Same
  cosmetic straggler as `vice/`: `generation_defaults.tres` still has an
  `ext_resource` for the deleted `job_skills.gd` and a `default_job_skills`
  line with no matching property.
- `camaraderie/` — `Camaraderie`, a `Dictionary[int, float]` keyed by rat id,
  not a fixed schema — uses `add/remove/update_relationship()` instead of
  `get_keys()` + generic get/set
- `other/` — `Other` (owner_relationship, currency, crisis, state,
  assigned_job) — everything that doesn't fit the four categories above
