# entities/

Scene-tree nodes for things that exist in the game world.

- `rat/` — the rat simulation (stats, needs, decision-making)
- `location/` — job stations and other places rats can travel to
- `colony/` — autoload holding the live `Dictionary[int, Rat]` of all rats
- `chef/` — a leftover `CharacterBody2D` template script (WASD movement); not wired into the sim
