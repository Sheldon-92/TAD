[P0] “To detect leaked data without access to the training corpus, use post-hoc statistical analysis. ConTAM defines four overlap metrics”
Why wrong: the listed TOKEN/NGRAM/LONGEST overlap metrics require a reference training/pretraining corpus or a proxy corpus to compare against. “Without access” contradicts the metric definition.
Fix: split methods: corpus-overlap methods require training-corpus access or a documented proxy; behavioral methods like CoDeC can be used when corpus access is unavailable.

[P0] “SWE-bench: Claude Opus 4.5 scored 80.9% on SWE-bench Verified … but dropped 35 percentage points to 45.9% on SWE-bench Pro”
Why wrong: this treats two different benchmark suites/harnesses as a controlled contaminated-vs-uncontaminated comparison. Scale’s SWE-bench Pro public board reports 45.89, but Anthropic’s own system card reports Opus 4.5 around 52.0 on SWE-bench Pro under its setup. The gap is not pure contamination inflation.
Fix: say SWE-bench Pro is a harder contamination-resistant benchmark, and report the exact evaluator/harness/date. Do not present the delta as causal contamination removal.

[P0] “n < 8 — for NGRAM-MATCH and LONGEST-MATCH, n-gram length below 8.”
Why wrong: this is an unsafe universal “optimal” setting. Short n-grams increase incidental-overlap false positives, directly conflicting with the stated purpose of LONGEST-MATCH to suppress short-match noise.
Fix: require a calibration sweep on clean/known-contaminated controls; report sensitivity by n, mincount, and skip budget instead of hard-coding `n < 8`.

[P0] “12× faster (≈270% runtime improvement)”
Why wrong: 12x faster and 270% runtime improvement are mathematically inconsistent. A 270% speedup is 3.7x throughput, while 12x faster is about 1100% faster or a 91.7% runtime reduction.
Fix: use one metric consistently: “12x faster” or “270% faster,” whichever the source actually supports.

[P0] “Use uint32 / Binary Vectors for MinHash Buckets … systems that natively support binary vectors and unsigned 32-bit integers (`uint32`) — e.g. Milvus / Zilliz Cloud”
Why wrong: Milvus supports scalar `INT32` and `BINARY_VECTOR`, but not a native `UINT32_VECTOR` type. Milvus MinHash output is a `BINARY_VECTOR` with dimensions equal to `32 * num_hashes`, and `MINHASH_LSH` uses `mh_element_bit_width=32`.
Fix: replace “uint32 / binary vectors” with “store MinHash signatures as `BINARY_VECTOR`; configure `MINHASH_LSH`/`MHJACCARD` with 32-bit MinHash elements.”

[P0] “without normalization, RRHF biases toward longer responses”
Why wrong: unnormalized summed log-probabilities usually penalize longer responses because log probabilities are negative and accumulate with length. The issue is length bias, typically toward shorter outputs, not longer.
Fix: say “without length normalization, RRHF scores are length-confounded, often favoring shorter responses; use average log-probability or another explicit length normalization.”

[P1] “Public benchmarks leak into training corpora at extreme rates — up to 90% of examples in datasets like SQuADv2 and DROP are flagged as contaminated.”
Why wrong: “up to 90%” is a very specific and alarming number, but the pack only cites an unavailable `findings.md`. It also risks implying all SQuADv2/DROP usage is 90% contaminated.
Fix: name the paper/tool, detection definition, corpus tested, and benchmark split. Phrase as “one study/tool reported up to X under Y definition.”

[P1] “Before reporting ANY benchmark number … run contamination detection against the eval set.”
Why wrong: overbroad. For private holdouts created after training cutoff, dynamic evals, or vendor-sealed benchmarks, contamination detection may be impossible or unnecessary; provenance controls may be stronger than post-hoc detection.
Fix: require either contamination detection or documented benchmark provenance/cutoff controls, with the residual risk stated.

[P1] “Reject a task if … it starts with punctuation or non-English characters.”
Why wrong: the pack advertises Chinese and multilingual dataset use, but this rule silently rejects valid non-English tasks.
Fix: make this target-language-aware: reject characters outside the declared target language/script, not all non-English starts.

[P1] “blacklisted keywords (e.g. image, graph, file — things the model cannot actually do)”
Why wrong: many current fine-tune targets are multimodal or tool-using and can handle images, graphs, and files through adapters/tools. The rule is only valid for text-only no-tool models.
Fix: condition the blacklist on target model capability and dataset scope.

[P1] “Output-First … generate the target label first, then an input conditioned on that label — this prevents the model from skewing toward majority labels.”
Why wrong: output-first prompting can reduce label imbalance, but “prevents” is too strong. It can still create unnatural inputs, label leakage, and template artifacts.
Fix: say it mitigates label bias and require post-generation class balance checks plus leakage checks.

[P1] “DPO is structurally limited to pairwise comparisons and lacks exploration. … For verifiable math/logic answers | GRPO”
Why wrong: GRPO is not just a preference-dataset curation choice; it generally requires on-policy sampled groups and a reward/verifier. The pack makes it sound like a drop-in replacement for curated preference pairs.
Fix: add caveat: use GRPO only when you can run on-policy generation and define a reliable reward/verifier; otherwise use DPO/IPO/KTO/RRHF-style offline objectives.

[P1] “Without `roles_to_train: ["assistant"]` you train gradients on the user’s turns too”
Why wrong: this depends on the trainer/data collator/template defaults. It is a real risk, but not guaranteed.
Fix: say “verify label masks; configure assistant-only training via `roles_to_train` or equivalent, and inspect token labels before training.”

[P1] “`map_eos_token` — maps EOS tokens to prevent training on pad tokens.”
Why wrong: Unsloth’s `map_eos_token` maps template end markers such as `<|im_end|>` to EOS. Preventing pad-token loss is a separate label masking / data collator / `pad_token_id` issue.
Fix: separate the concerns: use `map_eos_token` for template EOS alignment; verify padding labels are masked to `-100`.

[P1] “Axolotl | `pip install axolotl`”
Why wrong: official Axolotl installation commonly requires extras and `--no-build-isolation`/`uv` depending on CUDA/DeepSpeed/FlashAttention. The bare command is likely insufficient for the configs this pack recommends.
Fix: replace with an official install pointer or an environment-specific command, e.g. `uv pip install --no-build-isolation "axolotl[deepspeed]"` where appropriate.

[P1] “If you must use perplexity, note that model-free token-frequency statistics … match its quality while running up to 1000× faster.”
Why wrong: universal “match its quality” plus “1000x” is an unsupported generalization. It depends on corpus, scorer, downstream task, and compute setup.
Fix: phrase as a reported result under a named benchmark/setup; require local ablation before replacing PPL.

[P1] “Length | discard < 5 tokens or > 2000 tokens”
Why wrong: hard-rejecting documents over 2000 tokens is dangerous for pretraining corpora; long documents should often be segmented, not discarded.
Fix: reject very short/empty docs; for long docs, chunk by tokenizer/context policy and only discard pathological length outliers.

[P1] “Pick the selection method by its measured downstream score, not by intuition”
Why wrong: the table mixes token budgets, stages, benchmarks, and methods; choosing by headline average invites benchmark overfitting and bad transfer.
Fix: require matched-budget downstream ablations on the target domain, with held-out contamination-resistant evals.

[P1] “Generation needs an `ultrafeedback` judge step before human review”
Why wrong: this overfits to one distilabel-style workflow. Some pipelines should use task-specific validators, unit tests, rubric judges, or direct expert review instead of UltraFeedback.
Fix: require a judge/validator step appropriate to the task; UltraFeedback is one option for general instruction-response quality.

[P2] “Compatibility: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3”
Why wrong: this pack is being reviewed for Codex usage, but its metadata says Codex compatibility is future-phase. That creates activation ambiguity.
Fix: either mark Codex as supported or state which instructions are Claude-only and what Codex should ignore.

VERDICT: FIX-FIRST
