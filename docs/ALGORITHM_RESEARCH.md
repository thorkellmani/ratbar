# Algorithm Research — Combining Need Axes into a Location Score

This documents the research behind `NeedsEvaluator`'s combination formula — how multiple active need axes at one location get blended into a single score. Two research passes, progressively less scoped to game AI specifically, because the first pass wasn't rigorous enough on its own to trust.

## The problem that started this

A location can have several active need axes (e.g. Pantry: `nutrition`, `energy`). Averaging them treats every active axis as equally important, regardless of how urgent each one actually is *right now*. Concrete failure: a rat near-starving (`nutrition` urgency `≈1.0`) but well-rested (`energy` urgency `≈0.09`) at Pantry — the plain average blends these to `~0.46`, diluting the starvation signal with an irrelevant one. A mediocre-but-broad competing location could beat it purely because averaging doesn't let one screaming need dominate.

Explicitly out of scope: a hard veto/lexicographic override ("if starving, don't even consider anything else") — considered and deliberately deferred earlier this sprint as too blunt. We wanted something inside the *soft* scoring math.

## Pass 1 — game AI specifically (insufficient on its own)

Checked Dave Mark's IAUS (Infinite Axis Utility System) directly, since `NeedsEvaluator` is explicitly built on it.

**Confirmed** (Mike Lewis, *Game AI Pro 3* ch. 13, the shipped *Guild Wars 2* IAUS): considerations are combined by **multiplication**, not averaging. The "compensated average" formula we'd built (`M = 1-1/k`, `C = μ + (1-μ)Mμ`) is Dave Mark's own patch for the *count bias* multiplication introduces (multiplying more sub-1 numbers together shrinks the result, unfairly punishing options with more active considerations) — it was designed to correct a product, and we'd been applying it to a plain arithmetic mean instead, which doesn't have that particular bias to correct.

**Not found anywhere in IAUS:** any documented mechanism for one consideration to dynamically outweigh another based on their *relative* current values. IAUS's only documented lever for "importance" is the shape of each consideration's own response curve — which can't express "nutrition should matter more *because* energy happens to be low right now," since curves only ever look at their own axis in isolation.

**The actual shipped industry answer** to "a starving Sim shouldn't bother scoring Fun" (David Graham, *Game AI Pro* ch. 9; Kevin Dill's dual-utility bucketing, *Game AI Pro 2* ch. 3) is **lexicographic bucketing** — a hard tier system, i.e. exactly the veto we'd already ruled out. Worth knowing that's not a workaround, it's the canonical answer game AI actually ships — we're choosing to solve this differently on purpose, not because we missed the standard technique.

This pass produced a plausible-sounding recommendation (a power mean) but wasn't grounded well enough — game AI's own literature doesn't document a rigorous answer to this, so a second, wider pass was needed before trusting any conclusion.

## Pass 2 — cross-disciplinary (the real answer)

Reframed the question as a general aggregation problem, not a game-AI one: *given several `0..1` values representing current importance, and an active subset relevant to one option, what proven method lets an extreme value dominate mild ones, tunably, without a hard cutoff?* Surveyed decision theory/MCDA, welfare economics, fuzzy logic, control theory, and reinforcement learning as primary sources, checking game AI's practice against those conclusions rather than starting from it.

### The theorem that settles the shape of the answer

**Kolmogorov/Nagumo (1930).** Any combining function that is continuous, symmetric, strictly increasing, and idempotent (all-equal inputs return that same value) is forced into one specific shape: **quasi-arithmetic** — `M(x) = f⁻¹(mean(f(x)))`. Transform every input through some function `f`, average the transformed values, undo the transform. This isn't "one good option" — it's the *only* shape possible once those properties are demanded.

A second result: you cannot have both **decomposability** (grouping doesn't matter — combine some inputs first then the rest, vs. all at once, same answer) and **internality** (the result stays within `[min, max]` of the inputs, and stays comparable regardless of how many inputs are active) simultaneously in such a function. We don't care about grouping order (we always combine all active axes in one step), so we keep internality — which is exactly the property our compensated-average patch was fighting to approximate and never quite had cleanly. This same reasoning **disqualifies IAUS's own base mechanic (multiplication)** — a product isn't internal in the count-independent sense, which is *why* it needed a compensation patch in the first place.

### The two real candidates within that family

- **Power mean**: `f(x) = xᵖ` → `M_p = (Σwᵢxᵢᵖ/Σwᵢ)^(1/p)`. `p=1` is today's plain average; `p→∞` approaches max. Differentiating shows each axis's *effective* weight is `wᵢ·xᵢ^(p-1)` — at `p>1`, an axis's influence grows with its own current urgency, automatically, with no separate weight table. This is exactly the "sliding scale of relevancy" the design was reaching for, on proven footing.
- **Exponential/Kolm mean (mellowmax)**: `f(x) = eᵏˣ`, same min→mean→max sweep via `κ` instead of `p`. Proven non-expansive/well-behaved (Asadi & Littman, ICML 2017) — built specifically to fix a *documented pathology* in naive softmax/Boltzmann weighting (multiple fixed points, divergence in some cases). Confirms our earlier instinct to research softmax before using it was the right call — it would have been the wrong choice.

### Real-world validation

**Dujmović's Graded Logic / LSP method** — a ~50-year-old, commercially-deployed MCDA technique — is built around exactly the power mean parameterized by an "orness" dial; `p>1` is literally named "soft partial disjunction" in that literature. **Welfare economics** (Atkinson's inequality measure; prioritarianism) uses the mirror-image family for "how much should one person's/criterion's need outweigh others" — though economics only endorses the `p≤1` half on ethical grounds (the Pigou–Dalton transfer principle); the `p>1` extension we want is a reasonable mathematical mirror, not something welfare economics itself endorses — flagged as inference, not citation.

### Rejected alternatives, with real reasons

| Method | Why rejected |
|---|---|
| Plain multiplication (IAUS's own base mechanic) | Not internal/count-stable — the exact bias the compensation patch was fighting |
| Boltzmann softmax (`Σxᵢeᵏˣⁱ/Σeᵏˣⁱ`) | Confirmed pathological — proven to have multiple fixed points, diverges in some cases (Asadi & Littman 2017) |
| Plain log-sum-exp | Overshoots the true max by an amount that grows with how many axes are active |
| OWA operators | Valid, but the weight vector must be regenerated per active-axis-count — more machinery for the same result |
| WOWA, Choquet integral | Need far more parameters (`n(n+1)/2` or worse) than we have data to justify |
| t-conorm-based operators (Zimmermann–Zysno γ, etc.) | Not idempotent — adding a mild axis can *inflate* the score, which is backwards |
| Lexicographic bucketing/tiers | The actual shipped game-AI answer, but it's the hard veto we already deliberately deferred |

## Decision

**Use the weighted power mean, `p > 1`, replacing the compensated average entirely.** The compensation formula (`M`, `makeUp`) gets dropped — it's not needed, since the power mean is already stable across a varying number of active axes by construction, which is the exact problem the compensation formula existed to patch imperfectly.

```
score = (Σ(wᵢ × xᵢᵖ) / Σwᵢ) ^ (1/p)
```

`p` becomes one exported, feel-tunable constant (starting point `p ≈ 3`). `p=1` reproduces today's plain-average behavior exactly, so it's a safe, comparable baseline to A/B against once implemented.

Chosen over mellowmax because: our domain is always `0..1` (no negative inputs, no need to ever flip toward worst-case dominance), performance is a non-concern at this scale (six locations, five needs, run occasionally), and power mean is far simpler to implement correctly (`pow()` and one division vs. `exp`/`ln` plus a numerical safeguard near `κ=0`) — mellowmax's extra robustness solves problems we don't actually have.

## Implemented and verified

`NeedsEvaluator.evaluate()` now uses the weighted power mean (`SCORING_TUNING_CONSTANT = 3`), compensated-average code fully removed. Verified live via the nutrition-slide test: a rat assigned Head Chef held work over Pantry all the way to `nutrition = -45`, then Pantry overtook it at `-52` and held/widened the lead through `-72` — a real, working starvation crossover, which the old compensated-average formula never produced (work won even at full starvation, `-100`). `EMPLOYMENT_PRESSURE = 0.35` still holds up under the new formula; no re-tuning needed there.

One known, real limitation surfaced during this verification pass — not a bug, a mathematical property of the formula:

**Idempotence (equal-valued axes don't get punished for count) is guaranteed, but a genuinely weak *unequal* axis still taxes a location's score just for being counted.** Example: one axis at `0.9` alone scores `0.9`. Add one weak axis at `0.1` alongside it (`k=2`): `((0.9³ + 0.1³)/2)^(1/3) ≈ 0.716` — a real ~20% drop, even though the weak axis barely contributed to the sum. The weak axis is nearly free in the numerator but fully counted in the denominator. This showed up concretely: Pantry's `energy` axis (irrelevant for a well-rested rat) measurably dragged down its `nutrition`-crisis score, even at `-72`.

**Practical mitigation, adopted now:** be genuinely disciplined about which axes actually deserve a nonzero `pull` at a location — a location with fewer, honestly-relevant axes will often outscore one with marginal axes tacked on. The `0` (excluded) vs `1` (barely real, but counted) boundary from earlier this sprint now carries more real weight than it did under the compensated average, which had a fairness boost softening exactly this tax.

**Deferred idea, not researched or built:** dynamically excluding an axis from `k` (not just from the location's own `pull`) based on whether the need is currently a "practical consideration" for *this* rat right now — e.g. don't let `energy` count against Pantry at all while the rat isn't meaningfully tired. This would directly fix the tax above, but it reintroduces a hard threshold/cutoff (same category of mechanism as the deliberately-deferred veto, just per-axis instead of per-location), with a real discontinuity risk right at the threshold boundary. A *soft*, continuous version (an axis's practical weight scaling smoothly with its own urgency, rather than a hard in/out cutoff) might exist, but hasn't been researched — don't build this on a hunch, given how much this sprint cost us from doing exactly that with earlier formula ideas. Revisit only if the hand-authoring mitigation above proves insufficient in actual play.

## Honesty on confidence

Verified from primary/citable sources: the Kolmogorov/Nagumo characterization theorem, Dujmović's Graded Logic/LSP method, Atkinson's inequality measure, the Boltzmann softmax pathology, mellowmax's properties, and IAUS's documented multiplication + compensation mechanics. Reasonable inferences, not directly-cited claims: the `p>1` mirror of Atkinson's welfare-economics form, and that any orness-drift-with-axis-count in the power mean is negligible at this game's scale.
