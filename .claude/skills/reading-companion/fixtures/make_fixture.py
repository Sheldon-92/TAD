#!/usr/bin/env python3
"""make_fixture.py — build a tiny hand-made sample EPUB (stdlib only).

Produces fixtures/sample.epub with:
  - mimetype (stored uncompressed, first entry — EPUB OCF requirement)
  - META-INF/container.xml
  - OEBPS/content.opf  (OPF in a subdir to exercise trap #2: href relative to OPF dir)
  - OEBPS/chap1.xhtml
  - OEBPS/chap2.xhtml  <- CONTAINS A DUPLICATED SENTENCE (for AC5 discrimination)

The duplicated sentence in chap2 appears twice in the SAME paragraph-set so that
re-attach must use prefix/suffix to land on the *2nd* occurrence, not the 1st.
"""
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "sample.epub"

CONTAINER = """<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
"""

OPF = """<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>The Tiny Reader Sample</dc:title>
    <dc:identifier id="bookid">urn:uuid:reading-companion-fixture-0001</dc:identifier>
    <dc:language>en</dc:language>
  </metadata>
  <manifest>
    <item id="ch1" href="chap1.xhtml" media-type="application/xhtml+xml"/>
    <item id="ch2" href="chap2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="ch1"/>
    <itemref idref="ch2"/>
  </spine>
</package>
"""

CHAP1 = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head><title>Chapter One</title></head>
<body>
  <h1>Chapter One: On Reading</h1>
  <p>Reading is not a passive act of consumption. The reader who merely absorbs
  words without resistance learns little, because comprehension is built through
  effort and friction rather than ease.</p>
  <p>A good reading surface should invite difficulty in measured doses. It should
  let the mind wander to the margins and back, holding a structure map in working
  memory while the eyes move forward.</p>
  <p>The argument of this book is that tools shape thought. Change how a person
  reads, and you change what they are able to think.</p>
</body>
</html>
"""

# chap2 contains the SAME sentence twice, separated by other text. AC5 highlights
# the 2nd occurrence; re-attach must use suffix context to disambiguate.
DUP = "The map is not the territory."
CHAP2 = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head><title>Chapter Two</title></head>
<body>
  <h1>Chapter Two: Maps and Territory</h1>
  <p>%(dup)s It is a phrase repeated so often that its meaning has worn smooth,
  yet it still carries weight when applied to how we model the world.</p>
  <p>Every representation discards something. A summary is a map of a book, and a
  highlight is a map of a thought. We must remember the cost of compression.</p>
  <p>And so we return to the warning once more. %(dup)s Hold that doubt close as
  you read the chapters that follow, and let it sharpen your attention.</p>
  <p>Consider this paragraph carefully. %(dup)s And once more, for emphasis and to
  test our anchoring: %(dup)s The second one is the one that matters here.</p>
</body>
</html>
""" % {"dup": DUP}


def build():
    # mimetype must be the first entry and stored uncompressed.
    with zipfile.ZipFile(OUT, "w") as zf:
        zi = zipfile.ZipInfo("mimetype")
        zi.compress_type = zipfile.ZIP_STORED
        zf.writestr(zi, "application/epub+zip")
        zf.writestr("META-INF/container.xml", CONTAINER, zipfile.ZIP_DEFLATED)
        zf.writestr("OEBPS/content.opf", OPF, zipfile.ZIP_DEFLATED)
        zf.writestr("OEBPS/chap1.xhtml", CHAP1, zipfile.ZIP_DEFLATED)
        zf.writestr("OEBPS/chap2.xhtml", CHAP2, zipfile.ZIP_DEFLATED)
    print("wrote", OUT)
    print("duplicated sentence (AC5):", repr(DUP))


if __name__ == "__main__":
    build()
