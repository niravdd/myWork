# The Confidence Ladder: Climb From Guesswork to Proof in Your Game

### re:Invent 2026 — topic brief for a 50-min breakout + live, interactive demo

**Working title (locked):** *The Confidence Ladder: Climb From Guesswork to Proof in Your Game*
**Lens:** the studio's point of view — not "how do we make players trust us," but *"how do we know our own game is behaving as we designed it, how strong is that knowledge, and what do we do when it isn't?"*
**One-sentence thesis:** every integrity signal a studio can produce sits somewhere on a ladder from **"we statistically suspect"** to **"we can mathematically prove"** — and the engineering skill that actually matters is **matching the strength of your evidence to the stakes of the decision, with a reason attached to every signal.**
**Date:** 2026-06-11 (synced to the interactive deck `confidence-ladder-deck-v2.html`; earlier brief `reInvent2026-topic-brief.md` and 21-slide deck `confidence-ladder-deck.html` preserved)

**Abstract (submission copy):**
> Every studio runs anti-cheat models and economy dashboards — but ask a hard question and the honest answer is "we think so." This session turns "we think" into "we can prove." We use **anomaly detection** and **graph neural networks** to make cheat, fraud, and collusion detection measurably *more accurate* than the rules they replace — with a reason behind every flag. Then we cross from statistics to certainty: **Automated Reasoning** proves an economy exploit can't happen before you ship, and **commit-reveal and attestation** mathematically prove a draw wasn't rigged and your pipeline wasn't tampered with. The throughline is a **Confidence Ladder** — match your evidence to the stakes. Live demos throughout.

**The two running-example games (used across every slide and demo):**
- **SHARDFALL** — a competitive live-service **shooter-RPG**, the *running example all four live demos use*. One title that plausibly contains every integrity surface: gunplay (aimbots), a ranked ladder (win-trading rings), a marketplace + crafting (economy dupes), and loot crates (RNG odds). This keeps the demos consistent — one game, climbed rung by rung.
- **STAR ORACLE** — a **gacha hero-collector**, the recurring *"other genre" foil*. At each rung an "in your genre →" callout maps the technique from SHARDFALL to gacha / MOBA / trading-card / MMO / single-player, so the breadth is covered without diluting the spine.

---

## 0. Why this framing, and why it's honest

Most "AI for game integrity" talks are a grab-bag: a little anti-cheat ML, a little blockchain-flavored provable fairness, a little formal methods, stapled together with a "trust" narrative. The reason they don't land with a skeptical engineering audience is that they blur the one distinction that matters: **these techniques produce evidence of wildly different strength, and they conflate "we have a model that flags this" with "we can prove this happened."** A loot-box hash chain and a bot-detection classifier are not the same kind of claim, and an audience of engineers knows it.

So the spine of this talk is a single mental model the room carries out:

> **The Confidence Ladder.** Integrity evidence ranges from *probabilistic suspicion* (cheap, broad, wrong sometimes) to *cryptographic/formal proof* (expensive, narrow, wrong essentially never). Good integrity engineering is choosing the right rung for each decision — and never spending proof-grade money where a suspicion is enough, or acting on a suspicion as if it were proof.

Everything else hangs off that ladder. It tells you when each technique is worth the money, what you can honestly claim, and why "make the game accountable to the player" is the wrong goal and "make the game *auditable*" is the right one.

---

## 1. The Confidence Ladder (the spine)

| Rung | The claim you can make | Technique family | Strength | What it costs | Who acts on it |
|---|---|---|---|---|---|
| **1 — Detect** | "We *suspect* this session/account/ring is abusive, and here's why." | ML: anomaly detection, sequence models, graph analysis (GNN) | **Probabilistic.** Has false positives and false negatives by construction. | Cheap, broad, always-on. | A human reviewer — *never* an auto-ban. |
| **2 — Verify (rules)** | "No reachable state in our *specified* economy/ruleset violates this invariant." | Automated Reasoning / formal methods | **Proof — over the model, not the shipped binary.** | Moderate; needs a formal spec. | Designers, pre-ship. |
| **3 — Verify (pipeline)** | "This draw was committed *before* the player acted / this outcome derives deterministically from the seeds / this is the binary we shipped." | Commit-reveal, VRF, attestation, hash chains | **Cryptographic proof of a narrow property.** A tamper *provably* fails verification. | Real: key management, latency, audit surface. | Anyone — it's a hard true positive. |
| **4 — Expose (optional)** | "Don't trust us — re-run the check yourself." | Publishing rung-2/3 artifacts to players/regulators | As strong as the artifact underneath. | Governance + support cost. | Players, auditors, regulators. |

**The two rules that make this credible on stage:**

1. **Never act on a rung-1 signal as if it were rung-3.** A model score feeds human review; a cryptographic verification failure can trigger an automated response. Conflating them is how studios get burned by a false-ban PR incident.
2. **Never pay for a higher rung than the stakes justify.** Rung 3 on a cosmetic drop in a single-player game is over-engineering. Rung 3 on a real-money gacha pull in a regulated market is table stakes. The §6 decision rule formalizes this.

This ladder is the slide the whole talk returns to. Each segment below is "here's a rung, here's what it genuinely buys you, here's its honest ceiling."

---

## 2. The honest novelty audit (say this out loud, early)

The fastest way to lose an engineering audience is to imply these techniques are new. Most aren't. The fastest way to *earn* them is to say so before they catch you. So, plainly:

| Technique | New? | The honest verdict |
|---|---|---|
| ML / anomaly anti-cheat (rung 1) | **No.** | Valve Trust Factor, Riot, Activision Ricochet have done this at scale for years. Table stakes, not differentiation. |
| Graph / GNN ring detection (rung 1) | **Mostly no.** | Standard in fintech fraud; increasingly in games. The *gaming framing* is fresh; the math isn't. |
| Commit-reveal / "provably fair" RNG (rung 3) | **No, but mis-located.** | Well-known in crypto-gambling. What's under-served is using it as an **internal** control, not a player gimmick (see §4). |
| Automated Reasoning on game *economies/rules* (rung 2) | **Genuinely uncommon.** | Formal methods on game rulesets is rare in practice. Real differentiation. |
| Cryptographic verification of your **own backend** (rung 3) | **Genuinely uncommon.** | Studios verify the *client*. Almost nobody proves their own RNG service runs the configured odds or that prod runs the shipped binary. The most under-served idea in the talk. |
| "Score + reason + implicated subgraph" as one workflow | **Integration, not invention.** | The value is posture: earlier, localized, explainable. Not a new algorithm. |

**The one-liner for "how is this different from what studios do today?":** *Today's tooling tells you something broke, usually after the economy or ladder already absorbed the damage, and rarely tells you exactly where. Two ideas here are genuinely uncommon in games — proving rule-soundness before launch, and cryptographically verifying your own pipeline against insider/config tampering — and the rest is a posture upgrade: catch it earlier, localize the root cause, attach a reason. It's an upgrade to detection posture, not a new bag of algorithms.*

Owning this is not a weakness in the talk. It *is* the talk's credibility.

---

## 3. "Mathematical proof of game events" — proof of *what*, exactly?

This is the question the whole thing lives or dies on, and the trap is letting the word "proof" carry more than it can. The discipline: always separate the **syntactic** thing proven from the **semantic** thing the player or studio actually cares about.

| Technique | What it *actually* proves (syntactic) | What people *think* it proves (semantic) | The gap |
|---|---|---|---|
| **Commit-reveal** | The outcome was fixed *before* the player acted and derived deterministically from the seeds. | "The odds are fair." | A studio can honestly commit to a seed drawn from a **rigged distribution**. Commit-reveal only kills the *chosen-after-the-fact* attack. It says nothing about whether the drop table is the advertised one. |
| **VRF** | The randomness was unpredictable *and* unbiasable by the server. | "Fair draw." | Closer — but still silent on whether the *configured* table matches the *published* odds. |
| **Automated Reasoning** | No reachable state in the **specified model** violates invariant X. | "The shipped game has no exploit." | The proof is over the spec, not the compiled/shipped/running code. The map is not the territory. |
| **ZK proof** | A computation was performed correctly w.r.t. committed inputs. | "The server played by the rules." | Something still has to certify the *circuit encodes the real rules*. |
| **Attestation (Nitro etc.)** | Prod is running *this* measured binary/config. | "The game logic is correct." | Proves identity of the code, not correctness of the logic. |

**So why would a player ever trust any of it?** The answer is the entire "don't trust, verify" proposition, and it's genuinely powerful: **the player doesn't trust the studio's *claim* — they (or a regulator, or an auditor) can independently re-run the check and get the same answer without trusting anyone.** That's real. But it only covers the *narrow property the artifact proves.* The chasm between "this draw was committed beforehand" and "this game is fair to me" is bridged by **disclosure scope, governance, and audit — not by the math.** This deserves a full slide, because it is the exact boundary between a credible talk and snake-oil.

---

## 4. Reframe verifiability as an *internal* control (the under-served idea)

Here's the move that makes the cryptographic layers fundable without ever invoking the player. Stop pitching commit-reveal/VRF/attestation as a *player* feature. Pitch them as **answers to internal-threat questions the studio cannot currently answer:**

- *Is my RNG service actually running the odds I configured — or did a config push, a bad deploy, or an insider quietly change the drop table?*
- *Is production running the binary and config I shipped — or a swapped/patched one?*
- *If a database record was altered after the fact, would anything detect it — or do we just trust our own logs?*

Today the answer is usually "we assume so; we have no independent artifact." That's a **supply-chain / insider-threat gap**, and it's the same class of problem every security team is already funded to close elsewhere. Reframed this way, verifiability stops competing with "we already have anti-cheat" and starts competing with "we have no integrity control on our own pipeline at all" — a much easier sell.

Player-facing exposure (rung 4) then becomes the **elective outward face** of a control you built for yourself: switch it on for the narrow cases where it pays (regulatory hedging on loot-box odds, a brand-differentiating "verify it yourself"), leave it off everywhere else.

---

## 5. "Accountable to the player" is the wrong goal. "Auditable" is the right one.

You asked directly: *is this truly making a game accountable to the player?* No — and the talk is stronger if it says so.

**Accountability = a duty to answer for outcomes + a mechanism for redress.** The math supplies neither. It supplies an **evidentiary substrate**: a verifiable record that turns "trust us" into "here's an artifact you can check." But:

- A verifiable log makes a dispute **adjudicable with evidence** instead of a shouting match. It does **not** make the studio *act* on that evidence.
- The studio still decides whether to refund, reverse, or ban. Accountability requires a **commitment to act** — a published policy, an SLA, or a regulator with teeth. None of that comes from the cryptography.

So the precise, defensible claim is: **these techniques make a game *auditable* and make disputes *evidence-based*. "Accountable to the player" overstates what the math delivers.** This is *exactly* why the studio-POV framing is the right one: the studio builds this as its own integrity and observability tooling, where the ROI is concrete (§6), and player-facing accountability is an elective layer on top — not the justification.

---

## 6. When to build each rung (the decision rule attendees take home)

The single most credible slide in the deck is the one that tells people **when NOT to build this.** The verification machinery adds latency, key-management, and audit surface. Spend it only where the stakes clear the bar:

**Climb to rung 2–3 only where one of these is true:**
- **Real money meets randomness** — gacha/loot, where "the pity timer is rigged" is an accusation reputation alone can't rebut.
- **Competitive integrity meets revenue** — ranked/esports ladders measurably bleed paying players to cheaters.
- **A regulator is riding on the outcome** — loot-box-as-gambling classification (Belgium, Netherlands, ongoing EU/UK scrutiny, odds-disclosure mandates) means you'll need casino-grade RNG audit trails *anyway*; build them as a compliance moat.
- **Abuse has a measurable P&L cost** — fraud loss, chargebacks, RMT, churn off a cheated ladder, analyst hours.

**Stay on rung 1 (or do nothing) for:** single-player games, non-monetized random systems, titles with no competitive ladder. There, rung-3 machinery is over-engineering for trust the game doesn't need. *Saying this plainly is what earns the room's trust on everything else.*

Note the asymmetry that makes the ROI case: **rung 1 pays for itself operationally** (detect fraud/cheats earlier and cheaper — this is the lead pitch to LiveOps/eng leadership); **rung 2 pays once** (a left-shifted economy exploit that never ships is cheaper than the postmortem); **rung 3 pays in the tail** (insider/regulatory/dispute events that are rare but catastrophic).

---

## 6.5 Choosing the right rung: where each technique is genuinely irreplaceable

The most useful thing an attendee can leave with is the *judgment* of which rung a given problem needs — because the real skill on display isn't climbing as high as possible, it's reading the problem and reaching for the tool that fits it. The ladder is most valuable as a **decision aid**, and the way to teach that is to be precise about where each technique has no good substitute — and where a simpler, well-understood approach already does the job beautifully.

For each rung, ask three questions: *What outcome do we actually want? Is there a simpler reliable way to get it? And does the technique earn its place by doing something nothing else can?* That framing turns the talk into something an engineering lead can act on Monday morning.

| Rung | The outcome you want | Simpler approaches that often suffice | Where the rung is *uniquely* the right tool |
|---|---|---|---|
| **1 — Detect** | Catch evasive cheats and collusion rings early, with a reason attached | Rules, reports, manual review — fine for *blatant* abuse | **Adaptive adversaries and relational abuse.** A cheat tunes itself under any fixed threshold; a collusion ring is invisible when you score one account at a time. ML models *normal* and graph methods see *relationships* — there's no reliable non-ML way to catch an opponent who adapts, at scale. This rung is irreplaceable, which is exactly why every serious operator already runs it. |
| **2 — Verify rules** | Know an economy/rule exploit can't happen *before* you ship | Property-based testing, fuzzing, simulation, playtesting — catch most issues cheaply | **Certainty over a bounded, high-stakes rule set.** Fuzzing gives you *confidence* ("we tried 10M sequences, found nothing"); Automated Reasoning gives you *proof* ("no reachable state violates this") over a defined space. The difference matters when a single missed exploit — one infinite-gold loop — is catastrophic and the rule interaction is combinatorially large. Reach for it on the card-interaction set or the currency-conversion path, not the whole live economy. |
| **3 — Verify pipeline** | Detect tampering with your own RNG, config, or binaries | Signed configs, append-only audit logs, separation of duties, deploy provenance — strong, cheap hygiene | **When someone who doesn't trust your logs has to verify.** Internal hygiene reliably tells *you* nothing was altered. Commit-reveal/VRF/attestation produce an artifact a *skeptical outside party* — a regulator, a player in dispute, a partner studio — can check without taking your word. The cryptography earns its cost precisely at that trust boundary. |
| **4 — Expose** | Let outsiders verify outcomes without trusting you | Disclosure + a good reputation | **When external verifiability is part of the product** — regulated loot-box odds, on-chain games, competitive-integrity guarantees. Here "don't trust us, check it yourself" is a genuine differentiator, not overhead. |

**The honest, encouraging through-line:** these techniques *strengthen the system* when matched to a real need, and the framework's whole value is helping you make that match deliberately rather than by reflex. Rung 1 is near-universal because adaptive abuse is near-universal. Rungs 2–4 are sharper instruments for sharper problems — reach for them where real money, competitive rank, regulation, or an external verifier rides on the outcome, and you get a guarantee nothing cheaper can give you. Read the problem first; the right rung follows. *That judgment — not maximal climbing — is the takeaway most worth carrying out of the room.*

---

## 7. The recommended spine (detect → verify → optionally expose)

A tighter, more honest order than "make the game accountable":

Each rung follows one repeating shape — **plain-English analogy → live demo → today-vs-new → "in your genre"** — so a non-data-science audience can follow four unfamiliar techniques (see §8 for how the deck realizes this):

1. **Open on the operator's real question** — *"Is my game behaving as I designed it, how strong is my knowledge that it is, and what do I do when it isn't?"* Introduce SHARDFALL + STAR ORACLE, put the Confidence Ladder (§1) up, and promise to return to it.
2. **Rung 1 — Detect (the ROI core, lead here).** Anomaly detection (the evasive-aimbot demo) and graph analysis (the win-trading-ring demo), then close the rung with the **LLM analyst copilot** — the generative-AI hook that turns "score + features" into a reviewer-ready case note and makes higher recall operationally affordable. This is what pays for itself, so it leads.
3. **Rung 2 — Verify the rules.** Automated Reasoning finds the SHARDFALL infinite-gold *money pump* your playtesters missed, *before* launch, then proves the patched economy clean. The genuinely-uncommon-in-games beat.
4. **Rung 3 — Verify your own pipeline.** Commit-reveal as an *internal* tamper-evident control (§4), not a player gimmick. The live tamper test on the crate log (real SHA-256, computed in-browser).
5. **Rung 4 — Expose, optionally.** The elective player/regulator face (STAR ORACLE banner odds), gated by the §6 decision rule.
6. **Close on the three trust-earning slides** below.

**The three slides that make it substantive, not marketing:**
- **Proof of *what*, exactly** (§3) — the syntactic-vs-semantic table. This is the credibility anchor.
- **The two rules of the ladder** (§1) — never act on a suspicion as proof; never pay for proof you don't need.
- **When to build it — and when not** (§6) — the decision rule.

**Title (locked):** *The Confidence Ladder: Climb From Guesswork to Proof in Your Game.*
Backups if a shorter field is needed: *Stop Guessing. Start Proving.* · *What Can You Prove About Your Game?*

---

## 8. The proof: live demos that climb all the way up the ladder

Theory doesn't sell this; **demos the audience can poke at, that show the old way missing and the new way catching**, do. The demos exist in two forms, both consistent on the same numbers:

- **In-deck interactive (`confidence-ladder-deck-v2.html`)** — each rung has a real, in-browser demo on SHARDFALL data that *computes live on stage*, no Python, no network, can't-fail offline. Drag a threshold and watch evasive cheats slip under it; play a season and watch the win-trading ring assemble; run the money-pump loop and watch gold climb forever; click a crate record to tamper it and watch a **real SHA-256** turn red. (The browser SHA-256 was verified byte-identical to a reference implementation.)
- **Canonical Python (`/demo`)** — the auditable reference the kit ships; runs offline on synthetic data, pure stdlib + numpy, ~1 second. Same scenarios, same results.

All four beats map directly onto the ladder, and the climb is now complete (1 → 2 → 3):

| Beat | Rung | OLD (today) | NEW (this stack) | The honest point |
|---|---|---|---|---|
| **1 — Behavior** | 1 (probabilistic) | Fixed thresholds (accuracy/APM/reaction) | Anomaly detection on the *combination* of features, **+ the feature that fired as the reason** | Dataset includes **"evasive" cheats** tuned to sit just under every individual threshold — rules catch 0/35; anomaly detection catches all, with a "why." Interactive: drag the threshold and watch it fail no matter where you put it. Trades some precision for recall: it *surfaces for review*, never auto-bans. |
| **2 — Rings** | 1 (probabilistic) | Per-account win-rate heuristic | Graph analysis over the interaction graph; surface connected clusters | Colluders share wins ~50/50 so win rate looks normal — per-account catches 0; the *relational* view exposes every ring. Interactive: play a season and watch the knot form; toggle per-account vs. graph view. "The step-change a GNN delivers; shown as transparent graph analysis so it runs live." |
| **3 — Economy** | **2 (proof of rules)** | Playtest, fuzz, and hope — "we tried millions of trades" | **Automated Reasoning** searches every legal buy/sell/craft loop for a *money pump* | SHARDFALL's craft recipe (2 shards → a gem worth more than 2 shards cost) is a **+10g loop, items unchanged, forever** — found instantly; patch the recipe to 3 shards and it's **PROVEN** clean. Backed by `verify_economy.py` (a sound search over the bounded action lattice). "Playtesting says 'we didn't find a bug'; this says 'there isn't one.'" Production: **AWS Bedrock Automated Reasoning checks** / the Zelkova-Dafny provable-security lineage. |
| **4 — Pipeline** | 3 (cryptographic) | Server stores outcomes; an insider edit is invisible | Commit-reveal: `SHA-256(server_seed)` published *before* the act; outcome derived from `(server_seed, client_seed, nonce)` | Tamper one crate record (`common`→`RARE`) and verification **provably** fails and names the exact altered draw. "Not a confidence score — a hard true positive. SHA-256 here is real, not simulated." |

> The LLM **analyst copilot** is presented as the close of Rung 1 (a slide, not a live demo): it turns each detection's "score + features + implicated ring" into a plain-language case note, making higher recall affordable for the review team. The natural generative-AI / Amazon Bedrock hook.

**Takeaways the audience leaves with:** (1) a live metrics table — precision/recall of old thresholds vs. new detectors on the *same* labeled data, measurable on screen, not asserted; (2) the collusion ring the heuristic missed, assembled before their eyes; (3) the money pump the playtesters missed, found and then *proven* impossible after the fix; (4) a live tamper test where flipping one stored outcome makes a real hash fail. The deck deliberately walks **rung 1 → 2 → 3** so the audience *sees* the climb from suspicion to proof — which is the whole thesis.

**AWS production mapping** (service-free in the demos for portability):
- Beat 1 → SageMaker (train/infer), Kinesis (telemetry), SHAP (attribution), **Amazon Bedrock LLM** as the analyst copilot turning "score + feature" into a plain-language case note.
- Beat 2 → a GNN on SageMaker over a graph in Neptune / the match store.
- Beat 3 (economy) → **AWS Bedrock Guardrails Automated Reasoning checks**, and the AWS Provable-Security lineage (Zelkova, Dafny, s2n) — an SMT solver proving economy invariants over *all* action sequences, unbounded. *(Verify current Bedrock naming/status — see §9.)*
- Beat 4 → KMS (key custody/signing), Lambda (verify endpoint), DynamoDB + hash-chaining (tamper-evident log), Nitro Enclaves attestation (prove prod runs the shipped binary).

---

## 9. ⚠️ Verify before you submit

Live web research was not available in this session, so the following must be re-confirmed against current AWS docs before the abstract is locked:

1. **QLDB** — was sliding toward end-of-support; intentionally kept out of the mappings. Use DynamoDB + your own hash chain. Confirm status.
2. **Bedrock Guardrails "Automated Reasoning checks"** — confirm exact product name and GA-vs-preview status; §7 rung-2 leans on it.
3. **SageMaker Clarify** — confirm naming/availability for the attribution angle.
4. **AWS Clean Rooms** (+ Clean Rooms ML) — confirm current capability if you feature cross-studio abuse-signal sharing.
5. **Nitro Enclaves attestation** — confirm the attestation-document verification path before demoing rung-3 confidential compute.
6. **Amazon Fraud Detector** — confirm GA/maintenance/deprecated status before citing for payment fraud.
7. **GNN production path** — confirm current SageMaker graph support and whether Neptune (+ Neptune ML) is the recommended backing.
8. **Any prevalence/loss statistic** — every "X% cheat" / "$Y lost to fraud" figure must be sourced to a named, dated report. None are cited here; do not invent them on stage.

**Novelty caveat to own:** Automated Reasoning has appeared in prior AWS sessions — the gaming framing and the ladder context are what keep it fresh, not the technique. Your most differentiated angles are (a) the Confidence Ladder as an organizing principle, (b) verifiability reframed as an *internal* control, and (c) the honest "proof of what, exactly" boundary.
