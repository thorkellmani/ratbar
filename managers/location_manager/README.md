# managers/location_manager/

`LocationManager` — read-only queries over the `Location` children in the
scene: `get_location_data()` (all of them). No mutation, no state of its
own. `get_job_locations(job)` used to live here, filtering by
`location.job`; it's been removed along with that field — "which locations
serve this job" is now `Job.locations`, owned by the `Job` entity itself
(see `entities/job/README.md`), not something `LocationManager` needs to
know about.
