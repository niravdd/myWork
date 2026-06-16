"""
tamper_check.py — the integrity layer, made tangible.

Scenario contrast:
  OLD: "trust our server." If an insider or a compromised service rewrites a
       loot outcome in the database, nothing detects it — the value just changes.
  NEW: every draw is a commit-reveal record. The server published
       commitment = SHA-256(server_seed) BEFORE the player acted, and the
       outcome is DERIVED from (server_seed, client_seed, nonce). Anyone can:
         (1) recompute SHA-256(server_seed) and check it equals the commitment
             (proves the seed wasn't chosen after the fact), and
         (2) recompute the outcome from the seeds (proves the result wasn't edited).

This script verifies the whole log, then TAMPERS with one record (flips a
'common' to a 'RARE', exactly what a fraudster would do) and shows verification
catching it deterministically — a hard true positive, not a probabilistic guess.

SHA-256 is real here, not simulated. Pure stdlib.
"""

import csv
import hashlib
import os

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")


def load_draws():
    rows = []
    with open(os.path.join(DATA_DIR, "draws.csv")) as f:
        for row in csv.DictReader(f):
            row["nonce"] = int(row["nonce"])
            row["roll"] = int(row["roll"])
            rows.append(row)
    return rows


def derive(server_seed, client_seed, nonce):
    digest = hashlib.sha256(f"{server_seed}:{client_seed}:{nonce}".encode()).hexdigest()
    roll = int(digest[:8], 16) % 10000
    outcome = "RARE" if roll < 100 else "common"
    return roll, outcome


def verify_record(rec):
    """Returns (ok, reason). Checks commitment binding AND outcome derivation."""
    recomputed_commit = hashlib.sha256(rec["server_seed"].encode()).hexdigest()
    if recomputed_commit != rec["commitment"]:
        return False, "commitment mismatch (seed altered or chosen after the fact)"
    roll, outcome = derive(rec["server_seed"], rec["client_seed"], rec["nonce"])
    if outcome != rec["outcome"] or roll != rec["roll"]:
        return False, (f"outcome tampered: stored '{rec['outcome']}' (roll {rec['roll']}) "
                       f"but seeds derive '{outcome}' (roll {roll})")
    return True, "ok"


def verify_all(rows):
    bad = []
    for rec in rows:
        ok, reason = verify_record(rec)
        if not ok:
            bad.append((rec["nonce"], reason))
    return bad


def main():
    rows = load_draws()
    print("=" * 68)
    print("RNG / PIPELINE INTEGRITY  —  OLD (trust server) vs NEW (commit-reveal)")
    print("=" * 68)
    print(f"Loaded {len(rows)} loot draws.\n")

    # 1. honest log verifies cleanly
    bad = verify_all(rows)
    print("STEP 1 — verify the honest log")
    print(f"     {len(rows)-len(bad)}/{len(rows)} draws verify. tampered: {len(bad)}")
    rares = [r for r in rows if r["outcome"] == "RARE"]
    print(f"     (rare drops in log: {len(rares)} ~ {100*len(rares)/len(rows):.1f}% "
          f"vs configured 1%)\n")

    # 2. an insider rewrites one record: turn a common draw into a RARE drop
    victim = next(r for r in rows if r["outcome"] == "common")
    print("STEP 2 — simulate an insider editing the database")
    print(f"     rewriting draw #{victim['nonce']}: 'common' -> 'RARE' "
          f"(fraudulent free rare item)")
    victim["outcome"] = "RARE"

    # 3. OLD world sees nothing; NEW world catches it deterministically
    print("\nSTEP 3 — detection")
    print("     OLD ('trust the server'): no signal. The value simply changed.")
    bad = verify_all(rows)
    print(f"     NEW (commit-reveal):     {len(bad)} record fails verification ->")
    for nonce, reason in bad:
        print(f"        draw #{nonce}: {reason}")

    print("\n  Takeaway: this is a HARD true positive. Verification doesn't 'suspect'")
    print("  tampering — it proves it, and pinpoints the exact altered record. That")
    print("  is the difference between probabilistic ML detection and a cryptographic")
    print("  control over your own pipeline.")


if __name__ == "__main__":
    main()
