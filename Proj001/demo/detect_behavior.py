"""
detect_behavior.py — OLD vs NEW cheat/bot detection on the same data.

OLD: fixed hand-tuned thresholds (the "rules engine" most studios start with).
NEW: unsupervised anomaly detection (Mahalanobis distance on standardized
     behavior features) — flags sessions that are far from the human norm,
     WITHOUT being told what a bot looks like, AND reports which feature drove
     the flag (the 'explain why' that makes a detection operational).

Both are scored against ground truth so the audience sees precision/recall
improve on screen. Pure numpy + stdlib: runs in <1s, no GPU, no installs.

Why these two: the OLD thresholds catch obvious bots but (a) miss bots that
tune just under the line and (b) emit no rationale. The NEW detector adapts to
the data's own distribution and ships a reason with every flag.
"""

import csv
import os
import numpy as np

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
FEATURES = ["accuracy", "actions_per_min", "reaction_ms_mean",
            "reaction_ms_std", "session_min", "headshot_ratio"]


def load():
    ids, X, y = [], [], []
    with open(os.path.join(DATA_DIR, "sessions.csv")) as f:
        for row in csv.DictReader(f):
            ids.append(row["player_id"])
            X.append([float(row[k]) for k in FEATURES])
            y.append(row["label"])
    return ids, np.array(X), np.array(y)


def prf(pred_pos, true_pos_set, ids):
    """precision / recall / f1 for a set of flagged ids vs the truth set."""
    flagged = set(ids[i] for i in np.where(pred_pos)[0])
    tp = len(flagged & true_pos_set)
    fp = len(flagged - true_pos_set)
    fn = len(true_pos_set - flagged)
    precision = tp / (tp + fp) if (tp + fp) else 0.0
    recall = tp / (tp + fn) if (tp + fn) else 0.0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0.0
    return precision, recall, f1, tp, fp, fn


def old_thresholds(X):
    """Hand-tuned rules. Deliberately reasonable-but-brittle, as in real life."""
    acc = X[:, 0]
    apm = X[:, 1]
    rt = X[:, 2]
    # "Ban if accuracy is very high OR input rate is very high OR reaction is superhuman."
    return (acc > 0.55) | (apm > 175) | (rt < 130)


def new_anomaly(X, contamination=0.09):
    """Robust anomaly score = sum of squared robust z-scores per feature.

    We center/scale each feature by its MEDIAN and MAD (median absolute
    deviation) rather than mean/std. Robust statistics resist the 'masking'
    effect where the cheat clusters inflate the variance and hide themselves.
    Each feature's robust z says how many MADs from the human norm a session is;
    summing the squares flags sessions that are jointly far across features —
    which is exactly the evasive-cheat signature (several stats each a bit off).

    Returns the per-session score, the most-deviating feature (the 'why'),
    and the robust-z matrix.
    """
    med = np.median(X, axis=0)
    mad = np.median(np.abs(X - med), axis=0) * 1.4826 + 1e-9   # ~std for normal data
    Z = (X - med) / mad
    score = np.sum(Z ** 2, axis=1)          # joint deviation across all features
    thresh = np.quantile(score, 1 - contamination)
    flagged = score >= thresh
    top_feat = np.argmax(np.abs(Z), axis=1)  # dominant reason per session
    return flagged, score, top_feat, Z


def main():
    ids, X, y = load()
    bots = set(ids[i] for i in range(len(ids)) if y[i] == "bot")
    evasive = set(ids[i] for i in range(len(ids)) if y[i] == "evasive")
    cheats = bots | evasive
    # NOTE: colluders are behaviorally normal — a behavioral detector SHOULD NOT
    # be expected to catch them. They are caught by the graph detector instead.

    print("=" * 68)
    print("BEHAVIORAL CHEAT/BOT DETECTION  —  OLD (rules) vs NEW (anomaly)")
    print("=" * 68)
    print(f"Population: {len(ids)} sessions | true cheats: {len(cheats)} "
          f"({len(bots)} blatant bots + {len(evasive)} evasive cheats)")
    print("Evasive cheats tune each stat JUST under the rule thresholds.")
    print("(Colluders are behaviorally normal by design — see graph detector.)\n")

    old = old_thresholds(X)
    p, r, f1, tp, fp, fn = prf(old, cheats, ids)
    old_flagged = set(ids[i] for i in np.where(old)[0])
    old_bot_caught = len(old_flagged & bots)
    old_eva_caught = len(old_flagged & evasive)
    print("OLD  fixed thresholds")
    print(f"     precision={p:.2f}  recall={r:.2f}  f1={f1:.2f}"
          f"   (caught {tp}, false alarms {fp}, missed {fn})")
    print(f"     breakdown: blatant bots {old_bot_caught}/{len(bots)} caught, "
          f"EVASIVE {old_eva_caught}/{len(evasive)} caught  <- the blind spot")

    new, d2, top_feat, Z = new_anomaly(X)
    p2, r2, f2, tp2, fp2, fn2 = prf(new, cheats, ids)
    new_flagged = set(ids[i] for i in np.where(new)[0])
    new_bot_caught = len(new_flagged & bots)
    new_eva_caught = len(new_flagged & evasive)
    print("\nNEW  unsupervised anomaly detection (+ reason per flag)")
    print(f"     precision={p2:.2f}  recall={r2:.2f}  f1={f2:.2f}"
          f"   (caught {tp2}, false alarms {fp2}, missed {fn2})")
    print(f"     breakdown: blatant bots {new_bot_caught}/{len(bots)} caught, "
          f"EVASIVE {new_eva_caught}/{len(evasive)} caught  <- the win")

    print("\n  Sample NEW detections WITH explanation (what a copilot would surface):")
    print("  -- the evasive cheats the rules engine cleared are the headline --")
    order = np.argsort(-d2)

    def show(i):
        feat = FEATURES[top_feat[i]]
        direction = "high" if Z[i, top_feat[i]] > 0 else "low"
        if ids[i] in evasive:
            verdict = "TRUE evasive cheat (rules MISSED)"
        elif ids[i] in bots:
            verdict = "TRUE bot"
        else:
            verdict = "review"
        print(f"    {ids[i]:>5}  score={d2[i]:6.1f}  reason: {feat} unusually {direction}"
              f"   [{verdict}]")

    # surface a few evasive catches first (the point), then a couple of bots
    eva_shown = [i for i in order if new[i] and ids[i] in evasive][:4]
    bot_shown = [i for i in order if new[i] and ids[i] in bots][:2]
    for i in eva_shown + bot_shown:
        show(i)

    print("\n  Takeaway: the rules engine catches blatant bots but is blind to cheats")
    print("  tuned just under each threshold, and gives no rationale. The anomaly")
    print("  detector flags them on the COMBINATION of features being off-distribution,")
    print("  and ships a 'why' with every flag — exactly what an analyst needs.")


if __name__ == "__main__":
    main()
