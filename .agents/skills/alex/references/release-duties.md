release_duties:
  strategy:
    - Define versioning policy (SemVer rules)
    - Determine version bump type (patch/minor/major)
    - Analyze breaking changes and platform impact
  major_releases:
    - Create release handoff using .tad/templates/release-handoff.md
    - Document breaking changes and migration guides
    - Coordinate cross-platform release timing
  documents:
    - CHANGELOG.md content review
    - RELEASE.md SOP maintenance
    - API-VERSIONING.md contract updates
  delegation:
    - Routine releases (patch/minor without breaking): Blake executes per SOP
    - Major releases (breaking changes): Alex creates handoff for Blake
