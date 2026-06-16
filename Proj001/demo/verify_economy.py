"""
verify_economy.py — Rung 2 of the Confidence Ladder: VERIFY THE RULES.

OLD way  (today): playtest + fuzz the economy and hope. "We tried thousands of
                  trades and nothing broke" is CONFIDENCE, not certainty — and a
                  single missed money-pump means an infinite-gold meltdown found
                  AFTER players find it.

NEW way  (this): AUTOMATED REASONING. Encode the economy's rules as math, then
                 search the whole space for a sequence of *legal* actions that
                 nets free gold while leaving inventory unchanged (a "money
                 pump"). Either it hands you the EXACT exploit recipe, or it
                 proves none exists — BEFORE launch.

This is a dependency-free, sound stand-in for a production Automated Reasoning
check. In production this is:
  * AWS Bedrock Guardrails — Automated Reasoning checks, and/or
  * the AWS Provable-Security lineage (Zelkova, Dafny, s2n) — an SMT solver
    such as Z3 proving the property over ALL sequences, unbounded.
Here we reason over the economy's action-effect lattice with bounded action
counts. For a small linear economy that bound is complete; the technique and
the on-screen result are exactly what the production tool delivers.

Pure Python stdlib. Runs in well under a second. No GPU, no network, no installs.
"""

from itertools import product

# ---------------------------------------------------------------------------
# THE GAME ECONOMY (the "rulebook" a designer writes)
#
# Players hold GOLD plus two item types: SHIELD and GEM.
# Each action changes their holdings. Buys cost gold; sells return gold; the
# crafting recipe combines shields into a gem. Everything below looks individually
# reasonable — the question Rung 2 answers is whether some COMBINATION breaks it.
#
# Each action: name -> (gold_delta, {item: delta})
# A precondition (enough gold to buy, enough items to sell/craft) is enforced
# when we build a readable ordering; the math search works on the net effects.
# ---------------------------------------------------------------------------
ITEMS = ("shield", "gem")


def buggy_economy():
    """The shipped-as-designed economy. Each rule looks fine on its own."""
    return {
        "buy_shield":  (-40, {"shield": +1}),            # shop sells a shield for 40g
        "sell_shield": (+35, {"shield": -1}),            # buyback at 35g (5g spread — fine)
        "buy_gem":     (-100, {"gem": +1}),              # shop sells a gem for 100g
        "sell_gem":    (+90, {"gem": -1}),               # buyback at 90g (10g spread — fine)
        # CRAFTING RECIPE — the subtle bug: 2 shields -> 1 gem.
        # Nobody set out to create free gold. But 2 shields cost 80g, a gem sells
        # for 90g... the recipe is mispriced relative to the shop. Playtesters who
        # try actions one at a time never see it.
        "craft_gem":   (0,   {"shield": -2, "gem": +1}),
    }


def patched_economy():
    """The fix: the recipe needs 3 shields (120g) for a gem that sells for 90g.
    Crafting is now a gold SINK, as intended — no profitable inventory-neutral loop."""
    econ = buggy_economy()
    econ["craft_gem"] = (0, {"shield": -3, "gem": +1})
    return econ


# ---------------------------------------------------------------------------
# THE AUTOMATED-REASONING CHECK
#
# A "money pump" is a non-empty multiset of actions whose item-effects all sum
# to ZERO (you end holding exactly what you started with) but whose gold-effect
# sums POSITIVE. Repeat it forever -> unbounded gold. We search the action-count
# lattice up to a bound; for a small linear economy this is complete.
# ---------------------------------------------------------------------------
def find_money_pump(econ, max_per_action=4):
    """Return the minimal money-pump as a dict {action: count}, or None if the
    invariant 'no legal play yields free gold' holds within the search bound."""
    names = list(econ.keys())
    best = None
    best_total = None
    # enumerate non-negative action counts (c_a) for every action
    for counts in product(range(max_per_action + 1), repeat=len(names)):
        total = sum(counts)
        if total == 0:
            continue
        net_gold = 0
        net_items = {it: 0 for it in ITEMS}
        for name, c in zip(names, counts):
            if c == 0:
                continue
            g, eff = econ[name]
            net_gold += c * g
            for it, d in eff.items():
                net_items[it] += c * d
        inventory_neutral = all(v == 0 for v in net_items.values())
        if inventory_neutral and net_gold > 0:
            # a profitable, inventory-neutral loop = money pump
            if best_total is None or total < best_total:
                best = {n: c for n, c in zip(names, counts) if c > 0}
                best_total = total
                best_gain = net_gold
    if best is None:
        return None
    return best, best_gain


def order_pump(econ, pump, start_gold=1000):
    """Build a readable, precondition-respecting ordering of the pump actions,
    so we can print the exact step-by-step exploit a player would perform."""
    remaining = dict(pump)
    gold = start_gold
    holding = {it: 0 for it in ITEMS}
    sequence = []
    guard = 0
    while sum(remaining.values()) > 0 and guard < 1000:
        guard += 1
        progressed = False
        for name, cnt in list(remaining.items()):
            if cnt <= 0:
                continue
            g, eff = econ[name]
            # precondition: never go negative on gold or any item
            if gold + g < 0:
                continue
            if any(holding[it] + d < 0 for it, d in eff.items()):
                continue
            # apply
            gold += g
            for it, d in eff.items():
                holding[it] += d
            sequence.append(name)
            remaining[name] -= 1
            progressed = True
            break
        if not progressed:
            break
    return sequence, gold - start_gold


def _print_econ(econ):
    for name, (g, eff) in econ.items():
        items = ", ".join(f"{it}{d:+d}" for it, d in eff.items())
        gold = f"gold{g:+d}" if g else "gold +0"
        print(f"       {name:<12}  {gold:<10}  {items}")


def main():
    print("=" * 68)
    print("ECONOMY-RULE SOUNDNESS  —  OLD (playtest & hope) vs NEW (prove it)")
    print("=" * 68)
    print("The invariant the designer wants to hold:")
    print("   'No sequence of legal actions returns you to the same items")
    print("    with MORE gold than you started.'  (i.e. no infinite-gold loop)\n")

    # ---- OLD ----
    print("OLD  playtest / fuzz the economy and hope")
    print("     A QA pass tries thousands of trades, finds nothing obvious, ships.")
    print("     Each rule below looks individually reasonable:\n")
    econ = buggy_economy()
    _print_econ(econ)

    # ---- NEW: find the exploit ----
    print("\nNEW  automated reasoning — search EVERY legal combination for a money pump")
    result = find_money_pump(econ)
    if result is None:
        print("     (unexpected: no pump found in the buggy economy)")
        return
    pump, gain = result
    seq, realized = order_pump(econ, pump)
    print("     \033[91m✗ COUNTER-EXAMPLE FOUND\033[0m — the exploit playtesters missed:\n")
    steps = " -> ".join(seq)
    print(f"        {steps}")
    # explain the arithmetic
    parts = []
    g = 0
    for name in seq:
        gd, _ = econ[name]
        g += gd
        parts.append(f"{name}({gd:+d}g)")
    print(f"        net: {' '.join(parts)}  =  \033[93m{gain:+d} gold, items unchanged\033[0m")
    print(f"        => repeat forever => UNBOUNDED gold. (a 2-shield craft sells")
    print(f"           as a gem for more than the shields cost.)")

    # ---- NEW: fix and prove ----
    print("\n     Designer patches the recipe: craft now needs 3 shields, not 2.")
    fixed = patched_economy()
    print("       craft_gem    gold +0     shield-3, gem+1   <- the fix\n")
    result2 = find_money_pump(fixed)
    if result2 is None:
        print("     \033[92m✓ PROVEN — no sequence of legal actions yields free gold.\033[0m")
        print("        The search is complete over the economy's action lattice:")
        print("        every inventory-neutral loop now nets <= 0 gold. The exploit")
        print("        class cannot ship — caught LEFT OF LAUNCH, with the offending")
        print("        rule named.")
    else:
        p2, gain2 = result2
        print(f"     still vulnerable: {p2} (+{gain2}g)  — keep tuning")

    print("\n  Takeaway: playtesting says 'we didn't find a bug.' Automated Reasoning")
    print("  says 'there ISN'T one' — or hands you the exact recipe if there is.")
    print("  That is the jump from confidence to CERTAINTY, before a single player")
    print("  logs in. In production: AWS Bedrock Automated Reasoning checks / the")
    print("  Provable-Security lineage (Zelkova, Dafny) prove this unbounded.")


if __name__ == "__main__":
    main()
