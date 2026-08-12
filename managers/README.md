# managers/

`Node2D`s that drive entities from the outside — entities hold state, managers
own the logic that mutates it over time or across many instances at once.

- `rat_manager/` — the sim's tick loop; drives every rat's need application
  and decision re-evaluation
- `job_manager/` — rat ↔ job assignment
- `location_manager/` — queries over the `Location` children in the scene
