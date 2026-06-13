# Dataset Pipeline Review (CONTROL — generalist, NO pack)

Here's my review of your fine-tune dataset pipeline:

## 1. Instruction generation
Generating 50k instructions from your docs with a single model and high temperature is risky. Turning up the temperature does add variety, but it also raises the chance of low-quality or off-topic outputs. A better approach is to use a diverse set of seed prompts and varied instruction templates. You could also look at approaches like Self-Instruct or Evol-Instruct, which bootstrap and evolve instructions for more coverage. Consider filtering for redundancy — e.g. measure n-gram or ROUGE-L overlap and remove instructions that are too similar (a threshold around 0.7 is common). Using embeddings to cluster and prune near-duplicate prompts also helps.

## 2. Deduplication
Dropping only exact-duplicate rows is not enough. Exact matching misses paraphrases and reformatted text. Add a near-duplicate pass with MinHash + LSH to catch fuzzy duplicates. For semantic duplicates, embed the examples and use k-means or cosine-similarity clustering to remove redundant content. Deduplication reduces memorization and improves generalization.

## 3. Preference pairs
Hand-picking chosen/rejected pairs does not scale and introduces inconsistent labels. Instead, generate multiple candidate responses and score them with a reward model, then form preference pairs automatically. You can use DPO for training; if you have more than two candidates, ranking-based losses like RRHF work better, and for verifiable tasks GRPO is an option. Keep a small human-labeled set for validation.

## 4. Formatting and training
Training on raw JSON can break if you don't align to the model's chat template. Make sure you apply the correct chat template, mask the prompt tokens so loss is computed only on the response, and handle the EOS/pad tokens properly so you don't train on padding.

## 5. Benchmark reporting
Reporting accuracy on a public benchmark is risky because of data leakage / contamination. If benchmark examples leaked into your training or synthetic data, the score is inflated. Run a contamination check (n-gram overlap between training data and the eval set), and prefer held-out or fresh evaluation sets. Watch out for overfitting to the benchmark.

Overall: add diversity filtering, near-duplicate + semantic dedup, automated preference scoring, proper chat-template formatting, and a contamination check before you trust the benchmark number.
