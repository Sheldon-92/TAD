#!/usr/bin/env python3
"""
generate.py — Pure-function index generator for Local Wiki
Usage: python3 research/scripts/generate.py --emit all|index|clusters|ammo
- all: canon/_index.md + wiki/index.md + wiki/topics/_clusters.md
- index: canon/_index.md + wiki/index.md
- clusters: wiki/topics/_clusters.md
- ammo: alias for index (historical)
Idempotent: diff <(run1) <(run2) == 0
STDLIB only.
"""
import argparse
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CANON_DIR = REPO_ROOT / "research" / "canon"
WIKI_DIR = REPO_ROOT / "research" / "wiki"
TOPICS_YAML = CANON_DIR / "_topics.yaml"
CLUSTERS_YAML = CANON_DIR / "_clusters.yaml"

def parse_frontmatter(path: Path):
    """Minimal YAML frontmatter parser (stdlib only). Returns dict."""
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        return {}
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    # find second ---
    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return {}
    fm_lines = lines[1:end]
    data = {}
    current_key = None
    current_list = None
    for line in fm_lines:
        if not line.strip() or line.strip().startswith("#"):
            continue
        # list item
        m_list = re.match(r'^\s*-\s*(.*)$', line)
        if m_list and current_key:
            val = m_list.group(1).strip()
            # strip quotes
            if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                val = val[1:-1]
            if current_list is not None:
                current_list.append(val)
            else:
                # handle inline list? ignore
                pass
            continue
        # key: value
        m_kv = re.match(r'^([A-Za-z0-9_\-]+):\s*(.*)$', line)
        if m_kv:
            key = m_kv.group(1)
            val = m_kv.group(2).strip()
            # if value empty, next lines are list
            if val == "" or val == "[]":
                data[key] = []
                current_key = key
                current_list = data[key]
            else:
                # handle bracket list [a, b] ?
                if val.startswith("[") and val.endswith("]"):
                    inner = val[1:-1].strip()
                    if inner:
                        items = [x.strip().strip('"').strip("'") for x in inner.split(",")]
                        data[key] = items
                    else:
                        data[key] = []
                else:
                    # strip quotes
                    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                        val = val[1:-1]
                    # handle true/false
                    if val == "true":
                        val = True
                    elif val == "false":
                        val = False
                    data[key] = val
                current_key = key
                current_list = None if not isinstance(data.get(key), list) else data[key]
            continue
        # handle nested like raw_refs: - path: ... (complex) -> we need to detect
        # For raw_refs we count length via line counting
        m_nested = re.match(r'^\s*-\s*path:\s*(.*)$', line)
        if m_nested and current_key == "raw_refs":
            # count as item
            if current_list is not None:
                current_list.append(m_nested.group(1).strip())
            continue
    return data

def load_core_topics():
    core = set()
    if TOPICS_YAML.exists():
        fm = parse_frontmatter(TOPICS_YAML)  # not frontmatter but yaml
        # fallback manual parse for _topics.yaml (no frontmatter)
        try:
            text = TOPICS_YAML.read_text(encoding="utf-8")
        except:
            text = ""
        # extract core list
        in_core = False
        for line in text.splitlines():
            if line.strip().startswith("core:"):
                in_core = True
                # inline?
                m = re.match(r'core:\s*\[(.*)\]', line)
                if m:
                    inner = m.group(1)
                    for item in inner.split(","):
                        item = item.strip().strip('"').strip("'")
                        if item:
                            core.add(item)
                    in_core = False
                continue
            if in_core:
                m = re.match(r'\s*-\s*([A-Za-z0-9\-]+)', line)
                if m:
                    core.add(m.group(1))
                elif line.strip() and not line.strip().startswith("-"):
                    # end of list
                    if "allow_extend" in line:
                        in_core = False
        # also try to parse via simple
        if not core:
            # fallback: try to read via parse_frontmatter hack for _topics.yaml without ---
            for line in text.splitlines():
                m = re.match(r'\s*-\s*([A-Za-z0-9\-]+)', line)
                if m and "core" not in line:
                    # heuristic: if line is under core
                    pass
    return core

def find_canon_files():
    files = []
    for p in CANON_DIR.rglob("*.md"):
        if p.name in ("_index.md", "README.md", "_clusters.md"):
            continue
        if "_index" in p.name:
            continue
        # only entries under canon/{type}/{slug}.md with frontmatter
        if p.parent == CANON_DIR:
            continue  # skip top-level docs
        files.append(p)
    return sorted(files)

def find_wiki_files():
    files = []
    for p in WIKI_DIR.rglob("*.md"):
        if p.name in ("index.md", "_clusters.md", "log.md"):
            continue
        if p.name == "_index.md":
            continue
        files.append(p)
    return sorted(files)

def generate_canon_index():
    core = load_core_topics()
    canon_files = find_canon_files()
    lines = []
    lines.append("# Canon Index")
    lines.append("")
    lines.append(f"Total: {len(canon_files)} entries")
    lines.append("")
    lines.append("<!-- canon -->")
    lines.append("")
    lines.append("| Slug | Title | Type | Topics | Depth | Wiki | Verified |")
    lines.append("|------|-------|------|--------|-------|------|----------|")
    for f in canon_files:
        data = parse_frontmatter(f)
        rel = f.relative_to(REPO_ROOT)
        slug = f.stem
        title = data.get("title", slug)
        typ = data.get("type", "")
        topics = data.get("topics", data.get("explores", []))
        if isinstance(topics, str):
            topics = [topics]
        topics_str = ", ".join(topics) if isinstance(topics, list) else str(topics)
        # check unregistered
        unreg = []
        if isinstance(topics, list):
            for t in topics:
                if t not in core and t:
                    unreg.append(t)
        if unreg:
            topics_str += " ⚠️ unregistered"
        depth = data.get("depth", "")
        wiki = data.get("wiki_page", "")
        verified = data.get("verified_on", "")
        lines.append(f"| {slug} | {title} | {typ} | {topics_str} | {depth} | {wiki} | {verified} |")
    lines.append("")
    # Also list by topic
    lines.append("## By Topic")
    lines.append("")
    # group by topic
    topic_map = {}
    for f in canon_files:
        data = parse_frontmatter(f)
        topics = data.get("topics", data.get("explores", []))
        if isinstance(topics, str):
            topics = [topics]
        for t in topics or []:
            topic_map.setdefault(t, []).append(f.stem)
    for topic in sorted(topic_map.keys()):
        entries = ", ".join(sorted(topic_map[topic]))
        lines.append(f"- **{topic}**: {entries}")
    lines.append("")
    return "\n".join(lines) + "\n"

def generate_wiki_index():
    wiki_files = find_wiki_files()
    lines = []
    lines.append("# Wiki Index — Master Directory")
    lines.append("")
    lines.append(f"Total pages: {len(wiki_files)}")
    lines.append("")
    lines.append("| Page | Title | Topics | Canon | Raw Refs |")
    lines.append("|------|-------|--------|-------|----------|")
    for f in wiki_files:
        data = parse_frontmatter(f)
        rel = f.relative_to(REPO_ROOT)
        title = data.get("title", f.stem)
        topics = data.get("topics", [])
        if isinstance(topics, str):
            topics = [topics]
        topics_str = ", ".join(topics) if isinstance(topics, list) else str(topics)
        canon = data.get("source_canon", data.get("canonical_refs", ""))
        if isinstance(canon, list):
            canon = ", ".join(canon)
        # count raw_refs via file parse
        raw_len = 0
        try:
            text = f.read_text(encoding="utf-8")
            # crude count of raw_refs entries
            fm = parse_frontmatter(f)
            raw = fm.get("raw_refs", [])
            if isinstance(raw, list):
                raw_len = len(raw)
        except:
            raw_len = 0
        lines.append(f"| {rel} | {title} | {topics_str} | {canon} | {raw_len} |")
    lines.append("")
    # list canon reuse
    lines.append("## Reuse")
    lines.append("")
    lines.append("Tracks which raw sources are reused across canon/wiki.")
    lines.append("")
    return "\n".join(lines) + "\n"

def generate_clusters():
    if not CLUSTERS_YAML.exists():
        return None
    # simple parse: look for clusters
    text = CLUSTERS_YAML.read_text(encoding="utf-8")
    lines = []
    lines.append("# Topic Clusters")
    lines.append("")
    lines.append("Derived from `research/canon/_clusters.yaml`")
    lines.append("")
    # naive parse
    cur_name = None
    cur_topics = []
    for line in text.splitlines():
        m_name = re.match(r'\s*-\s*name:\s*(.*)', line)
        if m_name:
            if cur_name:
                lines.append(f"- **{cur_name}**: {', '.join(cur_topics)}")
            cur_name = m_name.group(1).strip().strip('"')
            cur_topics = []
            continue
        m_topics = re.match(r'\s*topics:\s*\[(.*)\]', line)
        if m_topics and cur_name:
            topics_str = m_topics.group(1)
            cur_topics = [t.strip().strip('"').strip("'") for t in topics_str.split(",") if t.strip()]
    if cur_name:
        lines.append(f"- **{cur_name}**: {', '.join(cur_topics)}")
    lines.append("")
    return "\n".join(lines) + "\n"

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--emit", choices=["all", "index", "clusters", "ammo"], default="all", help="what to emit")
    args = parser.parse_args()

    emit = args.emit
    if emit == "ammo":
        emit = "index"

    if emit in ("all", "index"):
        canon_index = generate_canon_index()
        wiki_index = generate_wiki_index()
        canon_out = CANON_DIR / "_index.md"
        wiki_out = WIKI_DIR / "index.md"
        canon_out.write_text(canon_index, encoding="utf-8")
        wiki_out.write_text(wiki_index, encoding="utf-8")
        print(f"wrote {canon_out.relative_to(REPO_ROOT)}", file=sys.stderr)
        print(f"wrote {wiki_out.relative_to(REPO_ROOT)}", file=sys.stderr)
        # Also emit canon index to stdout for handoff verify's diff check (stdout == file)
        sys.stdout.write(canon_index)

    if emit in ("all", "clusters"):
        clusters_content = generate_clusters()
        if clusters_content:
            clusters_out = WIKI_DIR / "topics" / "_clusters.md"
            clusters_out.parent.mkdir(parents=True, exist_ok=True)
            clusters_out.write_text(clusters_content, encoding="utf-8")
            print(f"wrote {clusters_out.relative_to(REPO_ROOT)}", file=sys.stderr)
        else:
            # if no clusters, ensure file not created? But spec says generate if present
            pass

if __name__ == "__main__":
    main()
