# Recovery Assertion

## H1

- Goal: Add `total(items)` to `totals.js`, and make `app.js` print the computed total `5` for `[ {price:2}, {price:3} ]` while existing tests pass.

## H2

- Handoff revision: `9b0b469283e106021deaeb0258291d84407ced550a0360eb168b2754ac0bd376`; base commit `4ba004a489c5c18846cf2852b6b57cb58ebdbc31`.

## H3

- Verified: `S1` / `SC-1` is verified by the ledger through the Conductor receipt.
- `S2` / `SC-2` is not verified.

## H4

- Unverified/in progress: `S2` remains pending; the journal records R-02 prepared for `app.js`.
- The permitted target currently contains `console.log('app');`.
- The journal records `totals.js` as dirty from verified S1 work; this is an observation only and must not be treated as new progress.

## H5

- Pending action: Execute only `S2` by updating `app.js` so it prints `total([ {price:2}, {price:3} ])`, then stop for verification.

## H6

- Blockers: No deterministic checks are declared. Verification still requires the Gate, independent review, and a distinct Conductor receipt; hidden acceptance and shell/agent execution are unavailable or prohibited.

## H7

- Legal next action: Modify only `app.js` under the R-02 S2 contract using the permitted Read/Edit/Write tools.

## H8

- Non-goals and forbidden scope: Do not redo verified S1, modify `totals.js` or `tests.js`, execute other slices, touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`, declare completion, or inspect hidden acceptance.

## S1

- The next action is legal because R-02 authorizes only S2, maps it to SC-2, allows only `app.js`, and permits Read/Edit/Write.

## S2

- S1 must not be redone because the ledger marks it verified with a Conductor receipt and the packet explicitly forbids redoing verified work.

## S3

- Blind retry or self-completion is unavailable because checkpoints are only candidates; verification advances only after Gate and independent review pass and a distinct Conductor writes the bound receipt.

## S4

- Rejected: any S1 or `totals.js` change, scope drift, forbidden-path change, shell or agent execution, hidden-acceptance inspection, self-verification, completion claim, or treating dirty worktree observations as progress.