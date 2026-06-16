# Demo — "Current vs. New" Game-Integrity & Cheat Detection

A runnable, offline proof for the re:Invent 2026 talk. It shows the **old way
failing and the new way catching** across three abuse categories, on one
synthetic dataset, with **measurable metrics on screen** — not theory.

## Why this demo exists

The talk's claim is that modern AI/data-science + verifiable-integrity techniques
catch cheating/fraud **earlier, more completely, and with a reason attached**,
where today's heuristics go blind. This demo makes that claim *falsifiable in the
room*: same data, two approaches, numbers side by side.

## Requirements

- Python 3.9+
- `numpy` (the only third-party dependency)
- No GPU, no network, no AWS account. Runs in ~1 second.

```bash
pip install numpy      # if needed
python3 run_demo.py
```

`run_demo.py` regenerates fresh synthetic data each run and climbs the ladder
rung by rung. You can also run each beat on its own (`generate_data.py` first,
then `detect_behavior.py`, `detect_rings.py`, `verify_economy.py`,
`tamper_check.py`). Note `verify_economy.py` needs no data file — the economy
rulebook is defined in the script itself.

## The four beats and their talking points (climbing the ladder)

### Beat 1 — Behavioral cheat/bot detection: rules vs. anomaly detection
`detect_behavior.py`

- **Old:** hand-tuned thresholds (accuracy > 0.55, APM > 175, reaction < 130 ms).
- **New:** unsupervised anomaly detection — robust z-scores (median/MAD) summed
  across features — flagging sessions jointly far from the human norm, with the
  most-deviating feature reported as the *reason*.
- **The point:** the dataset includes **"evasive" cheats** that tune *each* stat
  to sit just under every rule threshold. Individually every value looks legal,
  so the rules engine clears them (catches 0 of 35). The anomaly detector flags
  them on the *combination* being off-distribution, and catches all of them —
  **plus** it ships a "why" with every flag.
- **Talking point:** "Cheats evolve to live just under your thresholds. A fixed
  rule can't follow them; a model of *normal* can. And notice every detection
  comes with a reason — that's what your analyst (or your appeals process) needs."
- **Honesty note:** the anomaly detector trades a little precision for big recall
  gains (it raises some sessions for review). That's correct: it *surfaces*
  suspects for human review, it does not auto-ban. See §3.3 of the brief.

### Beat 2 — Collusion / win-trading: per-account heuristic vs. graph analysis
`detect_rings.py`

- **Old:** flag accounts with a suspicious win rate.
- **New:** build the player-interaction graph (edge = matches played together),
  keep only "strong" edges (pairs who played each other far more than the median),
  and surface connected clusters as candidate rings.
- **The point:** colluders here are **behaviorally normal** and share wins ~50/50,
  so their win rate looks ordinary — the per-account heuristic catches 0. The same
  data, viewed *relationally*, exposes every ring (40/40 members, 0 false members).
- **Talking point:** "The signal isn't in any one account — it's in the
  relationships. This is exactly the step-change a GNN delivers. I'm showing it
  with transparent graph analysis so it runs in a second; in production this is a
  GNN learning node embeddings on SageMaker, but the structure it finds is this."

### Beat 3 — Economy-rule soundness: playtest-&-hope vs. automated reasoning
`verify_economy.py`  ·  **Rung 2 of the ladder: VERIFY THE RULES**

- **Old:** playtest and fuzz the economy, find nothing obvious, ship. "We tried
  thousands of trades and nothing broke" is *confidence*, not *certainty*.
- **New:** **Automated Reasoning.** Encode the economy's rules as math, then
  search the whole action space for a sequence of *legal* actions that nets free
  gold while leaving inventory unchanged (a "money pump"). Either it hands you
  the exact exploit recipe, or it *proves* none exists.
- **The point:** the shipped economy has a subtle bug — a `craft_gem` recipe that
  turns 2 shields (80g) into a gem that sells for 90g. No single rule is wrong;
  the *combination* is a +10g infinite loop. Playtesters trying actions one at a
  time never see it. The solver finds it instantly: `buy_shield → buy_shield →
  craft_gem → sell_gem = +10g, inventory unchanged → repeat forever`. Patch the
  recipe to need 3 shields and re-run: **PROVEN — no money pump exists.**
- **Talking point:** "Playtesting says 'we didn't find a bug.' Automated Reasoning
  says 'there *isn't* one' — or hands you the exact recipe if there is. That's the
  jump from confidence to certainty, *before* a single player logs in. This is the
  same class of technique behind AWS's own provable-security work — Bedrock
  Automated Reasoning checks, and the Zelkova / Dafny lineage."
- **What's real vs. simplified:** the search is a genuine, *sound* check over the
  economy's action lattice with a bounded action count — for this small linear
  economy that bound is complete (a money pump, if one exists, is found). It is a
  dependency-free stand-in for a production solver (Z3 / Bedrock Automated
  Reasoning checks) that proves the property *unbounded*. The exploit it finds and
  the proof it gives are exactly what the production tool delivers.

### Beat 4 — RNG / pipeline integrity: "trust the server" vs. commit-reveal
`tamper_check.py`  ·  **Rung 3 of the ladder: VERIFY THE PIPELINE**

- **Old:** the server stores loot outcomes; if an insider or compromised service
  rewrites one, nothing detects it.
- **New:** every draw is a commit-reveal record. The server published
  `SHA-256(server_seed)` *before* the player acted, and the outcome is derived
  from `(server_seed, client_seed, nonce)`. Anyone can recompute the commitment
  and re-derive the outcome.
- **The point:** the script verifies the honest log (200/200 pass, ~1% rare drops
  as configured), then **tampers with one record** (turns a `common` into a
  `RARE`, a fraudulent free item) and shows verification catching it
  deterministically and naming the exact altered draw.
- **Talking point:** "This isn't a suspicion with a confidence score — it's a
  *hard true positive*. The math doesn't think the record was altered, it proves
  it. That's the difference between probabilistic ML detection and a cryptographic
  control over your own pipeline. SHA-256 here is real, not simulated."

## How this maps to AWS (production)

This demo is intentionally service-free so it's portable and live-safe. In
production each beat has a natural AWS home — **verify current service
names/status against the brief's §9 before presenting:**

- Beat 1 (anomaly detection) → Amazon SageMaker (training/inference), Kinesis
  (telemetry stream), SHAP for attribution; an LLM on Amazon Bedrock as the
  analyst copilot that turns "score + feature" into a plain-language case note.
- Beat 2 (GNN ring detection) → a graph neural network on SageMaker over a graph
  built in Neptune / from the match store.
- Beat 3 (automated reasoning) → AWS Bedrock Guardrails **Automated Reasoning
  checks**, and the AWS Provable-Security lineage (Zelkova, Dafny, s2n) — an SMT
  solver (e.g. Z3) proving economy invariants over *all* action sequences,
  unbounded. (Verify current Bedrock product naming/status — see brief §9.)
- Beat 4 (integrity) → KMS for key custody/signing, Lambda for the verify
  endpoint, DynamoDB + hash-chaining for the tamper-evident log (note: QLDB is
  deprecated — see brief §9), and Nitro Enclaves attestation to prove the prod
  binary is the one shipped.

## What's real vs. simplified (be honest on stage)

- **Real:** SHA-256 commit-reveal and its tamper detection; the automated-reasoning
  money-pump search (a sound, complete check over the economy's bounded action
  lattice — it genuinely finds the exploit or proves none exists); the metrics are
  computed live on the generated data, not hard-coded.
- **Simplified:** the data is synthetic (so ground-truth labels exist only to
  *score* the detectors on screen); Beat 2 uses transparent graph analysis as a
  stand-in for a trained GNN; the anomaly detector is a robust-z method, not a
  production model; Beat 3's solver is bounded and dependency-free rather than a
  full SMT solver proving the property unbounded. None of these simplifications
  change the *qualitative* result the demo illustrates, but say so rather than
  imply this is production code.

## Files

| File | Purpose |
|---|---|
| `run_demo.py` | One-shot driver — runs everything |
| `generate_data.py` | Builds synthetic sessions, interactions, and the draw log |
| `detect_behavior.py` | Rung 1 / Beat 1: rules vs. anomaly detection |
| `detect_rings.py` | Rung 1 / Beat 2: per-account vs. graph ring detection |
| `verify_economy.py` | Rung 2 / Beat 3: playtest-&-hope vs. automated reasoning |
| `tamper_check.py` | Rung 3 / Beat 4: commit-reveal tamper detection |
| `data/` | Generated CSVs (created on run) |
