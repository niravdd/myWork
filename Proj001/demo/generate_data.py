"""
generate_data.py — synthetic game-session + interaction dataset for the
"current vs. new" game-integrity demo.

Produces three artifacts in ./data:
  - sessions.csv      : per-session behavioral features + ground-truth label
  - interactions.csv  : match-level "who played against whom" edges (for ring detection)
  - draws.csv         : a commit-reveal RNG log (loot draws) used by the integrity demo

Everything is synthetic and deterministic (fixed seed) so the demo is reproducible
and safe to run live with no external services.

Ground-truth labels exist ONLY so the demo can score detector accuracy on screen.
A real deployment would not have these; that is the whole point of anomaly /
graph methods (see README).
"""

import csv
import hashlib
import os
import secrets
import numpy as np

RNG = np.random.default_rng(42)
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(DATA_DIR, exist_ok=True)

N_LEGIT = 900          # ordinary human players
N_BOTS = 45            # blatant bots / aim cheats (any rules engine catches these)
N_EVASIVE = 35         # cheats that tune each stat JUST under the rule thresholds
N_COLLUDERS = 40       # win-trading ring members (relational anomaly)

# Rule thresholds the OLD detector uses (kept here so the evasive cohort can be
# crafted to sit just under each one — the real-world cat-and-mouse).
OLD_ACC_T = 0.55
OLD_APM_T = 175
OLD_RT_T = 130


def _clip(x, lo, hi):
    return max(lo, min(hi, x))


def gen_sessions():
    """Behavioral features per player session.

    Features chosen to be intuitive on a slide:
      accuracy            : hit ratio (cheats aim too well, too consistently)
      actions_per_min     : input rate (bots are fast & metronomic)
      reaction_ms_mean    : mean reaction time (cheats react implausibly fast)
      reaction_ms_std     : variability (humans are noisy; bots are not)
      session_min         : session length
      headshot_ratio      : fraction of kills that are headshots
    """
    rows = []
    pid = 0

    # --- Legit humans: broad, noisy distributions ---
    for _ in range(N_LEGIT):
        acc = _clip(RNG.normal(0.34, 0.08), 0.05, 0.7)
        apm = _clip(RNG.normal(95, 25), 30, 200)
        rt_mean = _clip(RNG.normal(270, 45), 160, 450)
        rt_std = _clip(RNG.normal(60, 15), 20, 120)     # humans: high variability
        sess = _clip(RNG.normal(35, 18), 3, 120)
        hs = _clip(RNG.normal(0.22, 0.07), 0.0, 0.6)
        rows.append([f"p{pid}", round(acc, 4), round(apm, 1),
                     round(rt_mean, 1), round(rt_std, 1), round(sess, 1),
                     round(hs, 4), "legit"])
        pid += 1

    # --- Bots / aim cheats: too good, too consistent, too fast ---
    for _ in range(N_BOTS):
        acc = _clip(RNG.normal(0.62, 0.06), 0.45, 0.95)      # high accuracy
        apm = _clip(RNG.normal(165, 20), 120, 240)           # high, steady input
        rt_mean = _clip(RNG.normal(150, 25), 80, 220)        # implausibly fast
        rt_std = _clip(RNG.normal(18, 6), 5, 40)             # very low variability
        sess = _clip(RNG.normal(80, 30), 10, 240)            # long grinds
        hs = _clip(RNG.normal(0.5, 0.1), 0.25, 0.9)          # high headshot ratio
        rows.append([f"b{pid}", round(acc, 4), round(apm, 1),
                     round(rt_mean, 1), round(rt_std, 1), round(sess, 1),
                     round(hs, 4), "bot"])
        pid += 1

    # --- Evasive cheats: deliberately sit JUST UNDER every rule threshold.
    #     accuracy a touch below 0.55, apm below 175, reaction just above 130.
    #     Individually every feature looks "legal", so the rules engine clears them.
    #     But the COMBINATION (good accuracy AND fast reaction AND low variability)
    #     is still far from the human distribution -> the anomaly detector flags it.
    for _ in range(N_EVASIVE):
        acc = _clip(RNG.normal(OLD_ACC_T - 0.03, 0.015), 0.45, OLD_ACC_T - 0.005)  # ~2.5σ high
        apm = _clip(RNG.normal(OLD_APM_T - 10, 6), 130, OLD_APM_T - 1)            # elevated
        rt_mean = _clip(RNG.normal(OLD_RT_T + 12, 6), OLD_RT_T + 1, 165)          # ~2.6σ low
        rt_std = _clip(RNG.normal(22, 5), 10, 38)            # robotic steadiness (~2.5σ low)
        sess = _clip(RNG.normal(55, 22), 8, 160)
        hs = _clip(RNG.normal(0.40, 0.05), 0.25, 0.55)       # ~2.5σ high
        rows.append([f"e{pid}", round(acc, 4), round(apm, 1),
                     round(rt_mean, 1), round(rt_std, 1), round(sess, 1),
                     round(hs, 4), "evasive"])
        pid += 1

    # --- Colluders: behaviorally NORMAL (this is the trap for behavioral detectors).
    #     They look like ordinary humans per-session; only their interaction
    #     pattern (the graph) gives them away. ---
    for _ in range(N_COLLUDERS):
        acc = _clip(RNG.normal(0.34, 0.08), 0.05, 0.7)
        apm = _clip(RNG.normal(95, 25), 30, 200)
        rt_mean = _clip(RNG.normal(270, 45), 160, 450)
        rt_std = _clip(RNG.normal(60, 15), 20, 120)
        sess = _clip(RNG.normal(35, 18), 3, 120)
        hs = _clip(RNG.normal(0.22, 0.07), 0.0, 0.6)
        rows.append([f"c{pid}", round(acc, 4), round(apm, 1),
                     round(rt_mean, 1), round(rt_std, 1), round(sess, 1),
                     round(hs, 4), "colluder"])
        pid += 1

    header = ["player_id", "accuracy", "actions_per_min", "reaction_ms_mean",
              "reaction_ms_std", "session_min", "headshot_ratio", "label"]
    with open(os.path.join(DATA_DIR, "sessions.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    return rows


def gen_interactions(rows):
    """Match edges. Legit players face a broad random set of opponents.
    Colluders are organized into small rings that play each other far more
    than chance — the relational signature of win-trading / boosting."""
    legit_and_bots = [r[0] for r in rows if r[7] in ("legit", "bot", "evasive")]
    colluders = [r[0] for r in rows if r[7] == "colluder"]

    edges = []  # (player_a, player_b, winner)

    # Normal matchmaking: each legit/bot player has many matches vs random opponents
    for p in legit_and_bots:
        for _ in range(RNG.integers(8, 16)):
            opp = legit_and_bots[RNG.integers(0, len(legit_and_bots))]
            if opp == p:
                continue
            winner = p if RNG.random() < 0.5 else opp
            edges.append([p, opp, winner])

    # Collusion rings: partition colluders into rings of 4-6 who play each other
    # repeatedly, with lopsided, alternating wins (classic win-trading to farm rank/rewards).
    i = 0
    ring_id = 0
    rings = {}
    while i < len(colluders):
        size = int(RNG.integers(4, 7))
        ring = colluders[i:i + size]
        if len(ring) >= 3:
            rings[ring_id] = ring
            for a in ring:
                for b in ring:
                    if a >= b:
                        continue
                    # many repeated intra-ring matches
                    for _ in range(RNG.integers(6, 12)):
                        winner = a if RNG.random() < 0.5 else b
                        edges.append([a, b, winner])
            # a few camouflage matches vs the general pool
            for a in ring:
                for _ in range(RNG.integers(1, 4)):
                    opp = legit_and_bots[RNG.integers(0, len(legit_and_bots))]
                    winner = a if RNG.random() < 0.5 else opp
                    edges.append([a, opp, winner])
            ring_id += 1
        i += size

    with open(os.path.join(DATA_DIR, "interactions.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["player_a", "player_b", "winner"])
        w.writerows(edges)

    # save ground-truth rings for scoring
    with open(os.path.join(DATA_DIR, "rings_truth.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["ring_id", "member"])
        for rid, members in rings.items():
            for m in members:
                w.writerow([rid, m])
    return edges, rings


def gen_draws(n=200):
    """A commit-reveal loot-draw log.

    For each draw the server commits hash(server_seed) BEFORE the player acts,
    then reveals server_seed. The outcome is derived deterministically from
    (server_seed, client_seed, nonce). Anyone can recompute and verify.

    We write the data honestly here; tamper_check.py will later flip one
    'outcome' to show the verification catching it.
    """
    rows = []
    for nonce in range(n):
        server_seed = secrets.token_hex(16)
        client_seed = secrets.token_hex(8)
        commitment = hashlib.sha256(server_seed.encode()).hexdigest()
        digest = hashlib.sha256(f"{server_seed}:{client_seed}:{nonce}".encode()).hexdigest()
        # map first 8 hex digits to a 0..9999 roll; <100 => rare drop (1%)
        roll = int(digest[:8], 16) % 10000
        outcome = "RARE" if roll < 100 else "common"
        rows.append([nonce, commitment, server_seed, client_seed, roll, outcome])

    with open(os.path.join(DATA_DIR, "draws.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["nonce", "commitment", "server_seed", "client_seed", "roll", "outcome"])
        w.writerows(rows)
    return rows


if __name__ == "__main__":
    rows = gen_sessions()
    edges, rings = gen_interactions(rows)
    draws = gen_draws()
    print(f"Wrote {len(rows)} sessions "
          f"({N_LEGIT} legit, {N_BOTS} blatant bots, {N_EVASIVE} evasive cheats, "
          f"{N_COLLUDERS} colluders)")
    print(f"Wrote {len(edges)} match interactions across {len(rings)} collusion rings")
    print(f"Wrote {len(draws)} commit-reveal loot draws")
    print("Data ready in ./data")
