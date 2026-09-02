#!/usr/bin/env python3
"""Import a browser-exported Markdown clip into the immutable Local Wiki raw layer."""

from __future__ import annotations

import argparse
import datetime as dt
import os
import re
import secrets
import stat
import sys
from pathlib import Path, PurePosixPath
from urllib.parse import urlparse


MAX_BYTES = 5 * 1024 * 1024
ALLOWED_KEYS = {"title", "source_url", "saved_at", "summary", "keywords", "channel", "subtitle_language"}
REQUIRED_KEYS = {"title", "source_url", "saved_at"}
CONTROL_RE = re.compile(r"[\x00-\x1f\x7f]")
SLUG_RE = re.compile(r"[^a-z0-9]+")


class ImportError(ValueError):
    """A concise failure which leaves the raw corpus untouched."""


def _repo_root(value: str | None) -> Path:
    return Path(value).resolve() if value else Path(__file__).resolve().parents[2]


def _read_regular_nofollow(path: Path) -> str:
    try:
        fd = os.open(path, os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0))
    except OSError as exc:
        raise ImportError(f"cannot safely open input: {exc.strerror or exc}") from exc
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode):
            raise ImportError("input is not a regular file")
        if info.st_size > MAX_BYTES:
            raise ImportError("input exceeds 5 MiB")
        data = bytearray()
        while len(data) <= MAX_BYTES:
            part = os.read(fd, min(65536, MAX_BYTES + 1 - len(data)))
            if not part:
                break
            data.extend(part)
        if len(data) > MAX_BYTES:
            raise ImportError("input exceeds 5 MiB")
    finally:
        os.close(fd)
    try:
        return bytes(data).decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ImportError("input is not valid UTF-8") from exc


def _scalar(raw: str, *, key: str) -> str | None:
    raw = raw.strip()
    if raw == "null":
        return None
    if len(raw) < 2 or raw[0] not in "\"'" or raw[-1] != raw[0]:
        raise ImportError(f"{key} must be a quoted one-line string or null")
    value = raw[1:-1]
    if raw[0] == "\"":
        try:
            # The accepted export grammar only needs JSON-style double quoted strings.
            import json
            value = json.loads(raw)
        except Exception as exc:
            raise ImportError(f"invalid quoted {key}") from exc
    if not value or CONTROL_RE.search(value):
        raise ImportError(f"unsafe {key}")
    return value


def _keywords(raw: str) -> list[str] | None:
    raw = raw.strip()
    if raw == "null":
        return None
    if not (raw.startswith("[") and raw.endswith("]")):
        raise ImportError("keywords must be a bounded quoted-string list or null")
    inner = raw[1:-1].strip()
    if not inner:
        return []
    # Commas inside quoted entries are intentionally unsupported by the export contract.
    values = [_scalar(item.strip(), key="keywords") for item in inner.split(",")]
    if len(values) > 50 or any(value is None for value in values):
        raise ImportError("unsafe keywords")
    return [value for value in values if value is not None]


def _block_keywords(lines: list[str]) -> list[str]:
    if not lines or len(lines) > 50:
        raise ImportError("keywords must be a bounded quoted-string list")
    values: list[str] = []
    for line in lines:
        if not line.startswith("  - "):
            raise ImportError("unsupported keywords block structure")
        value = _scalar(line[4:], key="keywords")
        if value is None:
            raise ImportError("unsafe keywords")
        values.append(value)
    return values


def parse_clip(text: str) -> tuple[dict[str, object], str]:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    if not text.startswith("---\n"):
        raise ImportError("input must begin with frontmatter")
    end = text.find("\n---\n", 4)
    if end < 0 or end > 16384:
        raise ImportError("frontmatter must have a bounded closing delimiter")
    frontmatter = text[4:end]
    body = text[end + 5 :]
    if not body.strip():
        raise ImportError("input body is empty")
    parsed: dict[str, object] = {}
    lines = frontmatter.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        if not line or line[0].isspace() or ":" not in line:
            raise ImportError("unsupported frontmatter structure")
        key, raw = line.split(":", 1)
        if key not in ALLOWED_KEYS or key in parsed:
            raise ImportError(f"unsupported or duplicate frontmatter key: {key}")
        if any(token in raw for token in ("!", "&", "*", "|", ">")):
            raise ImportError("YAML tags, anchors, aliases, and block scalars are not allowed")
        if key == "keywords" and not raw.strip():
            index += 1
            block: list[str] = []
            while index < len(lines) and lines[index].startswith("  "):
                block.append(lines[index])
                index += 1
            parsed[key] = _block_keywords(block)
            continue
        parsed[key] = _keywords(raw) if key == "keywords" else _scalar(raw, key=key)
        index += 1
    missing = REQUIRED_KEYS - parsed.keys()
    if missing or any(not parsed[key] for key in REQUIRED_KEYS):
        raise ImportError("title, source_url, and saved_at are required")
    url = str(parsed["source_url"])
    pieces = urlparse(url)
    if pieces.scheme != "https" or not pieces.netloc or pieces.username or pieces.password:
        raise ImportError("source_url must be a credential-free HTTPS URL")
    try:
        dt.datetime.fromisoformat(str(parsed["saved_at"]).replace("Z", "+00:00"))
    except ValueError as exc:
        raise ImportError("saved_at must be ISO-8601 date/time") from exc
    return parsed, body


def _slug(title: str) -> str:
    value = SLUG_RE.sub("-", title.lower()).strip("-")[:72]
    return value or "browser-clip"


def _relative_output(value: str, repo_root: Path) -> Path:
    candidate = PurePosixPath(value)
    if candidate.is_absolute() or ".." in candidate.parts or candidate.suffix != ".md":
        raise ImportError("--out must be a safe repository-relative .md path")
    allowed = (PurePosixPath("research/raw/articles"), PurePosixPath("research/raw/transcripts"))
    if candidate.parent not in allowed or len(candidate.parts) != 4:
        raise ImportError("--out must be a direct child of raw/articles or raw/transcripts")
    return repo_root.joinpath(*candidate.parts)


def _is_youtube(url: str, body: str) -> bool:
    host = (urlparse(url).hostname or "").lower()
    return host in {"youtube.com", "www.youtube.com", "m.youtube.com", "youtu.be"} or bool(re.search(r"\*\*\[\d{1,2}:\d{2}(?::\d{2})?\]\*\*", body))


def _quote(value: str) -> str:
    import json
    return json.dumps(value, ensure_ascii=False)


def render_raw(meta: dict[str, object], body: str, transcript: bool) -> str:
    saved = str(meta["saved_at"])
    lines = [
        "---",
        f"original_url: {_quote(str(meta['source_url']))}",
        f"source_type: {'youtube_transcript' if transcript else 'rendered_page_export'}",
        f"medium: {'youtube' if transcript else 'web'}",
        f"slug: {_quote(_slug(str(meta['title'])))}",
        f"fetched_on: {saved[:10]}",
        f"title: {_quote(str(meta['title']))}",
    ]
    for key in ("summary", "channel", "subtitle_language"):
        value = meta.get(key)
        if value:
            lines.append(f"{key}: {_quote(str(value))}")
    keywords = meta.get("keywords")
    if keywords:
        lines.append("keywords: [" + ", ".join(_quote(str(value)) for value in keywords) + "]")
    lines.extend(["---", "", body.rstrip(), ""])
    return "\n".join(lines)


def _open_destination_dir(repo_root: Path, destination: Path) -> int:
    """Walk the fixed destination below root through no-follow directory descriptors."""
    try:
        root_fd = os.open(repo_root, os.O_RDONLY | os.O_DIRECTORY | getattr(os, "O_NOFOLLOW", 0))
    except OSError as exc:
        raise ImportError(f"cannot open repository root safely: {exc.strerror or exc}") from exc
    current_fd = root_fd
    try:
        for part in destination.relative_to(repo_root).parent.parts:
            next_fd = os.open(part, os.O_RDONLY | os.O_DIRECTORY | getattr(os, "O_NOFOLLOW", 0), dir_fd=current_fd)
            os.close(current_fd)
            current_fd = next_fd
        return current_fd
    except OSError as exc:
        os.close(current_fd)
        raise ImportError(f"unsafe or missing destination directory: {exc.strerror or exc}") from exc


def _safe_publish(repo_root: Path, destination: Path, content: bytes) -> Path:
    directory_fd = _open_destination_dir(repo_root, destination)
    stem, suffix = destination.stem, destination.suffix
    try:
        for index in range(1000):
            target_name = destination.name if index == 0 else f"{stem}-{index}{suffix}"
            temp_name = f".import-clip-{os.getpid()}-{secrets.token_hex(8)}"
            temp_fd = None
            try:
                temp_fd = os.open(temp_name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0), 0o600, dir_fd=directory_fd)
                written = 0
                while written < len(content):
                    count = os.write(temp_fd, content[written:])
                    if not isinstance(count, int) or count <= 0:
                        raise ImportError("short write while publishing clip")
                    written += count
                os.fsync(temp_fd)
                os.close(temp_fd)
                temp_fd = None
                os.link(temp_name, target_name, src_dir_fd=directory_fd, dst_dir_fd=directory_fd, follow_symlinks=False)
                os.unlink(temp_name, dir_fd=directory_fd)
                os.fsync(directory_fd)
                return destination.with_name(target_name)
            except FileExistsError:
                continue
            finally:
                if temp_fd is not None:
                    os.close(temp_fd)
                try:
                    os.unlink(temp_name, dir_fd=directory_fd)
                except FileNotFoundError:
                    pass
    finally:
        os.close(directory_fd)
    raise ImportError("could not allocate a unique output filename")


def import_clip(input_path: Path, repo_root: Path, requested_out: str | None, dry_run: bool) -> Path:
    meta, body = parse_clip(_read_regular_nofollow(input_path))
    transcript = _is_youtube(str(meta["source_url"]), body)
    default = f"research/raw/{'transcripts' if transcript else 'articles'}/{_slug(str(meta['title']))}.md"
    destination = _relative_output(requested_out or default, repo_root)
    if dry_run:
        return destination
    return _safe_publish(repo_root, destination, render_raw(meta, body, transcript).encode("utf-8"))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--repo-root")
    parser.add_argument("--out")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)
    try:
        result = import_clip(args.input, _repo_root(args.repo_root), args.out, args.dry_run)
    except ImportError as exc:
        print(f"import-clip: {exc}", file=sys.stderr)
        return 2
    print(result.relative_to(_repo_root(args.repo_root)).as_posix())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
