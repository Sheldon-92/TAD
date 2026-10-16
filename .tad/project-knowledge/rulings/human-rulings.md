# Human rulings (standing, this project)

## 2026-10-16 — A release's primary install path is exercised, not only declared untested
- Asked by Cora: "发版说明里自己写了『主要安装路径没测过』，这种版本以后还允许打 tag 吗？…我的建议是不允许：发版前必须真实跑一次下载安装，就像这次这样，成本很低。" (also: add release-archive contents to the review of a repository-only tracked-file change)
- The human: "同意"
- Reading recorded by Cora: before tagging, the release archive shape (`git archive` of the release commit) is installed end to end into a throwaway project; right after the tag is pushed, one real download install from GitHub is run; a release note may not ship "primary install path untested" as its only answer. A review of a change to repository-tracked files also checks what enters the release archive.
