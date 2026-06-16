"""
run_demo.py — one-shot driver for the full current-vs-new game-integrity demo.

Usage:
    python3 run_demo.py

Generates fresh synthetic data, then climbs the Confidence Ladder rung by rung —
each rung a cleaner, stronger guarantee than the one below it:
  Rung 1 · Detect          behavioral cheats  (rules        vs anomaly detection)
  Rung 1 · Detect          collusion rings    (per-account  vs graph analysis)
  Rung 2 · Verify rules    economy soundness  (playtest&hope vs automated reasoning)
  Rung 3 · Verify pipeline RNG integrity      (trust-server vs commit-reveal)

Pure numpy + Python stdlib. No GPU, no installs beyond numpy, no network.
"""

import generate_data
import detect_behavior
import detect_rings
import verify_economy
import tamper_check


def main():
    print("\n########  GENERATING SYNTHETIC DATA  ########\n")
    rows = generate_data.gen_sessions()
    edges, rings = generate_data.gen_interactions(rows)
    generate_data.gen_draws()
    print(f"  {len(rows)} sessions, {len(edges)} interactions, {len(rings)} rings, 200 draws\n")

    print("\n########  RUNG 1 · DETECT — BEHAVIORAL CHEATS (probabilistic)  ########\n")
    detect_behavior.main()

    print("\n\n########  RUNG 1 · DETECT — COLLUSION RINGS (probabilistic)  ########\n")
    detect_rings.main()

    print("\n\n########  RUNG 2 · VERIFY RULES — ECONOMY SOUNDNESS (proof of rules)  ########\n")
    verify_economy.main()

    print("\n\n########  RUNG 3 · VERIFY PIPELINE — RNG INTEGRITY (cryptographic proof)  ########\n")
    tamper_check.main()

    print("\n\n########  DEMO COMPLETE — climbed Rung 1 -> 2 -> 3  ########")
    print("See README.md for the talking points that go with each rung.\n")


if __name__ == "__main__":
    main()
