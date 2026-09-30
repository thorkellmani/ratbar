# Need Decay and Choice Commitment — Decision Log

Historical decisions for the current sprint. Superseded proposals stay visible with strikethrough.

- ~~Give selected needs special baseline rules: faster energy decay while working, social decay based on `socialness`, and vice decay based on stress or addiction.~~ All five needs use the same flat-decay mechanism, with independently configurable rates starting at `-5` per game-hour. Job and location modifiers carry state-dependent effects.
- ~~Decay stimulation only during repetitive or unstimulating activity.~~ Stimulation uses flat baseline decay. Repetition is a separate, later feature.
- ~~Couple `vice_satisfaction` decay to stress and addiction.~~ Addiction tracking was removed. Revisit stress coupling after the Stress System exists.
- Baseline decay applies during travel. Location and job effects require the rat to be stationary; job effects additionally require it to be working at an assigned station.
- ~~Use a fixed score-gap threshold to stop switching between near-tied locations.~~ A rat commits to one primary need when choosing a destination: the active axis at that location with the highest curve-sampled urgency. This uses the existing `0..1` urgency outputs.
- Commitment normally ends when that need reaches its own `GenerationDefaults` baseline. Its duration follows from the gap between the need's value at commitment and that target; there is no separate duration setting.
- Any need crossing below the shared `DEAD_BAND_FLOOR`, including the primary need relapsing, interrupts the commitment immediately between scheduled decision ticks. The mechanism is the same for all five needs.
- Severity- or personality-adjusted satisfaction targets remain deferred. The rats' ordinary need fulfillment should feel like self-interested lingering rather than an abrupt stop. A more acute crisis behavior remains a separate, undecided idea.
- The live nutrition slide was rechecked after adding decay: Pantry still overtakes Head Chef around `nutrition = -52`. Location and job modifier values remain first-pass tuning.
