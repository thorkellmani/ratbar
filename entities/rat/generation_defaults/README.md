# entities/rat/generation_defaults/

`GenerationDefaults extends Resource` — the single inspector-editable `.tres`
a new `Rat` is generated from: `personality_mean`/`personality_deviation`
(randomized per-trait via `randfn`), plus `default_needs`/`default_status`
(duplicated as-is, no randomization). `default_vice` and `default_job_skills`
no longer exist here — both `Vice` and `JobSkills` were removed (deferred,
not abandoned) — but `generation_defaults.tres` still has stale
`ext_resource`s for the deleted `vice.gd`/`job_skills.gd` and matching
`default_vice`/`default_job_skills` lines with no property to bind to;
cosmetic, worth cleaning out next time that file is opened in the inspector.

`initialize()` takes a `GenerationDefaults` param on purpose, reserved for
future archetype support — don't add an `archetype` param until that's
actually being built.
