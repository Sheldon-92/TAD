#!/usr/bin/env python3
# intent-route.py — deterministic pre-pass for the Alex Intent Router.
#
# CONTRACT
#   Implements steps 1, 1.5 and 2 of .agents/skills/alex/references/
#   intent-router-protocol.md mechanically, exactly as specified there:
#     step1   explicit-command bypass (*bug *discuss *idea *learn *express
#             *experiment *research *analyze)
#     step1.5 idle detection against the protocol's fixed zh/en word lists
#     step2   signal-word counting against .tad/config-workflow.yaml
#             (intent_modes.modes.*.signal_words), threshold and tie-break
#             from intent_modes.detection (signal_confidence_threshold,
#             priority_order), fallback = analyze.
#   Step 3 (user confirmation) and step 4 (routing) are NOT mechanized:
#   this script only produces the pre-selection + the step-3 candidate list.
#   It is an accelerator for a prose protocol, not a new gate: if it cannot
#   run, Alex applies steps 1-2 by reading, as before.
#
# COUNTING SEMANTICS (pinned here; the protocol says "count matches"):
#   A mode's count is the number of DISTINCT signal words of that mode
#   present in the input (zh + en lists combined). Repetition of the same
#   word does not inflate the count. A word containing CJK matches as a
#   substring; a pure-ASCII word matches case-insensitively on a word
#   boundary, allowing a trailing inflection suffix (s|es|ed|ing), so
#   "crashing" hits "crash" but "prefix" does not hit "fix".
#
# LEARNING FILTER (user-marked false positives):
#   Override files are consulted in order; see intent-overrides.yaml next
#   to this script for the format. Defaults: the shipped file beside this
#   script, then <repo>/.tad/intent-overrides.yaml if it exists.
#   force_routes (phrase -> mode) apply after idle, before counting;
#   suppress_words remove signal words from counting (per-mode or global).
#   Every applied override is reported in the output JSON.
#   REASON RULE (mechanically enforced): every override entry MUST carry
#   a non-empty reason; an entry with a missing/empty reason is rejected
#   at load time — skipped with a stderr warning and an
#   override_skipped_missing_reason note in the output JSON. It never
#   takes effect silently (P1 fix 2026-10-31; an unexplained override is
#   indistinguishable from tampering, so the rule is code, not convention).
#
# EXPRESS GUARD (AR-001): a mode flagged user_explicit_only in config
#   (express) can never be pre-selected; if counting or a force_route
#   lands on it, the result is analyze plus an explanatory note — the
#   protocol's step-3 "express is never Recommended" rule, enforced here.
#
# OUTPUT: one JSON object on stdout (fields documented in README section
#   of intent-router-protocol.md step2_mechanical). Exit 0 on a produced
#   classification; exit 2 on usage/config errors.
# DEPENDS: python3 + PyYAML. No network, no writes.

import argparse
import json
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.stderr.write("intent-route: PyYAML is required (python3 -m pip install pyyaml)\n")
    sys.exit(2)

EXPLICIT_COMMANDS = ["*bug", "*discuss", "*idea", "*learn", "*express",
                     "*experiment", "*research", "*analyze"]
IDLE_ZH = ["谢谢", "好的", "收到", "明白了", "嗯", "知道了", "没问题"]
IDLE_EN = ["thanks", "ok", "got it", "sure", "cool", "noted", "understood"]
IDLE_MAX_LEN = 24
INFLECT = r"(?:s|es|ed|ing)?"
PUNCT_RE = re.compile(r"[\s\.,!。，、；：？！·…~～\-—_、/\\'\"“”‘’（）()\[\]{}<>]+")

def has_cjk(s):
    return any('\u4e00' <= ch <= '\u9fff' for ch in s)

def word_present(word, text_lower):
    w = word.lower()
    if has_cjk(w):
        return w in text_lower
    pat = r"(?<![a-z0-9])" + re.escape(w) + INFLECT + r"(?![a-z0-9])"
    return re.search(pat, text_lower) is not None

def is_idle(text):
    # Normalize: lowercase, drop punctuation, collapse whitespace.
    norm = PUNCT_RE.sub(" ", text.lower()).strip()
    squashed = norm.replace(" ", "")
    if not squashed or len(squashed) > IDLE_MAX_LEN:
        return False
    phrases = sorted(IDLE_ZH + IDLE_EN, key=len, reverse=True)
    # Try to segment the squashed string fully into idle phrases.
    rest = squashed
    while rest:
        hit = None
        for ph in phrases:
            if rest.startswith(ph.replace(" ", "")):
                hit = ph.replace(" ", "")
                break
        if hit is None:
            return False
        rest = rest[len(hit):]
    return True

def _load_overrides_full(paths):
    force, suppress, applied_files, rejected = [], [], [], []
    for p in paths:
        if not p or not Path(p).exists():
            continue
        try:
            data = yaml.safe_load(Path(p).read_text(encoding="utf-8")) or {}
        except Exception as e:
            sys.stderr.write("intent-route: overrides %s unreadable: %s\n" % (p, e))
            continue
        applied_files.append(str(p))
        for fr in data.get("force_routes") or []:
            if isinstance(fr, dict) and fr.get("match") and fr.get("mode"):
                if fr.get("reason") is None or not str(fr.get("reason")).strip():
                    sys.stderr.write(
                        "intent-route: force_route in %s skipped: missing "
                        "reason (match=%r mode=%r)\n"
                        % (p, fr.get("match"), fr.get("mode")))
                    rejected.append({"type": "force_route",
                                     "match": fr.get("match"),
                                     "mode": fr.get("mode"),
                                     "file": str(p),
                                     "skipped": "missing reason"})
                    continue
                force.append(fr)
        for sw in data.get("suppress_words") or []:
            if isinstance(sw, dict) and sw.get("word"):
                if sw.get("reason") is None or not str(sw.get("reason")).strip():
                    sys.stderr.write(
                        "intent-route: suppress_word in %s skipped: missing "
                        "reason (word=%r mode=%r)\n"
                        % (p, sw.get("word"), sw.get("mode")))
                    rejected.append({"type": "suppress_word",
                                     "word": sw.get("word"),
                                     "mode": sw.get("mode"),
                                     "file": str(p),
                                     "skipped": "missing reason"})
                    continue
                suppress.append(sw)
    return force, suppress, applied_files, rejected

def load_overrides(paths):
    force, suppress, applied_files, _rejected = _load_overrides_full(paths)
    return force, suppress, applied_files

def classify(text, cfg, force_routes, suppress_words, rejected_overrides=()):
    modes = (cfg.get("intent_modes") or {}).get("modes") or {}
    detection = (cfg.get("intent_modes") or {}).get("detection") or {}
    threshold = detection.get("signal_confidence_threshold", 2)
    priority = detection.get("priority_order") or list(modes.keys())
    known_modes = set(modes.keys()) | {"research"}
    notes, applied = [], []
    for rj in rejected_overrides or ():
        key = rj.get("match") if rj.get("type") == "force_route" else rj.get("word")
        notes.append(
            "override_skipped_missing_reason: %s %r (mode=%r) from %s was "
            "NOT applied — every override entry must carry a reason"
            % (rj.get("type"), key, rj.get("mode"), rj.get("file")))

    def command_of(mode):
        if mode in modes and modes[mode].get("command"):
            return modes[mode]["command"]
        return "*" + mode

    def guard_explicit_only(mode, via):
        m = modes.get(mode) or {}
        if m.get("user_explicit_only"):
            notes.append(
                "express_never_recommended (AR-001): %s landed on %s, which is "
                "user-explicit-only; classified analyze per intent-router-"
                "protocol step3." % (via, mode))
            return "analyze"
        return mode

    stripped = text.lstrip()
    # step1: explicit command bypass (token must be followed by space/EOL/punct)
    for cmd in EXPLICIT_COMMANDS:
        if stripped.startswith(cmd):
            tail = stripped[len(cmd):len(cmd) + 1]
            if tail == "" or not (tail.isalnum() or tail == "_"):
                mode = cmd[1:]
                return {"route": "explicit", "mode": mode,
                        "command": command_of(mode), "counts": {},
                        "matched_words": {}, "threshold": threshold,
                        "candidates": [mode], "notes": notes,
                        "overrides_applied": applied}
    # step1.5: idle
    if is_idle(text):
        return {"route": "idle", "mode": None, "command": None,
                "counts": {}, "matched_words": {}, "threshold": threshold,
                "candidates": [], "notes": notes,
                "overrides_applied": applied}
    text_lower = text.lower()
    # learning filter: force routes
    for fr in force_routes:
        mode = str(fr["mode"])
        if mode not in known_modes:
            sys.stderr.write("intent-route: force_route to unknown mode %r skipped\n" % mode)
            continue
        if str(fr["match"]).lower() in text_lower:
            applied.append({"type": "force_route", "match": fr["match"],
                            "mode": mode, "reason": fr.get("reason", "")})
            mode = guard_explicit_only(mode, "force_route")
            return {"route": "force", "mode": mode,
                    "command": command_of(mode), "counts": {},
                    "matched_words": {}, "threshold": threshold,
                    "candidates": [mode], "notes": notes,
                    "overrides_applied": applied}
    # step2: signal-word counting with suppressions
    suppressed = {}
    for sw in suppress_words:
        suppressed.setdefault(str(sw["word"]).lower(), set()).add(
            str(sw.get("mode") or "*"))
    counts, matched = {}, {}
    for mode, m in modes.items():
        words, seen_words = [], set()
        sw_lists = (m.get("signal_words") or {})
        for lang in ("zh", "en"):
            for w in sw_lists.get(lang) or []:
                # The same surface word may be listed in both the zh and en
                # lists (e.g. "bug", "benchmark") — it is ONE signal word.
                if str(w).lower() not in seen_words:
                    seen_words.add(str(w).lower())
                    words.append(w)
        hits = []
        for w in words:
            wl = str(w).lower()
            sup = suppressed.get(wl)
            if sup and ("*" in sup or mode in sup):
                applied.append({"type": "suppress_word", "word": w,
                                "mode": mode})
                continue
            if word_present(str(w), text_lower):
                hits.append(w)
        counts[mode] = len(hits)
        matched[mode] = hits
    ranked = sorted(counts.items(),
                    key=lambda kv: (-kv[1],
                                    priority.index(kv[0]) if kv[0] in priority else 99))
    candidates = [m for m, c in ranked if c > 0][:3]
    top_mode, top_count = ranked[0] if ranked else ("analyze", 0)
    if top_count >= threshold:
        mode = guard_explicit_only(top_mode, "signal counting")
        route = "preselect"
    else:
        mode, route = "analyze", "fallback"
        if top_count > 0:
            notes.append("no mode reached threshold %d (top: %s=%d); "
                         "fallback analyze per detection.fallback_mode"
                         % (threshold, top_mode, top_count))
    return {"route": route, "mode": mode, "command": command_of(mode),
            "counts": counts, "matched_words": matched,
            "threshold": threshold, "candidates": candidates,
            "notes": notes, "overrides_applied": applied}

def main(argv=None):
    ap = argparse.ArgumentParser(description="Deterministic intent-router pre-pass")
    ap.add_argument("text", nargs="?", help="user input text (or use --stdin)")
    ap.add_argument("--stdin", action="store_true")
    ap.add_argument("--config", default=None)
    ap.add_argument("--overrides", action="append", default=None,
                    help="override YAML (repeatable); replaces default search")
    args = ap.parse_args(argv)

    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parents[2]
    cfg_path = Path(args.config) if args.config else repo_root / ".tad" / "config-workflow.yaml"
    if not cfg_path.exists():
        sys.stderr.write("intent-route: config not found: %s\n" % cfg_path)
        return 2
    try:
        cfg = yaml.safe_load(cfg_path.read_text(encoding="utf-8")) or {}
    except Exception as e:
        sys.stderr.write("intent-route: config parse failed: %s\n" % e)
        return 2
    if args.overrides is not None:
        override_paths = [Path(p) for p in args.overrides]
    else:
        override_paths = [script_dir / "intent-overrides.yaml",
                          repo_root / ".tad" / "intent-overrides.yaml"]
    force, suppress, _files, rejected = _load_overrides_full(override_paths)

    if args.stdin:
        text = sys.stdin.read()
    elif args.text is not None:
        text = args.text
    else:
        ap.print_usage(sys.stderr)
        return 2
    result = classify(text.strip(), cfg, force, suppress, rejected)
    result["input"] = text.strip()
    result["config"] = str(cfg_path)
    json.dump(result, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")
    return 0

if __name__ == "__main__":
    sys.exit(main())
