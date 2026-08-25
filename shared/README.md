# shared/

`base_stat_group.gd` — `BaseStatGroup extends Resource`, the root class every
stat/field group in the project ultimately extends (`Needs`, `Personality`,
`Status`, `LocationPull`, `LocationModifiers`, `JobModifiers`, ...). Owns:

- `_get_min()` / `_get_max()` — overridden per concrete class to set that
  class's scale (e.g. `Needs` is `-100..100`, `LocationPull` is `0..7`).
  Defaults to `0..1` here only as a base fallback; every real subclass
  overrides both.
- `_clamp_value(value)` — `clampf` against `_get_min()`/`_get_max()`, used by
  concrete classes' field setters so a stat can never leave its own valid
  range.
- `stat_changed` — signal emitted by concrete classes' setters, used for
  loose coupling (e.g. the debug panel connects to a rat's stat resources
  directly rather than polling).
- `get_keys()` — `static func`, returns `[]` here as a real base
  implementation (not just a convention every override has to remember).
  Concrete classes (via `shared/field_groups/`, see below) override it to
  list their own field names, enabling generic reflection — the debug panel
  and `NeedsEvaluator` both iterate needs/fields without hardcoding names.
- `get_normalized_value(key)` — instance method, `(get(key) - min) / (max -
  min)`, asserts `key in get_keys()` first. Lets code normalize any stat
  group's value to `0..1` without knowing its concrete scale — this is how
  `NeedsEvaluator` compares `LocationPull` (`0..7`) against normalized need
  urgencies (`0..1`) without hardcoding the literal `7` anywhere.

`shared/field_groups/` (see its own `README.md`) sits one level below this —
base classes that own a fixed *set* of `@export` fields for a category
(needs, personality, ...) plus `get_keys()` for that set, while the actual
scale (`_get_min()`/`_get_max()`) is left to the final concrete class. This
split is what lets e.g. `Needs`, `LocationPull`, and `LocationModifiers` all
share the same five need fields but each pick their own scale.
