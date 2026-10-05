# FROZEN ORACLE — control (uninterrupted baseline)

The control run is never interrupted and produces no recovery assertion, so it
carries no hard/soft anchors and no recovery score. It exists only to establish
that the same frozen base commit and the same frozen input produce a completed,
Gate-passing result without any recovery machinery being exercised.
