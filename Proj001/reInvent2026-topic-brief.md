# re:Invent 2026 — "Is My Game Behaving as Designed?": A Game-Integrity & Cheat-Detection Stack

### Ranked topic brief for a breakout + live demo session (also usable as an internal capability pitch)

**Author working notes for:** session/abstract planning + internal funding case
**Format assumed:** 50-min breakout with a live demo (AWS-flavored — technique is the star, services bolted where natural)
**Primary lens:** the *studio's* point of view — assuring gameplay is fair-as-designed, and getting early, localized signals when it isn't (cheating, fraud, abuse, economy drift)
**Game goals in scope:** cheat / fraud / abuse detection · gameplay integrity (intended-vs-actual) · verifiability · performance / efficiency
**Date:** 2026-06-02 (studio-integrity reframe: 2026-06-04)

---

## 1. The core idea: an integrity & cheat-detection stack the studio *keeps*

The strongest re:Invent breakouts have a spine — a single mental model the audience carries out of the room. Individually, "Automated Reasoning," "cryptographic proofs," and "ML anti-cheat" are each a solid 50 minutes, but they've also each been covered before and risk feeling like a grab-bag.

The differentiated framing — and the one that sells to a studio's own engineering and LiveOps leadership — is to present them as **one interconnected stack that answers the question every operator actually loses sleep over: _"Is my game behaving as designed and as projected — and if not, exactly what is going wrong, and where?"_**

This is not a player-facing promise. It's an **integrity-assurance + observability capability the studio builds and owns.** The unifying concept is *intended-vs-actual divergence with root-cause localization*: you formally pin down what "as designed" means, you instrument the live game to detect when reality drifts from it (cheating, fraud, collusion, exploited rules, economy runaway), and every layer emits a **signal that points at where the problem is** rather than just raising a generic alarm.

Each layer answers a different integrity question, and they compose:

| Layer | Integrity question the *studio* asks | Core technique | Signal it gives the studio |
|---|---|---|---|
| **Rules** | "Are my rules/economy sound — or is there an exploit path I haven't found?" | Automated Reasoning / formal methods | A concrete counter-example sequence (the exact exploit), found pre-ship |
| **Randomness** | "Are my own drop/matchmaking systems running the odds I configured — and has anything tampered with them?" | Commit-reveal + VRF as a tamper-evident internal audit log | Cryptographic alarm if a service, build, or insider altered RNG/odds |
| **Computation** | "Is production actually running the code and config I shipped?" | Attestation / verifiable computation (Nitro, ZK) | Proof of binary/config integrity; detection of a swapped or patched server |
| **Behavior** | "Which sessions/accounts are bots, cheats, colluders, or fraud — and why?" | ML + behavioral anti-cheat / fraud analytics | Ranked, *explained* detections that localize the abuse |
| **Models** | "Has my matchmaking/moderation/economy AI drifted from intended behavior?" | Fairness & drift *checks* + guardrails | Drift/disparity signal showing which cohort or segment broke |

This is the recommended spine. The ranking below scores each candidate as both a *standalone* topic and as a *layer* in the stack, so you can either go deep on one or use the stack as the through-line and demo the strongest 1–2 live.

> **A precision note the talk must respect.** These layers differ in *how hard* their signal is. The Randomness and Computation layers are rooted in cryptography or hardware (SHA-256, VRF, ZK, Nitro attestation): when something is tampered with, an artifact *provably* fails to verify — a true positive with no ambiguity. The Rules layer (Automated Reasoning) gives a genuine mathematical proof, but over the rules *as specified*, not as shipped. The Behavior and Models layers are **statistical detection, not proof** — they produce ranked suspicions with false-positive/false-negative rates, not certainties, which is exactly why their output must feed human review and a remedy workflow, never an automatic ban. Be precise about which signals are hard and which are probabilistic; a skeptical engineering lead is listening for exactly this distinction.

---

## 2. What's actually new — vs. how studios detect abuse today

This is the first question any skeptical reviewer or engineering lead will ask, so answer it head-on rather than imply the techniques are novel (several aren't). The differentiator is **not the technology — it's closing three gaps in today's detection posture.**

**What studios do well today.** Modern operators already run serious machinery: server-authoritative simulation so the client isn't the source of truth; statistical and ML anti-cheat (Valve's Trust Factor, Activision's Ricochet, behavioral bot detection); fraud and payment-abuse models; MMR/matchmaking systems; and deep churn, anomaly, and economy analytics with dashboards and alerting. This stack does **not** replace any of that — it sits alongside it and fixes where it's blind. Three gaps:

**Gap 1 — detection is reactive and post-hoc.** Most abuse is caught *after* it has already distorted the economy or the ladder: a dupe exploit is noticed when prices crater, a bot ring when reports pile up. Today's analytics tell you *something broke*; they rarely tell you *the exact rule interaction that allowed it.* The Rules layer (Automated Reasoning) moves a whole class of exploits **left of launch** — you get the precise exploit sequence as a counter-example *before* players find it, not a postmortem after.

**Gap 2 — the detection systems themselves are unverified and tamperable.** Studios trust their *own* pipeline implicitly: that the RNG service is using the configured odds, that the prod binary is the one shipped, that a config push didn't quietly change a drop table, that no insider or compromised service altered a value. Today there's usually no independent artifact proving this — it's assumed. The Randomness and Computation layers turn "we assume our own systems are honest" into a **tamper-evident internal audit log**: if a service, build, or insider changes the odds or swaps the binary, verification *provably fails* and you get an alarm. This is an internal-threat and supply-chain-integrity capability today's player-facing analytics simply don't address.

**Gap 3 — alerts don't localize the root cause.** A typical anomaly alert says "economy metric X spiked." An analyst then spends hours reconstructing *why*. The stack is built so each layer emits a **localizing signal**: the solver hands you the offending rule, the audit log points to the service/build that diverged, the behavioral model returns ranked sessions *with the features that fired*, and the drift check names the cohort that broke. Less time from "something's wrong" to "here's where."

| | Today (typical detection) | This stack (integrity + localized signal) |
|---|---|---|
| **When you find out** | After distortion shows up in metrics | Pre-ship for rule exploits; real-time alarm for tampering |
| **Trust in your own pipeline** | Assumed honest, rarely verified | Cryptographically attested; tampering fails verification |
| **What an alert tells you** | "Metric X is anomalous" | "*This* rule / service / cohort / session, and why" |

So the one-line answer to "how is this different?" is: **today's tools tell a studio that something is wrong, usually after the fact; this stack aims to catch a class of problems before launch, verify the studio's own integrity pipeline against tampering, and point alerts at the root cause.** It's an upgrade to detection *posture*, not a replacement for the analytics studios already run.

Two caveats to own so it doesn't oversell:

- **The cryptographic layers are an internal control, not a silver bullet for cheating.** Commit-reveal/VRF and attestation harden *your own backend* against tampering and prove integrity; they do nothing against a client-side aimbot, which is the Behavior layer's job. Different threats, different layers — say so.
- **More models ≠ better detection if they're unexplained or unverified.** Adding ML without localization just moves the analyst bottleneck; adding pipelines you can't attest just adds attack surface. The value is in *left-shift, verifiability, and localization*, not in model count.

### 2.1 The secondary payoff: player trust (kept, but not the pitch)

Everything above is internal capability. As a by-product, several of these signals are *also* externally verifiable, which lets a studio — when it chooses — turn an internal control into a player- or regulator-facing assurance ("here's the audit log, verify the draw yourself"). That's a real bonus, especially for regulatory hedging on loot-box odds, but it is **downstream of the operational value, not the reason to build.** Treat it as the optional outward face of a capability whose primary justification is catching cheats, fraud, and exploits faster and earlier. (If the player-accountability angle is ever the lead, note the honest limit: math can produce a verifiable record and let an outside party check it, but the *remedy* — refunds, reversals, enforcement — is governance and law, not proof.)

---

## 3. The centerpiece: cheat, fraud & abuse detection — old way vs. new way

This is the heart of the studio-POV talk. Frame it as a **detection-maturity progression**: most studios start with rules/heuristics + manual review, and the newer AI/data-science toolkit upgrades each abuse category. The persuasive structure is *threat → how it's caught today → what the newer technique adds → what signal the analyst actually gets.* The live demo (§8) makes one row of this table real.

> **Sourcing note (read before citing).** Live web research was unavailable in this session (workspace egress was restricted to a few AWS hosts and the browser wasn't connected), so the AI/data-science techniques below are described from established, stable knowledge — they are real, widely deployed methods, but **named vendor systems and any "X% of cheaters caught" style stats must be re-verified and cited before you present.** The AWS service specifics remain quarantined in §7.

### 3.1 A taxonomy of abuse, and the technique that catches each

| Abuse category | How it's caught *today* (typical) | Newer AI / data-science technique | Why it's better | Signal the analyst gets |
|---|---|---|---|---|
| **Aimbots / triggerbots** | Statistical thresholds on accuracy/headshot%; player reports | **Sequence models / 1-D CNNs on raw input traces** (mouse/stick trajectories, view-angle deltas, reaction-time distributions) | Learns the *texture* of human vs. synthetic aim instead of a hard threshold a cheat tunes just under | A score + the input window that looks non-human |
| **Bots / scripted farming** | Hard rules (clicks/min, identical paths), CAPTCHAs | **Autoencoder / isolation-forest anomaly detection** on behavior embeddings | Flags "not like a human" *without* a labeled example of every bot; catches novel bots | Anomaly score + which features were off-distribution |
| **Collusion / win-trading / boosting** | Manual review of reports; pairwise heuristics | **Graph neural networks (GNNs)** over the player-interaction graph (who queues/trades/loses to whom) | Detects *rings and structures* invisible to per-account rules; finds the whole cluster, not one account | The implicated subgraph (the ring) with edge evidence |
| **RMT / gold-farming / Sybil multi-accounting** | Payment heuristics, IP/device bans | **GNN + graph analytics on transaction + device + account graphs** | Surfaces farm→mule→buyer money-flow networks and shared-identity clusters | The money-flow path and the linked-account cluster |
| **Economy exploits / dupes** | Noticed *after* prices crater; dashboards | **Time-series anomaly detection** on economy aggregates **+ Automated Reasoning** on the rules pre-ship | Left-shifts a class of exploits to *before* launch; flags runaway sinks/faucets in real time | The offending rule (pre-ship) or the diverging metric + window |
| **Payment fraud / ATO / chargebacks** | Rules engines, blocklists | **Gradient-boosted trees + sequence models on account-action history**, graph features for fraud rings | Adapts to evolving fraud patterns; ring-aware instead of per-transaction | Risk score + contributing features + linked accounts |
| **Toxicity / chat abuse** | Keyword filters, reports | **Transformer text classifiers + LLM context understanding** | Catches context, evasion spellings, and harassment patterns keywords miss | Flagged message + model rationale |
| **Pipeline tampering / insider RNG manipulation** | *Usually nothing* — own systems assumed honest | **Commit-reveal + VRF audit log; Nitro attestation** | Turns "we assume our backend is honest" into a tamper-evident, provable control | Cryptographic verification failure pinpointing service/build |

### 3.2 The newer techniques, and the value each adds

- **Graph neural networks (GNNs) for ring detection.** The single biggest upgrade over today's per-account heuristics. Collusion, win-trading, boosting, RMT, and Sybil farms are *relational* — they're invisible when you score one account at a time, but obvious as a structure in the interaction/transaction graph. A GNN learns node embeddings from the graph topology and flags suspicious clusters and money-flow paths. The analyst payoff is huge: instead of "this account is suspicious," you get "*this ring of 14 accounts* is win-trading, here are the edges." This is the highest-weight addition to the talk.
- **Sequence models / transformers on action traces.** Player input is a time series. Transformers/temporal CNNs learn the signature of human vs. synthetic control (aim micro-corrections, reaction-time distributions, action cadence) far better than a fixed accuracy threshold — which cheats simply tune under. Same machinery re-applies to fraud (account-action sequences) and to "is this session a human?".
- **Self-supervised / anomaly detection (autoencoders, isolation forests).** The escape from the labeled-data trap: you rarely have labeled examples of *next* season's cheat. Train on normal behavior, flag reconstruction error / out-of-distribution sessions. Catches novel abuse the rules were never written for.
- **LLM analyst copilot.** The force-multiplier for the human-review bottleneck that every detection system eventually hits. An LLM ingests the flagged session's evidence (the features that fired, the subgraph, recent history) and produces a plain-language *why-flagged* summary, drafts the case note, and triages by severity. It doesn't decide bans; it makes a human reviewer many times faster and more consistent. This is also the most natural generative-AI hook for an AWS audience.
- **Privacy-preserving + cross-studio signals (federated learning, differential privacy, data clean rooms).** Cheats and fraud rings span titles and studios. Federated learning trains a shared detector without pooling raw player data; clean rooms let two studios compute on overlapping abuse signals without exposing their players. This is how detection scales beyond one game while staying privacy-defensible — and it's a strong, current, AWS-relevant angle.
- **Explainability as a first-class output (SHAP / feature attribution).** The thread tying it to the §1 promise of *localization*: every model output should ship with *why*. SHAP-style attribution on the tabular/behavioral models, attention/saliency on the sequence models, and the implicated subgraph for the GNN. "Score + reason" is what turns a model into an operational tool an analyst trusts and a player-appeals process can stand behind.

### 3.3 The non-negotiable honesty line

Every probabilistic detector has false positives. The studio-credible architecture is **detect (ML) → explain (attribution/LLM) → human review → remedy**, never auto-ban on a model score. The cryptographic layers are the exception: a verification *failure* is a hard true positive about your own pipeline, not a suspicion. Say this explicitly — it's what separates an operations team that trusts the system from one that gets burned by a false-ban PR incident.

---

## 4. Why a studio would actually fund this

The brief's job is not to claim every game needs this — that pitch fails the moment a senior engineer does the cost-benefit in their head. It's to name the **narrow set of cases where the ROI is real**, because precision here is what makes the talk credible.

The investment is justified specifically where **abuse has a measurable P&L cost, where real money meets randomness, where competitive integrity meets revenue, or where regulation forces your hand.** Concretely:

- **Detection ROI — the operational core (lead with this for an internal pitch).** Cheating, botting, RMT, and fraud directly erode revenue (refunds, chargebacks, churn of paying players who quit a cheater-ridden ladder) and inflate cost (analyst hours, CS escalations). The newer techniques in §3 attack exactly this: GNNs surface whole fraud/collusion rings instead of one account at a time, anomaly detection catches novel abuse before it's labeled, left-shifted Automated Reasoning prevents an economy-breaking exploit from ever shipping, and the LLM copilot cuts analyst time-per-case. The pitch is a faster, earlier, cheaper-to-operate detection function — not a compliance nicety. *(Re-verify specific prevalence/loss stats before quoting — see §3 sourcing note.)*
- **Regulatory hedge — the strongest external driver.** Loot boxes are sliding toward gambling classification in several markets (Belgium, the Netherlands, ongoing EU and UK scrutiny, odds-disclosure mandates in China). If that lands, you'll need casino-grade RNG certification and audit trails *anyway*. Building verifiable fairness now is both a compliance moat and a "we can *prove* compliance" posture that beats "we disclosed and hoped." This is a board-level risk, not an engineering nicety.
- **Real money meets randomness.** Gacha and loot mechanics are a multi-billion-dollar category built entirely on players trusting odds they cannot see, in a market saturated with pity-timer and rigging accusations. "Don't trust us — verify it" is a genuine brand differentiator, especially for a studio entering a market where an incumbent has a credibility problem.
- **Competitive integrity with direct revenue impact.** Ranked and esports titles measurably bleed paying players to cheaters. Anti-cheat ROI is already well-established; the *privacy-preserving* angle specifically buys down the PR and trust cost of invasive kernel-level anti-cheat — the player backlash against Riot's Vanguard is the cautionary tale every studio knows.
- **Dispute and support-cost reduction.** Verifiable logs let "I got cheated by the RNG / the matchmaker / a bad ban" be settled with an artifact instead of a CS escalation. Fewer tickets, fewer chargebacks, fewer public refund fights.

**And the counter the talk should say out loud:** for a single-player game, a non-monetized random system, or a title with no competitive ladder, this is over-engineering — the verification machinery adds latency, key-management, and audit-surface cost for trust the game doesn't actually need. Saying this plainly is what earns the room's trust on everything else. The reference pattern attendees take home should come with a one-slide decision rule: **build the verifiable layer only where a player has money, rank, or a regulator riding on the outcome.**

---

## 5. Ranked topics

Re-scored for the **studio-integrity / detection lens**. Axes (1–5): **detection value** (how much it improves catching cheats/fraud/exploits), **demo buildability** (can you show current-vs-new live), **novelty** (fresh vs. past AWS sessions), **interconnection** (does it strengthen the integrity-stack story), **AWS fit** (natural service hook). "Total" is an unweighted sum out of 25. The ranking shifts from the original player-trust version: the detection-heavy topics rise, pure verifiability slips toward "supporting" status.

| # | Topic | Detection | Demo | Novelty | Interconn. | AWS fit | Total |
|---|---|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | **ML/behavioral cheat & bot detection (sequence models, anomaly detection)** | 5 | 5 | 4 | 5 | 4 | **23** |
| 2 | **GNNs for collusion / RMT / Sybil ring detection** | 5 | 4 | 5 | 4 | 4 | **22** |
| 3 | **Automated Reasoning for game-rule & economy soundness (left-shift exploits)** | 4 | 4 | 4 | 5 | 5 | **22** |
| 4 | **Tamper-evident integrity log: commit-reveal + VRF (catch insider/pipeline tampering)** | 4 | 5 | 4 | 5 | 4 | **22** |
| 5 | **LLM analyst copilot (explain-why-flagged, triage, case notes)** | 4 | 5 | 4 | 4 | 5 | **22** |
| 6 | **Confidential compute & attestation (prove prod runs shipped code) — Nitro Enclaves** | 3 | 4 | 3 | 5 | 4 | **19** |
| 7 | **Privacy-preserving cross-studio signals (federated learning, Clean Rooms)** | 4 | 3 | 4 | 4 | 4 | **19** |
| 8 | **Fairness / drift *checks* for matchmaking & moderation AI** | 3 | 4 | 3 | 4 | 4 | **18** |
| 9 | **Verifiable computation / ZK proofs of honest game state** | 3 | 2 | 5 | 4 | 2 | **16** |

The top five are now tightly bunched on purpose — for a 50-minute slot, pick the **anchor demo** from #1/#4 (most buildable as a clean current-vs-new), use #2 (GNN rings) as the high-novelty "wow," #3 as the AWS-anchor, and #5 (LLM copilot) as the generative-AI hook that ties detections back to a human workflow.

---

## 6. Topic detail — the verifiability/integrity techniques

> **How this section relates to §3 and §5.** The detection-focused techniques (ML/behavioral anti-cheat, GNN ring detection, anomaly detection, the LLM copilot) are detailed in **§3**, which is the studio-lens centerpiece. This section gives the longer-form write-ups for the **verifiability and formal-methods techniques** that complete the stack. The `#1–#5` labels below are *per-technique tags*, **not** the §5 detection-lens ranking — don't read them as a priority order. For a 50-min studio-POV talk, the live anchor is the §8 current-vs-new demo; treat the items below as the deeper bench you draw on for the supporting segments.

### #1 — Verifiable / provably-fair randomness (as an internal tamper-evident log)
**Game problem.** Loot boxes, gacha pulls, card shuffles, matchmaking seeds, crit rolls — every one is a trust flashpoint. Players (and increasingly regulators around loot-box gambling mechanics) suspect the house rigs the odds. "Provably fair" is already a known concept in crypto-gaming, which gives you instant audience recognition.

**Demo concept (very buildable live).** A commit-reveal + VRF loot-box opener. Server commits to a hashed seed *before* the player acts, player contributes entropy, the combined seed produces the drop, and anyone can independently verify the result wasn't chosen after the fact. Show a live "audit" panel where the audience re-computes the hash and confirms the rare drop was predetermined and fair.

**AWS mapping.** KMS for key custody and signing; Lambda for the reveal/verify endpoint; DynamoDB for the commitment log; (optionally) a VRF library running in Lambda. Clean, cheap, fully live-demoable.

**Why #1.** Highest combination of buildability, visual payoff ("verify it yourself, right now"), and it anchors the whole stack's "randomness" layer.

---

### #2 — Automated Reasoning for game-rule & economy soundness
**Game problem.** Most catastrophic game exploits aren't hacks — they're *logically valid* but unintended rule interactions (infinite-gold loops, combo locks, stat overflows, economy death spirals). Automated Reasoning lets you formally specify rules/invariants and prove no reachable state violates them, instead of hoping QA stumbles on it.

**Demo concept.** Encode a small game economy or card-interaction ruleset as logical constraints, then ask a solver to *find* an exploit (e.g., a sequence that yields infinite currency). Show it surfacing the exploit, fix the rule, and prove the property now holds. The "the machine found the exploit your playtesters missed" moment is strong.

**AWS mapping.** This is the most natural AWS hook: **Bedrock Guardrails Automated Reasoning checks** for the LLM-facing angle, and the broader AWS Automated Reasoning heritage (Zelkova, s2n, etc.) for credibility. ⚠️ *Verify current GA/naming of "Automated Reasoning checks" before the abstract — see §7.*

**Why #2.** Deeply on-brand for AWS, strong "wow," and it's the "rules" layer. Slightly lower novelty because AWS has run Automated Reasoning sessions before — your gaming framing is what makes it fresh.

---

### #3 — Privacy-preserving anti-cheat & abuse analytics
**Game problem.** Aimbots, wallhacks, bots, gold-farming, and toxic behavior. Traditional anti-cheat is invasive (kernel-level drivers) and players resent it. The fresh angle: detect cheating from behavioral/server-side signals using ML, *without* deep client surveillance.

**Demo concept.** A live classifier that flags bot-like vs. human input patterns (mouse/movement trajectories, reaction-time distributions) in a tiny browser game, scoring the audience in real time. Pair with a privacy framing: features are aggregated, not raw keystroke logs.

**AWS mapping.** SageMaker for the model; Kinesis for the telemetry stream; Bedrock for an LLM that explains *why* a session was flagged (analyst copilot). Optionally Clean Rooms for cross-studio abuse-signal sharing without exposing player data.

**Why #3.** Hits all four goals, very relatable, and bridges the "behavior" layer to the "models" layer.

---

### #4 — Fairness checks for AI in games
**Game problem.** AI now runs moderation (chat toxicity), matchmaking, and NPC behavior. Biased moderation that disproportionately flags certain dialects, or matchmaking that quietly disadvantages a cohort, is a real trust and PR risk. A "fairness check" = systematically testing model decisions against fairness criteria, not just eyeballing metrics. **Call this a check, not a proof** — it raises confidence statistically, it doesn't mathematically foreclose a bad outcome (see the precision note in §1).

**Demo concept.** Run a toxicity-moderation model against a crafted test set, expose a disparity (e.g., false-positive skew across slang/dialect groups), then show a bias check / constraint that catches it before ship.

**AWS mapping.** SageMaker Clarify for bias metrics; Bedrock Guardrails for content safety on NPC/chat LLMs.

**Why #4.** Topical and important, but the guarantee here is statistical fairness *testing*, not a hard mathematical proof — be precise in the abstract so you don't oversell. It's the "models" layer.

---

### #5 — Verifiable computation / ZK proofs of honest game state
**Game problem.** In server-authoritative and especially in decentralized/on-chain games, can a client (or a third party) verify the server computed the outcome by the rules without re-running everything or seeing hidden state (fog of war, opponent's hand)?

**Demo concept.** A zero-knowledge proof that "this move was legal and the resulting score is correct" without revealing hidden information — e.g., prove a battleship hit was honestly adjudicated without revealing ship positions.

**AWS mapping.** Weakest native AWS fit (ZK tooling is mostly third-party libs on EC2/Lambda), which is fine given your AWS-*flavored* stance. Pairs naturally with #6 (Nitro attestation) as the "if you don't want full ZK, attest the computation instead" pragmatic alternative.

**Why #5.** Highest novelty and the deepest "verifiability" story, but the hardest to demo cleanly in 50 minutes. Best as a "where this goes next" segment rather than the live centerpiece.

---

## 7. Recommended session shape

**Title candidates (studio-integrity lens)**
- *Is My Game Behaving as Designed? An AI Cheat- & Fraud-Detection Stack on AWS*
- *Catch It Earlier, Localize It Faster: Modern Game-Integrity with GNNs, Anomaly Detection & Verifiable Logs*
- *From "Something Broke" to "Here's the Ring": Next-Gen Abuse Detection for Games*

**Spine (detection maturity), with one deep current-vs-new demo.** Open with the operator's question from §1 — *"is my game behaving as designed, and if not, where is it going wrong?"* Walk the §3 taxonomy (the old-way-vs-new-way table) as the backbone, then go *deep + live* on the **current-vs-new demo (§8)**: run the old heuristic detector, watch it miss, then run the modern stack and watch it catch the cheats *and explain why*. Use the **GNN ring-detection** beat as the high-novelty "wow," and the **LLM copilot** as the close that ties model output to a human workflow.

**Three slides that earn the room's trust** (what makes it substantive, not a marketing pitch):

1. **Hard signal vs. probabilistic signal** — the boundary slide from §1: cryptographic verification failures are certainties about your own pipeline; ML detections are ranked suspicions that must feed human review. Never auto-ban on a score.
2. **Detect → explain → review → remedy** — the operational architecture from §3.3, with explainability (SHAP / subgraph / attention) as a first-class output, not an afterthought.
3. **When to build it — and when not to** — the §4 decision rule: invest where abuse has a measurable P&L cost, money meets randomness, competitive integrity meets revenue, or regulation forces your hand.

**Why this composition wins:** it leads with an operational capability a studio *keeps* (not a player promise), it differentiates from prior single-technique sessions by showing a *detection-maturity progression* with newer AI (GNNs, sequence models, anomaly detection, LLM copilot), and it hands attendees something tangible — a runnable current-vs-new reference (§8) and an honest rule for when it's worth the money. Player-facing verifiability rides along as the optional outward face (§2.1), not the headline.

---

## 8. The proof: a runnable "current vs. new" demo

Theory doesn't sell this — a side-by-side that *shows the old way missing and the new way catching* does. The demo is built and lives in the project folder (`/demo`), designed to run offline (synthetic data, no external services) so it's safe to present live and easy for attendees to re-run.

**What it demonstrates, on one synthetic dataset of player sessions + interactions:**

| | OLD scenario (today) | NEW scenario (this stack) |
|---|---|---|
| **Cheat/bot detection** | Fixed thresholds on accuracy & actions/min | Anomaly detection on behavior features (+ explanation of which feature fired) |
| **Collusion / win-trading** | Per-account heuristics (misses the ring) | Graph analysis over the match-interaction graph (surfaces the whole ring) |
| **RNG / pipeline integrity** | "Trust our server" — tampering is invisible | Commit-reveal audit log — tampering *provably* fails verification |
| **Output** | A binary ban list, no rationale | Ranked detections **with reasons** + the implicated cluster |

**Tangible takeaways the audience leaves with:** (1) a metrics table — precision/recall of old thresholds vs. the new detectors on the same labeled synthetic data, making the improvement *measurable on screen*, not asserted; (2) a printed collusion ring the heuristic missed; (3) a live tamper test where flipping one stored outcome makes the cryptographic verification fail. See `/demo/README.md` for how to run it and the exact talking points for each beat.

> The demo uses a graph-analytics community/anomaly approach rather than a full trained GNN so it runs in seconds on a laptop with no GPU; the README notes exactly where a production GNN (e.g. on SageMaker) would slot in. The cryptographic commit-reveal is real (SHA-256), not simulated.

---

## 9. ⚠️ Verify before you submit (live web was unavailable in this environment)

**Sourcing status for this revision (2026-06-04):** live web research was unavailable this session — workspace web egress was restricted to a handful of AWS API hosts, and the browser extension wasn't connected. The newer AI/data-science techniques in §3 (GNNs, sequence models, anomaly detection, LLM copilots, federated learning) are described from stable, established knowledge and are not in dispute, but **named vendor systems, any prevalence/loss statistics, and all AWS service names/status below must be re-verified and cited before submission.** I was not able to confirm them this session.

These are the facts most likely to have shifted; confirm against current AWS docs before locking the abstract:

1. **QLDB (Quantum Ledger Database)** — Historically the obvious "auditable, cryptographically verifiable ledger" service for tamper-evident game state. AWS *announced QLDB end-of-support / deprecation*; I deliberately left it **out** of the mappings above. Do not build a demo on QLDB without confirming its status — use DynamoDB + your own hash-chain, or a ledger alternative, instead.
2. **Bedrock Guardrails "Automated Reasoning checks"** — Confirm the exact current product name and whether it's GA vs. preview, since the abstract leans on it for topic #2.
3. **SageMaker Clarify** — Confirm current naming/availability for the fairness-metrics angle in #4.
4. **AWS Clean Rooms** differential-privacy / cross-party features for #3 — confirm current capabilities if you feature cross-studio abuse-signal sharing.
5. **Nitro Enclaves attestation** flow for #6 — confirm the attestation-document verification path if you demo confidential compute.
6. **Amazon Fraud Detector** — confirm current status (GA / maintenance / deprecated) before citing it for the payment-fraud row in §3.1.
7. **GNN production path** — confirm current SageMaker support for graph neural networks and whether Amazon Neptune (+ Neptune ML) is the recommended graph backing for the ring-detection use case.
8. **Federated learning / cross-studio signals** — confirm the current recommended AWS pattern (and whether Clean Rooms ML covers the privacy-preserving collaborative-model angle) before featuring §3.2's cross-studio bullet.
9. **Cheating/fraud prevalence & loss statistics** — any "X% of players cheat" or "$Y lost to fraud" figure used in §3/§4 must be sourced to a named, dated report; none are cited yet.

Also a candid novelty note: **Automated Reasoning has appeared in multiple past AWS sessions**, so its standalone novelty is moderate — the gaming framing and the stack context are what keep it fresh. Verifiable randomness and the integrated "trust stack" framing are your most differentiated angles.
