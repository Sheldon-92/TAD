# Coverage Evidence

Command:

```bash
python3 -m trace --count --missing --summary --coverdir "$(mktemp -d)" \
  --module unittest research.tests.test_search
```

Result:

- `research.scripts.search`: 410 executable lines, **76.6% covered**
- `research.tests.test_search`: 130 executable lines, 99.2% covered
- tests: 14/14 PASS

`coverage.py` was not installed. Python stdlib `trace` is an equivalent line-coverage
measurement for this dependency-free CLI; branch coverage is not claimed.
