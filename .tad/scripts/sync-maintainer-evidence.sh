#!/usr/bin/env bash
# sync-maintainer-evidence.sh — maintainer-evidence 分支证据同步脚本
#
# TASK-20261004-EVIDENCE-CARRIER-RECOVERY-EXECUTION，HANDOFF §4.2 C3。
# 把执行版清单队列（class ∈ {no-carrier, stale-content} 且 outcome=pending）
# 逐件入 maintainer-evidence 分支，并按处置表点名弃置 drop 行。
#
# 机制：git plumbing + 临时索引（GIT_INDEX_FILE 指向 /tmp 下文件）：
#   read-tree 分支现尖 → hash-object -w 逐件写 blob → update-index 以
#   cacheinfo 批量形态（--index-info -z）更新索引条目、drop 行以零 sha
#   条目移除 → write-tree → commit-tree（父＝旧尖）→ update-ref 一次性
#   前移。不用朴素 add（两树整树被忽略，朴素路径会静默空转）；不检出
#   分支、不动工作树。删除只许由处置表逐件点名，不存在镜像删除；
#   处置表 decision=keep 的行与 gitlink 行是保护集，永不生成删除或
#   覆盖动作（gitlink 根本不入索引操作面）。
#
# 路径安全：全程 NUL 分隔 / argv 数组传参，不拼 shell 字符串路径。
#
# 输入（参数可覆盖）：
#   --manifest <path>     执行版清单（默认 <repo>/.tad/evidence/research/
#                         maintainer-evidence-revival/execution-manifest.jsonl）
#   --disposition <path>  处置表（默认同目录 branch-disposition.tsv）
#   --expect-base <sha>   期望基线尖；未给时默认断言当前尖为 Phase 0
#                         记录尖或其由本脚本产生的后继提交
#   --repo <path>         仓根（默认由脚本位置推导）
#
# 退出码：0=已同步（ref 已前移、清单已销账）／3=NO-OP（新树与旧尖树
# 相同，未产生提交；不是成功绿，调用方须如实记录）／1=同步失败
# （ref 未动、清单未改；已写 blob 为无害游离对象）／2=前置断言失败
# （仓根／基线尖／保护集冲突／载体冲突守卫命中，未做任何动作）。
#
# 载体冲突守卫（F1 增补）：队列行或处置表行命中「分支 gitlink 条目路径
# 前缀之下」或「路径含 .git 组件」两类，即在 read-tree 之前输出全部
# 命中路径清单并以退出码 2 停步——此类路径的内容由嵌入仓库自身 git
# 结构与分支 gitlink 指针承载，逐件入树会挤掉指针或被索引静默吞掉。
#
# 围栏声明（HANDOFF §4.6）：本脚本的 git 写操作只有 W1（hash-object -w
# 写 blob、临时索引操作）与 W2（update-ref 本分支）两类；不写任何其他
# ref、不写工作树跟踪文件、不落盘任何凭据。

set -u
export PYTHONDONTWRITEBYTECODE=1
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export TAD_REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

exec python3 - "$@" <<'PYEOF'
import argparse, csv, json, os, shutil, subprocess, sys, tempfile

BRANCH = 'maintainer-evidence'
REF = 'refs/heads/' + BRANCH
PHASE0_TIP = '8713ea4eb88b53f74f70f50477143a6fec05d22a'
MSG_MARK = 'sync-maintainer-evidence'
ZERO_SHA = '0' * 40
QUEUE_CLASSES = ('no-carrier', 'stale-content')


class Fail(Exception):
    def __init__(self, code, msg):
        super().__init__(msg)
        self.code = code
        self.msg = msg


def git(args, cwd, env=None, inp=None):
    r = subprocess.run(['git'] + args, cwd=cwd, env=env, input=inp,
                       capture_output=True)
    return r


def must(r, code, what):
    if r.returncode != 0:
        err = r.stderr.decode('utf-8', 'replace').strip()[:500]
        raise Fail(code, 'FAIL %s rc=%d stderr=%s' % (what, r.returncode, err))
    return r.stdout


def main(argv):
    ap = argparse.ArgumentParser(prog='sync-maintainer-evidence.sh')
    ap.add_argument('--manifest')
    ap.add_argument('--disposition')
    ap.add_argument('--expect-base')
    ap.add_argument('--repo')
    a = ap.parse_args(argv)

    repo = os.path.realpath(a.repo or os.environ['TAD_REPO_ROOT'])
    manifest_path = a.manifest or os.path.join(
        repo, '.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl')
    disposition_path = a.disposition or os.path.join(
        repo, '.tad/evidence/research/maintainer-evidence-revival/branch-disposition.tsv')

    # --- 前置自检 1：仓根断言 -------------------------------------------
    r = git(['rev-parse', '--show-toplevel'], cwd=repo)
    if r.returncode != 0:
        raise Fail(2, 'FAIL not a git repo at %s' % repo)
    top = os.path.realpath(r.stdout.decode('utf-8').strip())
    if top != repo:
        raise Fail(2, 'FAIL toplevel mismatch: %s != %s' % (top, repo))

    # --- 前置自检 2：分支尖期望基线断言 ---------------------------------
    tip = must(git(['rev-parse', BRANCH], cwd=repo), 2,
               'rev-parse branch').decode('utf-8').strip()
    if a.expect_base:
        if tip != a.expect_base:
            raise Fail(2, 'FAIL base mismatch: tip=%s expect-base=%s'
                       % (tip, a.expect_base))
    else:
        if tip != PHASE0_TIP:
            anc = git(['merge-base', '--is-ancestor', PHASE0_TIP, tip],
                      cwd=repo)
            ok = anc.returncode == 0
            if ok:
                out = must(git(['log', '--format=%s',
                                PHASE0_TIP + '..' + tip], cwd=repo), 2,
                           'log successor range').decode('utf-8')
                subjects = [s for s in out.splitlines() if s]
                ok = bool(subjects) and all(
                    s.startswith('chore(evidence): sync') and MSG_MARK in s
                    for s in subjects)
            if not ok:
                raise Fail(2, 'FAIL tip %s is neither Phase 0 tip nor a '
                           'successor produced by this script' % tip)

    # --- 读清单与处置表 --------------------------------------------------
    with open(manifest_path, encoding='utf-8') as f:
        rows = [json.loads(line) for line in f if line.strip()]
    with open(disposition_path, encoding='utf-8', newline='') as f:
        disp = list(csv.DictReader(f, delimiter='\t'))
    drop_paths = [d['path'] for d in disp if d['decision'] == 'drop']
    protect_paths = set(d['path'] for d in disp if d['decision'] == 'keep')

    queue = [r for r in rows
             if r['class'] in QUEUE_CLASSES and r.get('outcome') == 'pending']
    qpaths = [r['path'] for r in queue]
    clash = [p for p in qpaths if p in protect_paths or p in set(drop_paths)]
    if clash:
        raise Fail(2, 'FAIL queue paths clash with disposition: %s'
                   % clash[:5])

    # --- 载体冲突守卫（F1 增补，§4.2 C3） --------------------------------
    # read-tree 之前逐行扫描队列行与处置表行：命中 (i) 分支现尖任一 gitlink
    # 条目（mode 160000）路径前缀之下（前缀本体路径本身除外，归保护集）、
    # (ii) 路径任一组件为 .git —— 即输出全部命中路径并以退出码 2 停步，
    # 不许静默跳过、不许降级为警告续跑。
    raw = must(git(['ls-tree', '-r', '-z', tip], cwd=repo), 2,
               'ls-tree guard scan')
    gitlink_prefixes = []
    for e in raw.split(b'\0'):
        if b'\t' in e:
            meta, pb = e.split(b'\t', 1)
            parts = meta.decode('utf-8').split(' ')
            if parts[0] == '160000':
                gitlink_prefixes.append(pb.decode('utf-8'))

    def guard_hit(p):
        if any(c == '.git' for c in p.split('/')):
            return True
        return any(p.startswith(pf + '/') for pf in gitlink_prefixes)

    scan_paths = list(qpaths) + [d['path'] for d in disp]
    guard_hits = sorted({p for p in scan_paths if guard_hit(p)})
    if guard_hits:
        raise Fail(2, 'FAIL carrier-conflict guard: %d path(s) under a '
                   'gitlink prefix or with a .git component:\n%s'
                   % (len(guard_hits),
                      '\n'.join('GUARD-HIT ' + p for p in guard_hits)))

    # --- 存在性预扫（任何变更动作之前） ----------------------------------
    missing = []
    total_bytes = 0
    for p in qpaths:
        fp = os.path.join(repo, p)
        if not os.path.isfile(fp):
            missing.append(p)
        else:
            total_bytes += os.path.getsize(fp)
    if missing:
        raise Fail(1, 'FAIL %d queue files missing on disk, first: %s'
                   % (len(missing), missing[:5]))

    tmpdir = tempfile.mkdtemp(prefix='sync-me-idx-')
    try:
        env_idx = dict(os.environ)
        env_idx['GIT_INDEX_FILE'] = os.path.join(tmpdir, 'index')

        must(git(['read-tree', tip], cwd=repo, env=env_idx), 1, 'read-tree')
        base_tree = must(git(['rev-parse', tip + '^{tree}'], cwd=repo), 1,
                         'rev-parse base tree').decode('utf-8').strip()
        raw = must(git(['ls-tree', '-r', '-z', tip], cwd=repo), 1,
                   'ls-tree base')
        base_paths = set()
        for e in raw.split(b'\0'):
            if b'\t' in e:
                base_paths.add(e.split(b'\t', 1)[1].decode('utf-8'))

        # --- 逐件 hash-object -w（argv 分块） ----------------------------
        sha_map = {}
        mode_map = {}
        for i in range(0, len(queue), 200):
            chunk = queue[i:i + 200]
            paths = [r['path'] for r in chunk]
            out = must(git(['hash-object', '-w', '--'] + paths, cwd=repo),
                       1, 'hash-object chunk@%d' % i)
            shas = out.decode('utf-8').split()
            if len(shas) != len(paths):
                raise Fail(1, 'FAIL hash-object count mismatch at chunk %d'
                           % i)
            for r, s in zip(chunk, shas):
                p = r['path']
                sha_map[p] = s
                st = os.stat(os.path.join(repo, p))
                mode_map[p] = '100755' if (st.st_mode & 0o111) else '100644'

        # --- 索引更新：cacheinfo 条目（--index-info -z）+ drop 零 sha 条目 -
        entries = []
        for r in queue:
            p = r['path']
            entries.append('%s %s\t%s' % (mode_map[p], sha_map[p], p))
        dropped_applied = 0
        dropped_absent = 0
        for p in drop_paths:
            if p in base_paths:
                entries.append('0 %s\t%s' % (ZERO_SHA, p))
                dropped_applied += 1
            else:
                dropped_absent += 1
        data = ''.join(e + '\0' for e in entries).encode('utf-8')
        must(git(['update-index', '-z', '--index-info'], cwd=repo,
                 env=env_idx, inp=data), 1, 'update-index')

        new_tree = must(git(['write-tree'], cwd=repo, env=env_idx), 1,
                        'write-tree').decode('utf-8').strip()

        if new_tree == base_tree:
            print('RESULT=NO-OP')
            print('BASE=%s' % tip)
            print('QUEUE_PENDING=%d' % len(queue))
            print('DROPPED_APPLIED=0 DROPPED_ABSENT=%d' % dropped_absent)
            return 3

        msg = 'chore(evidence): sync %d evidence files to %s (%s)' % (
            len(queue), BRANCH, MSG_MARK)
        if dropped_applied:
            msg += '; drop %d by PM ruling' % dropped_applied
        new_commit = must(git(['commit-tree', new_tree, '-p', tip, '-m',
                               msg], cwd=repo), 1,
                          'commit-tree').decode('utf-8').strip()
        must(git(['update-ref', REF, new_commit, tip], cwd=repo), 1,
             'update-ref')

        # --- 清单销账（ref 前移成功后才改） ------------------------------
        drop_set = set(drop_paths)
        for r in rows:
            p = r['path']
            if r['class'] in QUEUE_CLASSES and r.get('outcome') == 'pending':
                r['outcome'] = 'synced'
                r['sha'] = sha_map[p]
                r['commit'] = new_commit
            elif r['class'] == 'branch-only':
                if p in drop_set:
                    r['outcome'] = 'dropped-by-ruling'
                    r['commit'] = new_commit
                elif p in protect_paths:
                    r['outcome'] = 'kept-branch-only'
        tmp_out = manifest_path + '.tmp-sync'
        with open(tmp_out, 'w', encoding='utf-8') as f:
            for r in rows:
                f.write(json.dumps(r, ensure_ascii=False) + '\n')
        os.replace(tmp_out, manifest_path)

        print('RESULT=SYNCED')
        print('BASE=%s' % tip)
        print('NEW_TIP=%s' % new_commit)
        print('SYNCED=%d' % len(queue))
        print('SYNC_BYTES=%d' % total_bytes)
        print('DROPPED_APPLIED=%d DROPPED_ABSENT=%d'
              % (dropped_applied, dropped_absent))
        return 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


try:
    sys.exit(main(sys.argv[1:]))
except Fail as e:
    print(e.msg, file=sys.stderr)
    sys.exit(e.code)
PYEOF
