"""
detect_rings.py — OLD vs NEW collusion / win-trading ring detection.

The colluders in this dataset are behaviorally NORMAL — a per-account detector
cannot see them. Their signature is RELATIONAL: they play each other far more
than chance. This is the case GNNs / graph analytics solve.

OLD: per-account heuristic ("flag accounts with a suspicious win rate").
     Misses rings entirely, because each colluder's overall win rate looks normal.

NEW: graph analysis over the player-interaction graph. We build a weighted
     graph (edge weight = number of matches between two players), then find
     tightly-knit clusters whose members play each other vastly more than the
     global average. This is a transparent stand-in for a production GNN that
     would learn node embeddings; it surfaces the SAME relational structure and
     runs instantly with no training. (README shows where a real GNN slots in.)

Pure numpy + stdlib.
"""

import csv
import os
from collections import defaultdict
import numpy as np

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")


def load_edges():
    edges = []
    with open(os.path.join(DATA_DIR, "interactions.csv")) as f:
        for row in csv.DictReader(f):
            edges.append((row["player_a"], row["player_b"], row["winner"]))
    return edges


def load_truth_rings():
    members = set()
    with open(os.path.join(DATA_DIR, "rings_truth.csv")) as f:
        for row in csv.DictReader(f):
            members.add(row["member"])
    return members


def old_winrate_heuristic(edges):
    """Flag accounts whose win rate is abnormally high. Misses win-traders,
    whose wins are shared 50/50 inside the ring, so win rate looks ordinary."""
    wins = defaultdict(int)
    games = defaultdict(int)
    for a, b, w in edges:
        games[a] += 1
        games[b] += 1
        wins[w] += 1
    flagged = set()
    for p in games:
        if games[p] >= 5 and wins[p] / games[p] > 0.75:
            flagged.add(p)
    return flagged


def new_graph_rings(edges, repeat_factor=4):
    """Find clusters of players who play each other far more than average.

    Approach (transparent, GNN-free):
      1. Build weighted undirected graph: w(a,b) = #matches between a and b.
      2. Keep only 'strong' edges: pairs that played each other >= repeat_factor
         times the median pair-match count (the win-trading signature).
      3. Connected components over strong edges = candidate rings.
    """
    pair_w = defaultdict(int)
    for a, b, _ in edges:
        key = tuple(sorted((a, b)))
        pair_w[key] += 1

    counts = np.array(list(pair_w.values()))
    median = max(1, int(np.median(counts)))
    strong_threshold = repeat_factor * median

    # adjacency over strong edges only
    adj = defaultdict(set)
    for (a, b), w in pair_w.items():
        if w >= strong_threshold:
            adj[a].add(b)
            adj[b].add(a)

    # connected components
    seen = set()
    rings = []
    for node in adj:
        if node in seen:
            continue
        # BFS
        comp = []
        stack = [node]
        while stack:
            n = stack.pop()
            if n in seen:
                continue
            seen.add(n)
            comp.append(n)
            stack.extend(adj[n] - seen)
        if len(comp) >= 3:                 # a ring needs >=3 members
            rings.append(sorted(comp))
    return rings, strong_threshold, median


def main():
    edges = load_edges()
    truth = load_truth_rings()

    print("=" * 68)
    print("COLLUSION / WIN-TRADING DETECTION  —  OLD (per-account) vs NEW (graph)")
    print("=" * 68)
    print(f"Match interactions: {len(edges)} | true colluders: {len(truth)}\n")

    old = old_winrate_heuristic(edges)
    tp = len(old & truth)
    print("OLD  per-account win-rate heuristic")
    print(f"     flagged {len(old)} accounts; of the {len(truth)} real colluders, caught {tp}")
    print("     -> win-traders share wins 50/50, so their win rate looks normal. Missed.\n")

    rings, strong_thr, median = new_graph_rings(edges)
    caught = set()
    for r in rings:
        caught |= set(r)
    tp2 = len(caught & truth)
    fp2 = len(caught - truth)
    print("NEW  graph analysis over the interaction graph")
    print(f"     (median matches per pair={median}; 'strong' edge >= {strong_thr} matches)")
    print(f"     surfaced {len(rings)} rings, {len(caught)} members; "
          f"caught {tp2}/{len(truth)} colluders, {fp2} false members")
    print("\n  Rings surfaced (the structure the per-account view cannot see):")
    for i, r in enumerate(rings[:6]):
        tag = "all colluders" if set(r) <= truth else "MIXED/REVIEW"
        print(f"    ring {i}: {len(r)} members {r}   [{tag}]")
    if len(rings) > 6:
        print(f"    ... and {len(rings)-6} more")

    print("\n  Takeaway: the same data that hides colluders from per-account rules")
    print("  exposes the entire ring once you look at the RELATIONSHIPS. That is the")
    print("  step-change a GNN delivers — here shown with transparent graph analysis.")


if __name__ == "__main__":
    main()
