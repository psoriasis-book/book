#!/usr/bin/env python3
import re
import sys
import unicodedata
from pathlib import Path

DOCS = Path("src/content/docs")
REF_FILE = DOCS / "A5-references.md"

CITE_RE = re.compile(r"\[\(([^\]]+)\)\]\((https?://[^)]+)\)")
YEAR_RE = re.compile(r"\b(?:19|20)\d{2}\b")
URL_RE = re.compile(r"\((https?://[^)]+)\)")
REF_WITH_JOURNAL_RE = re.compile(r"^(\d+)\.\s+(.+?)\.\s+\*[^*]+\*\.\s+(.+)$")
REF_FALLBACK_RE = re.compile(r"^(\d+)\.\s+(.+?)\.\s+(.+)$")

ALIAS = {
    "npf": "national",
    "nice": "national",
    "fda": "us",
    "who": "world",
    "bozek": "bozek",
    "bożek": "bozek",
}


def ascii_fold(s: str) -> str:
    return unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")


def normalize_author(author: str) -> str:
    author = author.replace(" et al.", "").strip()
    author = author.split(";")[0].strip()
    author = author.split("&")[0].strip()
    author = author.split(",")[0].strip()
    token = author.split()[0] if author else ""
    token = ascii_fold(token).lower().replace(".", "")
    return ALIAS.get(token, token)


def parse_ref_line(line: str):
    m = REF_WITH_JOURNAL_RE.match(line)
    if not m:
        m = REF_FALLBACK_RE.match(line)
    if not m:
        return None
    authors = m.group(2).strip()
    rest = m.group(3).strip()
    first = normalize_author(authors)
    year = None
    ym = YEAR_RE.search(rest)
    if ym:
        year = ym.group(0)
    urls = [u.rstrip("/") for u in URL_RE.findall(line)]
    if not urls:
        return None
    return first, year, urls


def main():
    ref_text = REF_FILE.read_text()
    ref_by_url = {}
    malformed = []
    for line_no, line in enumerate(ref_text.splitlines(), start=1):
        if "http" in line:
            for url in URL_RE.findall(line):
                if "..." in url or "…" in url:
                    malformed.append((str(REF_FILE), line_no, url))
        parsed = parse_ref_line(line)
        if not parsed:
            continue
        first, year, urls = parsed
        for u in urls:
            ref_by_url[u] = (first, year, line_no)

    missing = []
    mismatch = []
    for path in sorted(DOCS.glob("*.md")):
        if path.name == "A5-references.md":
            continue
        text = path.read_text()
        for m in CITE_RE.finditer(text):
            cite, url = m.group(1), m.group(2).rstrip("/")
            line_no = text.count("\n", 0, m.start()) + 1
            if "..." in url or "…" in url:
                malformed.append((str(path), line_no, url))
            if url not in ref_by_url:
                missing.append((str(path), line_no, cite, url))
                continue
            ref_author, ref_year, _ = ref_by_url[url]
            ym = re.search(r",\s*((?:19|20)\d{2})", cite)
            cite_year = ym.group(1) if ym else None
            cite_author = normalize_author(cite)
            if cite_author and ref_author and cite_author != ref_author:
                mismatch.append((str(path), line_no, cite, url, ref_author, ref_year))
                continue
            if cite_year and ref_year and cite_year != ref_year:
                mismatch.append((str(path), line_no, cite, url, ref_author, ref_year))

    ok = True
    if malformed:
        ok = False
        print("Malformed URLs:")
        for f, ln, u in malformed:
            print(f"  {f}:{ln} -> {u}")
    if missing:
        ok = False
        print("Missing references:")
        for f, ln, c, u in missing:
            print(f"  {f}:{ln} | ({c}) -> {u}")
    if mismatch:
        ok = False
        print("Author/year mismatches:")
        for f, ln, c, u, ra, ry in mismatch:
            print(f"  {f}:{ln} | ({c}) -> expected {ra}, {ry} | {u}")

    if not ok:
        sys.exit(1)
    print("Citation validation passed.")


if __name__ == "__main__":
    main()
