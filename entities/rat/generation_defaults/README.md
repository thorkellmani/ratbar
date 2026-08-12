# entities/rat/generation_defaults/

`GenerationDefaults extends Resource` — the single inspector-editable `.tres`
a new `Rat` is generated from: `personality_mean`/`personality_deviation`
(randomized per-trait via `randfn`), plus `default_mood`/`default_status`/
`default_vice`/`default_job_skills` (duplicated as-is, no randomization).

`initialize()` takes a `GenerationDefaults` param on purpose, reserved for
future archetype support — don't add an `archetype` param until that's
actually being built.
