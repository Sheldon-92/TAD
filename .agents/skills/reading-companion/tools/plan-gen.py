#!/usr/bin/env python3
"""plan-gen.py — content.json -> plan.md (active-reading scaffold, not a TOC dump).

Produces, deterministically (stdlib only):
  - Structure map: chapter outline + first-paragraph gist + paragraph/word counts.
  - Reading path: suggested order, skippable chapters (very short ones), per-chapter
    estimated reading time (~230 wpm).
  - ## Questions: >=5 content-based questions ending in '?', of which >=2 are
    adversarial (using argue/refute/defend/论证/反驳) per the North Star: make the
    reader think MORE, not less (DESIGN-FINDINGS §1).

Questions are derived from actual paragraph CONTENT (key noun phrases / the book's
stated thesis sentences), not merely chapter titles.
"""
import argparse
import json
import re
import sys
from pathlib import Path

WPM = 230  # average adult reading speed


def words(text):
    r"""Count words, locale-aware (P2#9).

    A run of CJK characters has no spaces, so ``\w+`` counts it as one "word",
    badly under-counting and mis-flagging chapters as "skippable". Count each
    CJK codepoint as a word (typical for CJK reading-time estimates) and add the
    space-delimited Latin/other word count.
    """
    cjk = re.findall(r"[㐀-鿿豈-﫿぀-ヿ가-힯]", text)
    non_cjk = re.sub(r"[㐀-鿿豈-﫿぀-ヿ가-힯]", " ", text)
    latin = re.findall(r"[A-Za-z0-9_]+", non_cjk)
    return len(cjk) + len(latin)


def chapter_stats(ch):
    paras = ch.get("paragraphs", [])
    body = [p for p in paras if p.get("tag", "p") not in ("h1", "h2", "h3")]
    wc = sum(words(p["text"]) for p in paras)
    minutes = max(1, round(wc / WPM))
    gist = body[0]["text"] if body else (paras[0]["text"] if paras else "")
    return {"para_count": len(paras), "word_count": wc, "minutes": minutes, "gist": gist}


# --- key-phrase extraction (lightweight, deterministic) -----------------------
# Function words to exclude — articles, prepositions, conjunctions, pronouns,
# auxiliaries, adverbs. A leaked conjunction/adverb ("...claiming about because")
# is exactly the P1#7 defect, so this list is deliberately broad.
STOP = set("""a an the and or but if then else of to in on at by for with from as
is are was were be been being am this that these those it its it's their theirs
his her hers our ours your yours my mine we us you they them he she i do does did
done doing not no nor yes so such than too very can will would shall should could
may might must into onto over under about above below between among within without
across through during before after since until while because although though
unless whether however therefore thus hence moreover meanwhile otherwise instead
each any all both few more most other others some one two three first second
again once still just only even also yet ever never always often rarely soon
here there where when how why what which who whom whose
much many own same able like via per up down out off""".split())


def key_phrases(text, k=2):
    """Return up to k clean NOUN phrases from a paragraph (P1#7).

    Deliberately CONSERVATIVE: only emits **multi-word Capitalized sequences**
    (proper concepts, e.g. "Maps and Territory") because those are the only
    candidates that reliably read grammatically inside a question template
    without a real part-of-speech tagger. A frequency-based lowercase fallback
    was removed — it leaked verbs ("absorbs", "carries") into questions
    ("...claiming about absorbs"), the exact P1#7 defect.

    Returns [] when no clean Capitalized concept exists, so the caller falls
    back to an always-grammatical, chapter-title-based question instead of
    emitting a broken fragment. (Reviewer guidance: lean on the
    title/thesis/adversarial questions, which are reliably good.)
    """
    seen, phrases = [], []

    def add(p):
        key = p.lower()
        if key in seen or key in STOP or len(p) < 4:
            return
        seen.append(key)
        phrases.append(p)

    # Multi-word Capitalized sequences only, excluding the sentence-initial word
    # (capitalized only by position). Require at least TWO capitalized words.
    for m in re.finditer(r"(?<=[a-z,;:]\s)([A-Z][a-z]+(?:\s+(?:and\s+)?[A-Z][a-z]+)+)", text):
        cand = re.sub(r"\s+and$", "", m.group(1)).strip()
        if cand:
            add(cand)
        if len(phrases) >= k:
            break
    return phrases


def thesis_sentence(ch):
    """Find a sentence that looks like a claim/thesis in the chapter."""
    text = " ".join(p["text"] for p in ch.get("paragraphs", []) if p.get("tag") not in ("h1", "h2", "h3"))
    sents = re.split(r"(?<=[.!?])\s+", text)
    for s in sents:
        if re.search(r"\b(argues?|claims?|thesis|is that|must|should|because)\b", s, re.I) and 30 < len(s) < 240:
            return s.strip()
    return sents[0].strip() if sents and sents[0] else ""


def build_plan(content):
    title = content.get("title", "Untitled")
    chapters = content.get("chapters", [])
    lines = []
    lines.append("# Reading Plan — %s" % title)
    lines.append("")
    lines.append("> Active-reading scaffold. North star: make you think MORE, not less.")
    lines.append("> AI is a junior editor here — attempt your own answers first.")
    lines.append("")

    # --- Structure map ---
    lines.append("## Structure Map")
    lines.append("")
    total_min = 0
    stats = []
    for ch in chapters:
        s = chapter_stats(ch)
        stats.append((ch, s))
        total_min += s["minutes"]
        gist = s["gist"]
        if len(gist) > 160:
            gist = gist[:157].rstrip() + "..."
        lines.append("### %s" % ch.get("title", ch["chapter_id"]))
        lines.append("- **paragraphs:** %d · **words:** %d · **est. time:** ~%d min"
                     % (s["para_count"], s["word_count"], s["minutes"]))
        lines.append("- **gist:** %s" % gist)
        lines.append("")

    # --- Reading path ---
    lines.append("## Reading Path")
    lines.append("")
    lines.append("- **Total estimated reading time:** ~%d min" % total_min)
    lines.append("- **Suggested order:** read in spine order (%s)."
                 % " → ".join(ch.get("title", ch["chapter_id"]) for ch, _ in stats))
    skippable = [ch.get("title", ch["chapter_id"]) for ch, s in stats if s["word_count"] < 60]
    if skippable:
        lines.append("- **Skippable on a first pass (very short):** %s" % ", ".join(skippable))
    else:
        lines.append("- **Skippable on a first pass:** none — every chapter carries weight.")
    # P2#11: on equal minutes, break the tie by higher word_count (denser read),
    # not by first-encountered chapter.
    slowest = max(stats, key=lambda cs: (cs[1]["minutes"], cs[1]["word_count"]))
    lines.append("- **Read slowly:** the chapter with the longest est. time (%s)."
                 % slowest[0].get("title", "—"))
    lines.append("")

    # --- Questions (>=5, >=2 adversarial) ---
    lines.append("## Questions")
    lines.append("")
    questions = []
    adversarial = []

    for ch, _ in stats:
        ctitle = ch.get("title", ch["chapter_id"])
        # content-based key phrases from the first substantive paragraph
        body = [p for p in ch.get("paragraphs", []) if p.get("tag") not in ("h1", "h2", "h3")]
        kp = []
        for p in body[:2]:
            kp.extend(key_phrases(p["text"], 2))
        kp = [k for k in kp if k]
        thesis = thesis_sentence(ch)

        if kp:
            # clean noun phrase available -> content-anchored question
            questions.append('In "%s", what is the author really claiming about %s, and what evidence would change your mind?'
                             % (ctitle, kp[0]))
        else:
            # no clean phrase -> always-grammatical chapter-title question
            questions.append('What is the core claim of "%s", and what would it take to convince you it is wrong?'
                             % ctitle)
        if len(kp) > 1:
            questions.append('How does the idea of %s connect to %s — are they reinforcing or in tension?'
                             % (kp[0], kp[1]))
        elif kp:
            questions.append('Where does the idea of %s in "%s" hold up, and where does it break down?'
                             % (kp[0], ctitle))
        if thesis:
            # adversarial question grounded in the chapter's own thesis
            short = thesis.rstrip(".!?")
            if len(short) > 130:
                short = short[:127].rstrip() + "..."
            adversarial.append('How would you refute the claim that "%s" — and could you then defend it?'
                               % short)

    # ensure we always have >=2 adversarial even on tiny inputs
    if len(adversarial) < 2:
        for ch, _ in stats:
            ctitle = ch.get("title", ch["chapter_id"])
            adversarial.append('Argue against the central position of "%s": where is it weakest, and how would you refute it?' % ctitle)
            if len(adversarial) >= 2:
                break

    # de-dup while preserving order, then assemble: content qs first, then adversarial
    def dedup(seq):
        seen, out = set(), []
        for x in seq:
            if x not in seen:
                seen.add(x); out.append(x)
        return out

    questions = dedup(questions)
    adversarial = dedup(adversarial)[:max(2, len(adversarial))]

    final = questions + adversarial
    # guarantee >=5 total
    i = 0
    generic = [
        "What single idea from this book would you most want to argue with a friend, and why?",
        "Which claim here would be hardest to falsify, and does that make it stronger or weaker?",
        "If you had to teach this book in one question, what would it be?",
    ]
    while len(final) < 5 and i < len(generic):
        if generic[i] not in final:
            final.append(generic[i])
        i += 1

    for q in final:
        lines.append("- %s" % q)
    lines.append("")
    lines.append("*(Adversarial questions ask you to argue / refute / defend — that friction is the point.)*")
    lines.append("")
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser(description="content.json -> plan.md")
    ap.add_argument("content", help="path to content.json")
    ap.add_argument("-o", "--output", required=True, help="output plan.md path")
    args = ap.parse_args(argv)
    content = json.loads(Path(args.content).read_text(encoding="utf-8"))
    plan = build_plan(content)
    if args.output == "-":
        sys.stdout.write(plan)
    else:
        Path(args.output).write_text(plan, encoding="utf-8")
        sys.stderr.write("wrote %s\n" % args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
