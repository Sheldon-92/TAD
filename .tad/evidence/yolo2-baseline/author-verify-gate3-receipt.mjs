import fs from 'fs'
import path from 'path'
import crypto from 'crypto'
import childProcess from 'child_process'

const ROOT = process.cwd()
const REVIEW_BASE = path.join(ROOT, '.tad/evidence/reviews/blake/yolo2-phase1')
const COMPLETION = path.join(ROOT, '.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-contract-baseline.md')

function terminal(kind, message) {
  process.stdout.write((message ? message + '\n' : '') + 'RESULT=' + kind + '\n')
  process.exit(kind === 'PASS' ? 0 : kind === 'FAIL' ? 1 : 2)
}

function read(file, label) {
  if (!fs.existsSync(file)) terminal('ERROR', 'E_MISSING ' + label)
  return fs.readFileSync(file)
}

function readJson(file, label) {
  try {
    return JSON.parse(read(file, label).toString('utf8'))
  } catch (error) {
    terminal('ERROR', 'E_JSON ' + label + ' ' + error.message)
  }
}

function sha(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex')
}

function carrierId(sessionId) {
  return sha(Buffer.from(sessionId, 'utf8'))
}

function containedReviewPath(relative, label) {
  if (path.isAbsolute(relative)) terminal('FAIL', 'E_SOURCE_ABSOLUTE ' + label)
  const resolved = path.resolve(ROOT, relative)
  const base = path.resolve(REVIEW_BASE)
  if (!resolved.startsWith(base + path.sep)) terminal('FAIL', 'E_SOURCE_ESCAPE ' + label)
  if (!fs.existsSync(resolved)) terminal('ERROR', 'E_MISSING ' + label)
  const root = path.resolve(ROOT)
  const segments = path.relative(root, resolved).split(path.sep)
  let cursor = root
  segments.forEach(function (segment) {
    cursor = path.join(cursor, segment)
    if (fs.lstatSync(cursor).isSymbolicLink()) terminal('FAIL', 'E_SOURCE_SYMLINK ' + label)
  })
  const realRoot = fs.realpathSync(root)
  const realBase = fs.realpathSync(base)
  const realResolved = fs.realpathSync(resolved)
  if (realBase !== realRoot && !realBase.startsWith(realRoot + path.sep)) terminal('FAIL', 'E_REVIEW_BASE_ESCAPE')
  if (!realResolved.startsWith(realBase + path.sep)) terminal('FAIL', 'E_SOURCE_REALPATH_ESCAPE ' + label)
  return resolved
}

function exactKeys(value, keys, label) {
  const actual = Object.keys(value).sort().join(',')
  const expected = keys.slice().sort().join(',')
  if (actual !== expected) terminal('FAIL', 'E_KEYS ' + label + ' actual=' + actual)
}

function execGit(args) {
  try {
    return childProcess.execFileSync('git', ['-C', ROOT].concat(args), { encoding: 'utf8' }).trim()
  } catch (error) {
    terminal('ERROR', 'E_GIT ' + args.join(' '))
  }
}

function field(text, name, label) {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const matches = text.match(new RegExp('^' + escaped + ': (.+)$', 'gm')) || []
  if (matches.length !== 1) terminal('FAIL', 'E_FIELD ' + label + ' ' + name)
  return matches[0].slice(name.length + 2)
}

const receiptPath = containedReviewPath('.tad/evidence/reviews/blake/yolo2-phase1/gate3-review-receipt.json', 'gate3-review-receipt.json')
const receipt = readJson(receiptPath, 'gate3-review-receipt.json')
const receiptKeys = [
  'schema_version', 'attestation_mode', 'executor_actor_id',
  'code_reviewer_actor_id', 'code_reviewer_session_id', 'code_reviewer_invocation_id',
  'code_reviewer_carrier_id', 'code_reviewer_source_path', 'code_reviewer_response_sha256', 'code_reviewer_output_sha256',
  'code_reviewer_verdict', 'code_reviewer_p0_count',
  'test_runner_actor_id', 'test_runner_session_id', 'test_runner_invocation_id',
  'test_runner_carrier_id', 'test_runner_source_dir', 'test_runner_verifier_sha256', 'test_runner_output_sha256',
  'test_runner_report_sha256', 'test_runner_verdict',
  'implementation_parent', 'implementation_commit', 'implementation_worktree',
  'assertion_manifest_sha256', 'direct_api_assertion_ids', 'negative_control_ids'
]
exactKeys(receipt, receiptKeys, 'receipt')
if (receipt.schema_version !== '1.0.0' || receipt.attestation_mode !== 'harness_observed') terminal('FAIL', 'E_RECEIPT_MODE')

const identityFields = [
  'executor_actor_id', 'code_reviewer_actor_id', 'code_reviewer_session_id', 'code_reviewer_invocation_id',
  'test_runner_actor_id', 'test_runner_session_id', 'test_runner_invocation_id'
]
identityFields.forEach(function (name) {
  if (typeof receipt[name] !== 'string' || receipt[name].length === 0) terminal('FAIL', 'E_IDENTITY ' + name)
})
if (receipt.code_reviewer_actor_id === receipt.executor_actor_id || receipt.test_runner_actor_id === receipt.executor_actor_id) terminal('FAIL', 'E_REVIEWER_IS_EXECUTOR')
if (receipt.code_reviewer_actor_id === receipt.test_runner_actor_id || receipt.code_reviewer_session_id === receipt.test_runner_session_id || receipt.code_reviewer_invocation_id === receipt.test_runner_invocation_id) terminal('FAIL', 'E_REVIEWERS_NOT_DISTINCT')
if (receipt.code_reviewer_verdict !== 'PASS' || receipt.code_reviewer_p0_count !== 0 || receipt.test_runner_verdict !== 'PASS') terminal('FAIL', 'E_REVIEW_VERDICT')

const directIds = ['baseline-15', 'compatibility-4', 'digest-10', 'grant-one-use', 'live-surface-120', 'mutations-3-importable', 'runtime-boundary-5', 'schemas-42-fresh', 'transitions-24-fresh']
const negativeIds = ['ambient-object-computed-constructor', 'comment-separated-dynamic-external', 'comment-separated-dynamic-untracked', 'comment-separated-external-import', 'constructor-dynamic-external', 'fs-default-alias-cp', 'fs-named-default-alias-cp', 'fs-namespace-alias-cp', 'fs-nested-destructure-cp', 'fs-nested-promises-cp', 'function-dynamic-external', 'function-dynamic-untracked', 'global-alias-computed-function', 'global-structuredclone', 'live-protected-file-byte', 'missing-fixture', 'objectpattern-computed-constructor-external', 'objectpattern-constructor-external', 'proto-computed-constructor-external', 'reflection-constructor-external', 'reflection-destructured-constructor-external', 'regexp-comment-camouflage-dynamic-external', 'template-comment-fs-cp', 'transition-oracle-flip', 'unsupported-schema-keyword', 'untracked-local-module']
if (!Array.isArray(receipt.direct_api_assertion_ids) || receipt.direct_api_assertion_ids.join('\n') !== directIds.join('\n')) terminal('FAIL', 'E_DIRECT_IDS')
if (!Array.isArray(receipt.negative_control_ids) || receipt.negative_control_ids.join('\n') !== negativeIds.join('\n')) terminal('FAIL', 'E_NEGATIVE_IDS')
const assertionJson = JSON.stringify({ direct_api_assertion_ids: directIds, negative_control_ids: negativeIds })
if (receipt.assertion_manifest_sha256 !== sha(Buffer.from(assertionJson, 'utf8'))) terminal('FAIL', 'E_ASSERTION_SHA')

const completionText = read(COMPLETION, 'completion').toString('utf8')
const completionParent = field(completionText, 'implementation_parent', 'completion')
const completionCommit = field(completionText, 'implementation_commit', 'completion')
const completionWorktree = field(completionText, 'implementation_worktree', 'completion')
if (receipt.implementation_parent !== completionParent || receipt.implementation_commit !== completionCommit || receipt.implementation_worktree !== completionWorktree) terminal('FAIL', 'E_COMPLETION_BINDING')
if (!/^[0-9a-f]{40}$/.test(receipt.implementation_parent) || !/^[0-9a-f]{40}$/.test(receipt.implementation_commit)) terminal('FAIL', 'E_COMMIT_FORMAT')
if (path.resolve(receipt.implementation_worktree) !== path.resolve(ROOT)) terminal('FAIL', 'E_WORKTREE_ROOT')
if (execGit(['rev-parse', 'HEAD']) !== receipt.implementation_commit) terminal('FAIL', 'E_HEAD_BINDING')
if (execGit(['rev-parse', receipt.implementation_commit + '^']) !== receipt.implementation_parent) terminal('FAIL', 'E_PARENT_BINDING')
if (execGit(['rev-list', '--parents', '-n', '1', receipt.implementation_commit]).split(/\s+/).length !== 2) terminal('FAIL', 'E_MERGE_COMMIT')
if (execGit(['diff', '--name-only']) !== '' || execGit(['diff', '--cached', '--name-only']) !== '') terminal('FAIL', 'E_TRACKED_DIRTY')

const expectedCodeCarrier = carrierId(receipt.code_reviewer_session_id)
const expectedTestCarrier = carrierId(receipt.test_runner_session_id)
if (receipt.code_reviewer_carrier_id !== expectedCodeCarrier || receipt.test_runner_carrier_id !== expectedTestCarrier) terminal('FAIL', 'E_CARRIER_ID')
const codeSourceExpected = '.tad/evidence/reviews/blake/yolo2-phase1/code-reviewer-' + expectedCodeCarrier + '/code-reviewer-response.md'
const testSourceExpected = '.tad/evidence/reviews/blake/yolo2-phase1/test-runner-' + expectedTestCarrier
if (receipt.code_reviewer_source_path !== codeSourceExpected || receipt.test_runner_source_dir !== testSourceExpected) terminal('FAIL', 'E_SOURCE_PATH')

const codeSource = read(containedReviewPath(codeSourceExpected, 'code-reviewer-source'), 'code-reviewer-source')
const codeOutput = read(containedReviewPath('.tad/evidence/reviews/blake/yolo2-phase1/code-reviewer.md', 'code-reviewer-output'), 'code-reviewer-output')
if (!codeSource.equals(codeOutput)) terminal('FAIL', 'E_CODE_NORMALIZATION')
if (sha(codeSource) !== receipt.code_reviewer_response_sha256 || sha(codeOutput) !== receipt.code_reviewer_output_sha256) terminal('FAIL', 'E_CODE_HASH')
const codeText = codeOutput.toString('utf8')
if (field(codeText, 'reviewer_actor_id', 'code-reviewer') !== receipt.code_reviewer_actor_id || field(codeText, 'reviewer_session_id', 'code-reviewer') !== receipt.code_reviewer_session_id || field(codeText, 'reviewer_invocation_id', 'code-reviewer') !== receipt.code_reviewer_invocation_id) terminal('FAIL', 'E_CODE_IDENTITY')
if (field(codeText, 'implementation_parent', 'code-reviewer') !== receipt.implementation_parent || field(codeText, 'implementation_commit', 'code-reviewer') !== receipt.implementation_commit || field(codeText, 'implementation_worktree', 'code-reviewer') !== receipt.implementation_worktree) terminal('FAIL', 'E_CODE_IMPLEMENTATION')
if (field(codeText, 'VERDICT', 'code-reviewer') !== 'PASS' || field(codeText, 'P0_COUNT', 'code-reviewer') !== '0') terminal('FAIL', 'E_CODE_RESULT')

const testSourceDir = containedReviewPath(testSourceExpected, 'test-runner-source')
const verifierSource = read(containedReviewPath(path.join(testSourceExpected, 'independent-api-verifier.mjs'), 'test-verifier-source'), 'test-verifier-source')
const outputSource = read(containedReviewPath(path.join(testSourceExpected, 'independent-api-verifier-output.txt'), 'test-output-source'), 'test-output-source')
const reportSource = read(containedReviewPath(path.join(testSourceExpected, 'test-runner.md'), 'test-report-source'), 'test-report-source')
const verifierOutput = read(containedReviewPath('.tad/evidence/reviews/blake/yolo2-phase1/independent-api-verifier.mjs', 'test-verifier-output'), 'test-verifier-output')
const outputOutput = read(containedReviewPath('.tad/evidence/reviews/blake/yolo2-phase1/independent-api-verifier-output.txt', 'test-output-output'), 'test-output-output')
const reportOutput = read(containedReviewPath('.tad/evidence/reviews/blake/yolo2-phase1/test-runner.md', 'test-report-output'), 'test-report-output')
if (!verifierSource.equals(verifierOutput) || !outputSource.equals(outputOutput) || !reportSource.equals(reportOutput)) terminal('FAIL', 'E_TEST_NORMALIZATION')
if (sha(verifierOutput) !== receipt.test_runner_verifier_sha256 || sha(outputOutput) !== receipt.test_runner_output_sha256 || sha(reportOutput) !== receipt.test_runner_report_sha256) terminal('FAIL', 'E_TEST_HASH')
const testText = reportOutput.toString('utf8')
if (field(testText, 'reviewer_actor_id', 'test-runner') !== receipt.test_runner_actor_id || field(testText, 'reviewer_session_id', 'test-runner') !== receipt.test_runner_session_id || field(testText, 'reviewer_invocation_id', 'test-runner') !== receipt.test_runner_invocation_id) terminal('FAIL', 'E_TEST_IDENTITY')
if (field(testText, 'implementation_parent', 'test-runner') !== receipt.implementation_parent || field(testText, 'implementation_commit', 'test-runner') !== receipt.implementation_commit || field(testText, 'implementation_worktree', 'test-runner') !== receipt.implementation_worktree) terminal('FAIL', 'E_TEST_IMPLEMENTATION')
if (field(testText, 'VERDICT', 'test-runner') !== 'PASS') terminal('FAIL', 'E_TEST_RESULT')
if (!outputOutput.toString('utf8').endsWith('RESULT=PASS\n')) terminal('FAIL', 'E_TEST_TERMINAL')

const thisFile = fs.readFileSync(new URL(import.meta.url))
process.stdout.write('RECEIPT_VERIFIER_SHA256=' + sha(thisFile) + '\n')
terminal('PASS')
