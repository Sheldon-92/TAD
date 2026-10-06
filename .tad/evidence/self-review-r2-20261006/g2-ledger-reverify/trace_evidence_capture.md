# trace_evidence_capture — C 类挂起（2026-10-06）
须鉴权会话实测（完整 turn 的 JSONL 捕获）。当次尝试同 context_compaction 件：exec --json 流确实产出结构化 JSONL（thread.started / turn.started / error / turn.failed 五件），但 turn 因配额失败（厂商原话 try again at Oct 10th, 2026 2:24 PM，2026-10-06T18:52Z 实测）——事件流格式获旁证、成功 turn 的证据捕获未测成 → 按停步点挂起：本条日期不动，旁证不充刷新依据。
