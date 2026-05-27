# Fixture: Photo-to-Beat-Sync Acceptance Scenario

## User Task

"我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。"

## Expected AI Agent Output Markers

When AI agent processes this task using the upgraded pack, the generated
prompt + plan MUST include:

1. **Intent classification**: explicit "montage" tag (Pattern 2 — Intent Router Rule)
2. **First/Last frame plan** per photo:
   - Each photo → "first_frame: <photo>, last_frame: <described>, motion: <described>"
   (Pattern 1 — Visual Decomposition Rule)
3. **View consistency check**: if same person across photos, note view selection
   (Pattern 3 — View-Specific Reference Rule)
4. **Scene cohesion**: if photos share location, camera-tree parent-child note
   (Pattern 4 — Camera Tree Rule)
5. **BPM target**: explicit BPM from audio-design.md (montage → 20-80 BPM emotional
   OR 110-130 BPM lofi modern)
6. **Cut timing**: 6s / 3 photos = 2s per photo, align cuts with BPM beat
   (audio-design BPM-to-cut formula)

## Marker-to-Quick-Rule-Index Mapping

| Fixture Marker | SKILL.md Quick Rule Index Entry |
|----------------|-------------------------------|
| Intent classification | Intent Router Rule |
| First/Last frame plan | Visual Decomposition Rule |
| View consistency check | View-Specific Reference Rule |
| Scene cohesion | Camera Tree Rule |
| BPM target | BPM-to-Video-Type (existing audio-design.md) |
| Cut timing | SFX Pre-Lead (existing audio-design.md) |

## Verification Method

Post-implementation, run a Task subagent with the same user task against the
upgraded pack. Capture the response and check for the 6 markers above.

AC15 verification command:
```bash
grep -ocE 'first.frame|last.frame|intent.+(narrative|motion|montage)|view-specific|camera.tree' \
  .tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/post-upgrade-output.md \
  | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Decision 6 Note

Pattern 3 (View-Specific Reference) may not trigger in the first Photo-to-Beat-Sync
scenario if the 3 photos contain 3 different people (no repeated character). This is
expected — Pattern 3 provides "future asset" value for multi-angle same-character
videos. Track whether Pattern 3 actually fires as a value signal.
