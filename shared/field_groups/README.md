# shared/field_groups/

Base `Resource` classes that own a fixed set of `@export` fields + `get_keys()`
for a category of stat, shared across every concrete stat group that uses
that category — instead of each concrete class re-declaring the same fields.

- `NeedFields` — `nutrition`, `energy`, `stimulation`, `social`,
  `vice_satisfaction`. Extended by `Needs` (`-100..100`, a rat's own need
  levels), `LocationPull` (`0..7`, appeal scoring), `LocationModifiers`
  (`-20..20`, a location's physical per-hour effect), and `JobModifiers`
  (`-20..20`, a job's own inherent per-need effect, independent of station —
  summed with `LocationModifiers` while a rat is working, see
  `entities/job/README.md`).
- `PersonalityFields` — extended by `Personality`.
- `StatusFields` — extended by `Status`.
- `CamaraderieFields` — extended by `Camaraderie` (in flux, see
  `entities/rat/stats/README.md`).
- `OtherFields` — extended by `Other`. Note `assigned_job: Job` here is not
  `@export`ed unlike its sibling fields — see `entities/job/README.md` for
  why.

`JobSkillsFields` and `ViceFields` existed here briefly but were removed
along with `JobSkills` and `Vice` themselves — both deferred, not abandoned,
see `entities/rat/stats/README.md`.

A concrete class only needs to override `_get_min()`/`_get_max()` (from
`shared/base_stat_group.gd`) for its own scale — the fields, setters, and
`get_keys()` live here once. This is what let `LocationPull` and
`LocationModifiers` pick up all five need fields for free instead of
hand-declaring `energy`/`social`/`stimulation`/`vice_satisfaction` a third
and fourth time.

`get_keys()` and `get_normalized_value(key)` both live one level further
up, on `shared/base_stat_group.gd` itself — `get_keys()` is a `static func`
(no instance needed; each field-groups class overrides it with its real
list), and `get_normalized_value()` is a plain instance method that reads
`get(key)` against `_get_min()`/`_get_max()` to produce a `0..1` value
regardless of a class's actual scale. `NeedsEvaluator` uses both directly
on `NeedFields` to drive its scoring loop without hardcoding the five need
names or `LocationPull`'s `0..7` scale anywhere.
