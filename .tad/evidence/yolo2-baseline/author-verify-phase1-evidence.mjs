import fs from 'fs'
import path from 'path'
import crypto from 'crypto'
import { fileURLToPath } from 'url'
import childProcess from 'child_process'
import { createRequire } from 'module'

const ROOT = process.cwd()
const BASE = path.join(ROOT, '.tad/evidence/yolo2-baseline')

function terminal(kind, message) {
  process.stdout.write((message ? message + '\n' : '') + 'RESULT=' + kind + '\n')
  process.exit(kind === 'PASS' ? 0 : kind === 'FAIL' ? 1 : 2)
}

function readJson(name) {
  const file = path.join(BASE, name)
  if (!fs.existsSync(file)) terminal('ERROR', 'E_EVIDENCE_MISSING ' + name)
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'))
  } catch (error) {
    terminal('ERROR', 'E_EVIDENCE_JSON ' + name + ' ' + error.message)
  }
}

function readJsonl(name) {
  const file = path.join(BASE, name)
  if (!fs.existsSync(file)) terminal('ERROR', 'E_EVIDENCE_MISSING ' + name)
  const text = fs.readFileSync(file, 'utf8')
  if (!text.endsWith('\n')) terminal('FAIL', 'E_EVIDENCE_NEWLINE ' + name)
  const lines = text.split('\n').filter(Boolean)
  return lines.map(function (line, index) {
    try {
      return JSON.parse(line)
    } catch (error) {
      terminal('ERROR', 'E_EVIDENCE_JSONL ' + name + ':' + (index + 1))
    }
  })
}

function exactKeys(value, keys, label) {
  const actual = Object.keys(value).sort().join(',')
  const expected = keys.slice().sort().join(',')
  if (actual !== expected) terminal('FAIL', 'E_KEYS ' + label + ' actual=' + actual)
}

function exactIdSet(rows, expected, label) {
  const ids = rows.map(function (row) { return row.case_id }).sort()
  const want = expected.slice().sort()
  if (new Set(ids).size !== ids.length) terminal('FAIL', 'E_DUPLICATE_ID ' + label)
  if (ids.join('\n') !== want.join('\n')) terminal('FAIL', 'E_ID_SET ' + label)
}

const kinds = ['contract', 'event', 'state', 'round', 'audit', 'capabilities']
const invalidShapes = {
  'missing-required': 'E_REQUIRED',
  'wrong-type': 'E_TYPE',
  'unknown-version': 'E_ENUM',
  'bad-path': 'E_FORMAT',
  'bad-enum': 'E_ENUM',
  'unknown-field': 'E_ADDITIONAL_PROPERTY'
}

const schemaEvidence = readJson('phase1-schema-results.txt')
exactKeys(schemaEvidence, ['schema_version', 'results'], 'schema-root')
if (schemaEvidence.schema_version !== '1.0.0' || !Array.isArray(schemaEvidence.results)) terminal('FAIL', 'E_SCHEMA_EVIDENCE_ROOT')
const schemaIds = []
kinds.forEach(function (kind) {
  schemaIds.push(kind + '/valid')
  Object.keys(invalidShapes).forEach(function (shape) { schemaIds.push(kind + '/' + shape) })
})
exactIdSet(schemaEvidence.results, schemaIds, 'schema')
schemaEvidence.results.forEach(function (row) {
  exactKeys(row, ['case_id', 'outcome', 'code', 'instance_path'], 'schema-row:' + row.case_id)
  const parts = row.case_id.split('/')
  if (parts[1] === 'valid') {
    if (row.outcome !== 'accepted' || row.code !== null || row.instance_path !== '') terminal('FAIL', 'E_SCHEMA_VALID ' + row.case_id)
  } else {
    if (row.outcome !== 'rejected' || row.code !== invalidShapes[parts[1]]) terminal('FAIL', 'E_SCHEMA_INVALID ' + row.case_id)
    if (typeof row.instance_path !== 'string' || row.instance_path.length === 0) terminal('FAIL', 'E_SCHEMA_PATH ' + row.case_id)
  }
})

const transitionExpected = {
  happy_path: 'complete',
  executor_claim_only: 'not_complete',
  completion_only: 'not_complete',
  layer1_false: 'not_complete',
  required_test_failed: 'not_complete',
  one_auditor: 'not_complete',
  unregistered_auditor: 'not_complete',
  executor_actor_audit: 'not_complete',
  executor_session_audit: 'not_complete',
  executor_role_audit: 'not_complete',
  stale_audit: 'not_complete',
  candidate_digest_mismatch: 'not_complete',
  snapshot_digest_mismatch: 'not_complete',
  contract_digest_mismatch: 'contract_changed',
  cache_replay_mismatch: 'corrupt',
  capability_not_strict: 'honest_partial',
  executor_issued_grant: 'not_complete',
  audit_before_grant: 'not_complete',
  grant_candidate_mismatch: 'not_complete',
  grant_snapshot_mismatch: 'not_complete',
  grant_contract_mismatch: 'contract_changed',
  reused_grant: 'not_complete',
  grant_invocation_mismatch: 'not_complete',
  grant_session_mismatch: 'not_complete'
}
const transitionEvidence = readJson('phase1-transition-results.txt')
exactKeys(transitionEvidence, ['schema_version', 'results'], 'transition-root')
if (transitionEvidence.schema_version !== '1.0.0') terminal('FAIL', 'E_TRANSITION_EVIDENCE_VERSION')
exactIdSet(transitionEvidence.results, Object.keys(transitionExpected), 'transition')
transitionEvidence.results.forEach(function (row) {
  exactKeys(row, ['case_id', 'classification', 'terminal_state', 'error_code'], 'transition-row:' + row.case_id)
  if (row.classification !== transitionExpected[row.case_id]) terminal('FAIL', 'E_TRANSITION_CLASS ' + row.case_id)
  if (row.case_id === 'happy_path' && row.terminal_state !== 'complete') terminal('FAIL', 'E_HAPPY_PATH')
  if (row.case_id !== 'happy_path' && row.terminal_state === 'complete') terminal('FAIL', 'E_FALSE_COMPLETE ' + row.case_id)
})

const digestComponents = [
  'epic_id', 'phase_id', 'handoff', 'ac_manifest', 'allowed_paths',
  'required_checks', 'risk_level', 'authority_policy', 'capability_mode', 'schema_versions'
]
const digestEvidence = readJson('phase1-digest-results.txt')
exactKeys(digestEvidence, ['schema_version', 'mutations'], 'digest-root')
if (digestEvidence.schema_version !== '1.0.0') terminal('FAIL', 'E_DIGEST_EVIDENCE_VERSION')
exactIdSet(digestEvidence.mutations.map(function (row) {
  return { case_id: row.component }
}), digestComponents, 'digest')
digestEvidence.mutations.forEach(function (row) {
  exactKeys(row, ['component', 'digest_changed', 'old_round_state'], 'digest-row:' + row.component)
  if (row.digest_changed !== true || row.old_round_state !== 'contract_changed') terminal('FAIL', 'E_DIGEST ' + row.component)
})

const mutationExpected = ['AUDIT_AUTHORITY', 'EVIDENCE_BINDING', 'REPLAY_CONSISTENCY']
const mutationCaseIds = {
  AUDIT_AUTHORITY: ['audit_before_grant', 'executor_issued_grant', 'grant_candidate_mismatch', 'reused_grant'],
  EVIDENCE_BINDING: ['candidate_digest_mismatch', 'snapshot_digest_mismatch'],
  REPLAY_CONSISTENCY: ['cache_replay_mismatch']
}
const mutationEvidence = readJson('phase1-mutation-results.txt')
exactKeys(mutationEvidence, ['schema_version', 'original_suite_result', 'original_sha256_before', 'original_sha256_after', 'mutants'], 'mutation-root')
if (mutationEvidence.schema_version !== '1.0.0') terminal('FAIL', 'E_MUTATION_EVIDENCE_VERSION')
if (mutationEvidence.original_suite_result !== 'PASS') terminal('FAIL', 'E_MUTATION_ORIGINAL_SUITE')
if (mutationEvidence.original_sha256_before !== mutationEvidence.original_sha256_after) terminal('FAIL', 'E_ORIGINAL_CHANGED')
exactIdSet(mutationEvidence.mutants.map(function (row) {
  return { case_id: row.mutant_id }
}), mutationExpected, 'mutation')
mutationEvidence.mutants.forEach(function (row) {
  exactKeys(row, ['mutant_id', 'import_ok', 'executed_case_ids', 'case_results', 'unsafe_outcomes', 'killed'], 'mutation-row:' + row.mutant_id)
  const expectedIds = mutationCaseIds[row.mutant_id]
  if (!Array.isArray(row.executed_case_ids) || row.executed_case_ids.join('\n') !== expectedIds.join('\n')) terminal('FAIL', 'E_MUTATION_CASE_IDS ' + row.mutant_id)
  if (!Array.isArray(row.case_results)) terminal('FAIL', 'E_MUTATION_CASE_RESULTS ' + row.mutant_id)
  exactIdSet(row.case_results, expectedIds, 'mutation-cases:' + row.mutant_id)
  let observedUnsafe = 0
  row.case_results.forEach(function (caseRow) {
    exactKeys(caseRow, ['case_id', 'original_classification', 'mutant_classification'], 'mutation-case:' + row.mutant_id + ':' + caseRow.case_id)
    if (caseRow.original_classification !== transitionExpected[caseRow.case_id] || caseRow.original_classification === 'complete') terminal('FAIL', 'E_MUTATION_ORIGINAL_CLASS ' + caseRow.case_id)
    if (caseRow.mutant_classification === 'complete') observedUnsafe += 1
  })
  if (row.import_ok !== true || row.unsafe_outcomes !== observedUnsafe || observedUnsafe < 1 || row.killed !== true) terminal('FAIL', 'E_MUTANT_SURVIVED ' + row.mutant_id)
})

const compatibilityFiles = [
  '.tad/workflows/yolo/schema-validator.mjs',
  '.tad/workflows/yolo/reference-model.mjs',
  '.tad/tests/yolo2/run-phase1.mjs',
  '.tad/tests/yolo2/baseline-v1.mjs'
]
const allowedBareImports = new Set(['fs', 'fs/promises', 'path', 'crypto', 'url', 'os', 'perf_hooks', 'vm'])
const allowedModuleRoots = ['.tad/workflows/yolo/', '.tad/tests/yolo2/']

function git(args, encoding) {
  try {
    return childProcess.execFileSync('git', ['-C', ROOT].concat(args), {
      encoding: encoding === undefined ? 'utf8' : encoding,
      maxBuffer: 16 * 1024 * 1024
    })
  } catch (error) {
    terminal('FAIL', 'E_GIT_TREE ' + args.join(' '))
  }
}

const implementationHead = git(['rev-parse', 'HEAD']).trim()
if (!/^[0-9a-f]{40}$/.test(implementationHead)) terminal('FAIL', 'E_IMPLEMENTATION_HEAD')
if (!process.execArgv.includes('--disallow-code-generation-from-strings')) terminal('FAIL', 'E_CODEGEN_FLAG')

const require = createRequire(import.meta.url)
let acornParse
try {
  const resolvedAcorn = require.resolve('acorn')
  const expectedAcorn = path.join(ROOT, 'node_modules/acorn/dist/acorn.js')
  const realRoot = fs.realpathSync(ROOT)
  const realAcorn = fs.realpathSync(resolvedAcorn)
  if (path.resolve(resolvedAcorn) !== path.resolve(expectedAcorn)) terminal('FAIL', 'E_ACORN_RESOLUTION')
  if (realAcorn !== path.join(realRoot, 'node_modules/acorn/dist/acorn.js')) terminal('FAIL', 'E_ACORN_REALPATH')
  const acornPackage = path.join(realRoot, 'node_modules/acorn/package.json')
  const acornJsSha = crypto.createHash('sha256').update(fs.readFileSync(realAcorn)).digest('hex')
  const acornPackageSha = crypto.createHash('sha256').update(fs.readFileSync(acornPackage)).digest('hex')
  if (acornJsSha !== 'fc3ed7b81e58464715d0291402892f22c3d86ea75302645a330390f85d8015c9') terminal('FAIL', 'E_ACORN_BYTES')
  if (acornPackageSha !== '5c1ed7259579a7899b303f514b0194adcb9fe474fc7d136a84c6a45f10eefc84') terminal('FAIL', 'E_ACORN_PACKAGE_BYTES')
  acornParse = require(resolvedAcorn).parse
} catch (error) {
  terminal('ERROR', 'E_ACORN_MISSING')
}

function canonical(value) {
  if (Array.isArray(value)) return '[' + value.map(canonical).join(',') + ']'
  if (value && typeof value === 'object') {
    return '{' + Object.keys(value).sort().map(function (key) {
      return JSON.stringify(key) + ':' + canonical(value[key])
    }).join(',') + '}'
  }
  return JSON.stringify(value)
}

function literalString(node) {
  return node && node.type === 'Literal' && typeof node.value === 'string' ? node.value : null
}

function memberName(node) {
  if (!node || node.type !== 'MemberExpression') return null
  if (!node.computed && node.property.type === 'Identifier') return node.property.name
  return literalString(node.property)
}

function tokenText(source, tokens, start, end) {
  return tokens
    .filter(function (token) { return token.start >= start && token.end <= end && token.type.label !== 'eof' })
    .map(function (token) { return source.slice(token.start, token.end) })
    .join(' ')
}

function walkAst(node, visit) {
  if (!node || typeof node !== 'object') return
  if (typeof node.type === 'string') visit(node)
  Object.keys(node).forEach(function (key) {
    if (key === 'loc' || key === 'start' || key === 'end') return
    const value = node[key]
    if (Array.isArray(value)) value.forEach(function (entry) { walkAst(entry, visit) })
    else if (value && typeof value === 'object') walkAst(value, visit)
  })
}

function assertCommittedModule(file) {
  const relative = path.relative(ROOT, file).split(path.sep).join('/')
  if (relative.startsWith('../') || path.isAbsolute(relative)) terminal('FAIL', 'E_IMPORT_OUTSIDE_ROOT ' + relative)
  if (!allowedModuleRoots.some(function (root) { return relative.startsWith(root) })) terminal('FAIL', 'E_IMPORT_OUTSIDE_MODULE_ROOTS ' + relative)
  let committed
  try {
    committed = childProcess.execFileSync('git', ['-C', ROOT, 'show', implementationHead + ':' + relative], {
      encoding: null,
      maxBuffer: 16 * 1024 * 1024,
      stdio: ['ignore', 'pipe', 'ignore']
    })
  } catch (error) {
    terminal('FAIL', 'E_IMPORT_NOT_COMMITTED ' + relative)
  }
  const current = fs.readFileSync(file)
  if (!current.equals(committed)) terminal('FAIL', 'E_IMPORT_BLOB_MISMATCH ' + relative)
  return relative
}

function resolveLocalImport(fromFile, specifier) {
  let resolved
  if (specifier.startsWith('file:')) {
    try {
      resolved = fileURLToPath(specifier)
    } catch (error) {
      terminal('FAIL', 'E_IMPORT_FILE_URL ' + fromFile + ' ' + specifier)
    }
  } else {
    resolved = path.resolve(path.dirname(fromFile), specifier)
  }
  const normalizedRoot = path.resolve(ROOT)
  const normalized = path.resolve(resolved)
  if (normalized !== normalizedRoot && !normalized.startsWith(normalizedRoot + path.sep)) terminal('FAIL', 'E_IMPORT_OUTSIDE_ROOT ' + fromFile + ' ' + specifier)
  if (!fs.existsSync(normalized) || !fs.statSync(normalized).isFile()) terminal('FAIL', 'E_IMPORT_LOCAL_MISSING ' + fromFile + ' ' + specifier)
  return normalized
}

function scanModuleGraph(entryFile, seen) {
  const file = path.resolve(entryFile)
  if (seen.has(file)) return
  seen.add(file)
  if (!fs.existsSync(file)) terminal('ERROR', 'E_COMPATIBILITY_FILE_MISSING ' + path.relative(ROOT, file))
  const source = fs.readFileSync(file, 'utf8')
  const relativeFile = assertCommittedModule(file)
  const tokens = []
  let ast
  try {
    ast = acornParse(source, { ecmaVersion: 2020, sourceType: 'module', allowHashBang: true, onToken: tokens })
  } catch (error) {
    terminal('FAIL', 'E_ACORN_PARSE ' + relativeFile + ' ' + error.message)
  }
  const normalizedTokens = tokenText(source, tokens, 0, source.length)
  const localSpecifiers = []
  let vmImportCount = 0
  let createContextCount = 0
  let scriptConstructionCount = 0
  let runInContextCount = 0

  walkAst(ast, function (node) {
    if (node.type === 'ImportDeclaration' && literalString(node.source) === 'vm') {
      if (relativeFile !== '.tad/tests/yolo2/baseline-v1.mjs') terminal('FAIL', 'E_VM_IMPORT_PATH ' + relativeFile)
      const bindings = node.specifiers.map(function (entry) {
        if (entry.type !== 'ImportSpecifier') return ''
        return entry.imported.name + ':' + entry.local.name
      }).sort()
      if (bindings.join('\n') !== ['Script:Script', 'createContext:createContext'].join('\n')) terminal('FAIL', 'E_VM_IMPORT_BINDINGS ' + relativeFile)
      vmImportCount += 1
    }
    if (node.type === 'CallExpression' && node.callee.type === 'Identifier' && node.callee.name === 'createContext') {
      if (relativeFile !== '.tad/tests/yolo2/baseline-v1.mjs' || tokenText(source, tokens, node.start, node.end) !== 'createContext ( contextSeed , { codeGeneration : { strings : false , wasm : false } } )') terminal('FAIL', 'E_VM_CONTEXT ' + relativeFile)
      createContextCount += 1
    }
    if (node.type === 'NewExpression' && node.callee.type === 'Identifier' && node.callee.name === 'Script') {
      if (relativeFile !== '.tad/tests/yolo2/baseline-v1.mjs' || tokenText(source, tokens, node.start, node.end) !== "new Script ( wrappedSource , { filename : 'yolo-epic.workflow.js' } )") terminal('FAIL', 'E_VM_SCRIPT ' + relativeFile)
      scriptConstructionCount += 1
    }
    if (node.type === 'CallExpression' && node.callee.type === 'MemberExpression' && memberName(node.callee) === 'runInContext') {
      if (relativeFile !== '.tad/tests/yolo2/baseline-v1.mjs' || tokenText(source, tokens, node.start, node.end) !== 'script . runInContext ( context )') terminal('FAIL', 'E_VM_RUN ' + relativeFile)
      runInContextCount += 1
    }
  })
  if (relativeFile === '.tad/tests/yolo2/baseline-v1.mjs') {
    if (vmImportCount !== 1 || createContextCount !== 1 || scriptConstructionCount !== 1 || runInContextCount !== 1) terminal('FAIL', 'E_VM_BOUNDARY_COUNT ' + relativeFile)
    const requiredWrapperTokens = [
      "const workflowSource = readFileSync ( workflowSourcePath , 'utf8' )",
      "const exportToken = 'export const meta ='",
      "const replacementToken = 'const meta ='",
      'const replacementCount = workflowSource . split ( exportToken ) . length - 1',
      "if ( ! workflowSource . startsWith ( exportToken ) || replacementCount !== 1 ) throw new Error ( 'E_WORKFLOW_TRANSFORM' )",
      'const transformedSource = replacementToken + workflowSource . slice ( exportToken . length )',
      "const wrappedSource = '(async () => {\\n' + transformedSource + '\\n})()'",
      'const contextSeed = Object . assign ( Object . create ( null ) , { agent , parallel , args , log , phase } )',
      'const context = createContext ( contextSeed , { codeGeneration : { strings : false , wasm : false } } )',
      "const script = new Script ( wrappedSource , { filename : 'yolo-epic.workflow.js' } )",
      'const workflowPromise = script . runInContext ( context )'
    ]
    requiredWrapperTokens.forEach(function (required) {
      if (!normalizedTokens.includes(required)) terminal('FAIL', 'E_VM_BOUNDARY_GUARD ' + relativeFile)
    })
  } else if (vmImportCount !== 0 || createContextCount !== 0 || scriptConstructionCount !== 0 || runInContextCount !== 0) {
    terminal('FAIL', 'E_VM_BOUNDARY_PATH ' + relativeFile)
  }

  function recordSpecifier(specifier, dynamic) {
    if (specifier.startsWith('node:')) terminal('FAIL', 'E_NODE_PREFIX ' + relativeFile)
    if (specifier.startsWith('./') || specifier.startsWith('../') || specifier.startsWith('file:')) localSpecifiers.push(specifier)
    else if (dynamic) terminal('FAIL', 'E_DYNAMIC_EXTERNAL_IMPORT ' + relativeFile + ' ' + specifier)
    else if (!allowedBareImports.has(specifier)) terminal('FAIL', 'E_EXTERNAL_IMPORT ' + relativeFile + ' ' + specifier)
  }

  walkAst(ast, function (node) {
    if (node.type === 'Identifier') {
      if (node.name === 'require') terminal('FAIL', 'E_REQUIRE ' + relativeFile)
      if (node.name === 'eval' || node.name === 'Function' || node.name === 'AsyncFunction' || node.name === 'structuredClone' || node.name === 'Reflect' || node.name === 'globalThis' || node.name === 'global') terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
    }
    if (node.type === 'ObjectPattern') {
      node.properties.forEach(function (property) {
        if (property.type === 'RestElement') return
        if (property.computed) terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
        const key = property.key.type === 'Identifier' ? property.key.name : literalString(property.key)
        if (key === 'constructor' || key === 'eval' || key === 'Function' || key === 'AsyncFunction' || key === 'Reflect' || key === 'structuredClone' || key === 'getPrototypeOf' || key === 'getOwnPropertyDescriptor' || key === 'getOwnPropertyDescriptors' || key === 'getOwnPropertyNames' || key === 'getOwnPropertySymbols' || key === '__lookupGetter__' || key === '__lookupSetter__') terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
      })
    }
    if (node.type === 'MemberExpression') {
      const property = memberName(node)
      if (property === 'constructor') terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
      if (property === 'getPrototypeOf' || property === 'getOwnPropertyDescriptor' || property === 'getOwnPropertyDescriptors' || property === 'getOwnPropertyNames' || property === 'getOwnPropertySymbols' || property === '__lookupGetter__' || property === '__lookupSetter__') terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
      if (property === 'eval' || property === 'Function' || property === 'AsyncFunction' || property === 'structuredClone') terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
      if (property === 'at') terminal('FAIL', 'E_ARRAY_AT ' + relativeFile)
    }
    if (node.type === 'ImportDeclaration' || node.type === 'ExportAllDeclaration' || (node.type === 'ExportNamedDeclaration' && node.source)) {
      const specifier = literalString(node.source)
      if (specifier === null) terminal('FAIL', 'E_IMPORT_NON_LITERAL ' + relativeFile)
      recordSpecifier(specifier, false)
      if (node.type === 'ImportDeclaration' && (specifier === 'fs' || specifier === 'fs/promises')) {
        node.specifiers.forEach(function (entry) {
          if (entry.type === 'ImportDefaultSpecifier' || entry.type === 'ImportNamespaceSpecifier' || (entry.type === 'ImportSpecifier' && (entry.imported.name === 'default' || entry.imported.name === 'promises'))) terminal('FAIL', 'E_FS_OBJECT_IMPORT ' + relativeFile)
          if (entry.type === 'ImportSpecifier' && (entry.imported.name === 'cp' || entry.imported.name === 'cpSync')) terminal('FAIL', 'E_FS_CP_IMPORT ' + relativeFile)
        })
      }
    }
    if (node.type === 'ImportExpression') {
      const specifier = literalString(node.source)
      if (specifier !== null) recordSpecifier(specifier, true)
      else {
        const canonical = tokenText(source, tokens, node.start, node.end)
        if (relativeFile !== '.tad/tests/yolo2/run-phase1.mjs') terminal('FAIL', 'E_DYNAMIC_IMPORT_ALLOWLIST_PATH ' + relativeFile)
        if (canonical !== 'import ( pathToFileURL ( mutantPath ) . href )') terminal('FAIL', 'E_DYNAMIC_IMPORT_COMPUTED ' + relativeFile)
        const tempRoot = "const mutationRoot = mkdtempSync ( path . join ( os . tmpdir ( ) , 'tad-yolo2-mutation-' ) )"
        const containment = "if ( ! path . resolve ( mutantPath ) . startsWith ( path . resolve ( mutationRoot ) + path . sep ) ) throw new Error ( 'E_MUTANT_PATH' )"
        if (!normalizedTokens.includes(tempRoot) || !normalizedTokens.includes(containment)) terminal('FAIL', 'E_DYNAMIC_IMPORT_ALLOWLIST_GUARD ' + relativeFile)
      }
    }
    if (node.type === 'CallExpression') {
      if (node.callee.type === 'Identifier' && node.callee.name === 'require') terminal('FAIL', 'E_REQUIRE ' + relativeFile)
      if (node.callee.type === 'Identifier' && (node.callee.name === 'eval' || node.callee.name === 'Function' || node.callee.name === 'AsyncFunction')) terminal('FAIL', 'E_DYNAMIC_CODE ' + relativeFile)
    }
  })

  localSpecifiers.forEach(function (specifier) {
    scanModuleGraph(resolveLocalImport(file, specifier), seen)
  })
}

function verifyDependencySurface() {
  const packagePath = path.join(ROOT, 'package.json')
  const lockPath = path.join(ROOT, 'package-lock.json')
  const packageSource = fs.readFileSync(packagePath)
  const lockSource = fs.readFileSync(lockPath)
  const committedPackage = git(['show', implementationHead + ':package.json'], null)
  const committedLock = git(['show', implementationHead + ':package-lock.json'], null)
  if (!packageSource.equals(committedPackage) || !lockSource.equals(committedLock)) terminal('FAIL', 'E_DEPENDENCY_BLOB_MISMATCH')
  const parentPackage = git(['show', implementationHead + '^:package.json'], null)
  if (crypto.createHash('sha256').update(parentPackage).digest('hex') !== '62a2f529de107940ca5b7424f0f1f56711e19d5f67862668031890a0fbb3a32d') terminal('FAIL', 'E_DEPENDENCY_PARENT')
  const before = JSON.parse(parentPackage.toString('utf8'))
  const after = JSON.parse(packageSource.toString('utf8'))
  if (canonical(after.devDependencies) !== canonical({ acorn: '8.18.0' })) terminal('FAIL', 'E_DEPENDENCY_DELTA')
  delete after.devDependencies
  if (canonical(after) !== canonical(before)) terminal('FAIL', 'E_PACKAGE_EXTRA_DELTA')
  const lock = JSON.parse(lockSource.toString('utf8'))
  const expectedLock = {
    name: 'tad-framework',
    version: '2.42.0',
    lockfileVersion: 1,
    requires: true,
    dependencies: {
      acorn: {
        version: '8.18.0',
        resolved: 'https://registry.npmjs.org/acorn/-/acorn-8.18.0.tgz',
        integrity: 'sha512-lGq+9yr1/GuAWaVYIHRjvvySG5/4VfKIvC8EWxStPdcDh/Ka7FG3twP6v4d5BkravUilhIAsG4Qj83t02LWUPQ==',
        dev: true
      }
    }
  }
  if (canonical(lock) !== canonical(expectedLock)) terminal('FAIL', 'E_PACKAGE_LOCK')
  ;['npm-shrinkwrap.json', 'yarn.lock', 'pnpm-lock.yaml'].forEach(function (name) {
    if (fs.existsSync(path.join(ROOT, name))) terminal('FAIL', 'E_EXTRA_LOCKFILE ' + name)
  })
}

verifyDependencySurface()

const signatureAudit = readJson('acorn-signature-audit.json')
exactKeys(signatureAudit, ['invalid', 'missing'], 'acorn-signature-audit')
if (!Array.isArray(signatureAudit.invalid) || signatureAudit.invalid.length !== 0) terminal('FAIL', 'E_ACORN_SIGNATURE_INVALID')
if (!Array.isArray(signatureAudit.missing) || signatureAudit.missing.length !== 0) terminal('FAIL', 'E_ACORN_SIGNATURE_MISSING')

const compatibility = readJson('phase1-compatibility-results.txt')
exactKeys(compatibility, ['schema_version', 'policy_id', 'runtime_test_deferred_to', 'implementation_commit', 'node_path_observed', 'node_options_observed', 'code_generation_from_strings_observed', 'files'], 'compatibility-root')
if (compatibility.schema_version !== '1.0.0' || compatibility.policy_id !== 'node14-static-v1') terminal('FAIL', 'E_COMPATIBILITY_POLICY')
if (compatibility.runtime_test_deferred_to !== 'EPIC-20260824-yolo2-verified-orchestration.md#phase-4') terminal('FAIL', 'E_COMPATIBILITY_DEFER')
if (compatibility.implementation_commit !== implementationHead) terminal('FAIL', 'E_COMPATIBILITY_COMMIT')
if (compatibility.node_path_observed !== null) terminal('FAIL', 'E_NODE_PATH')
if (compatibility.node_options_observed !== null) terminal('FAIL', 'E_NODE_OPTIONS')
if (compatibility.code_generation_from_strings_observed !== 'blocked') terminal('FAIL', 'E_CODEGEN_OBSERVATION')
exactIdSet(compatibility.files.map(function (row) {
  return { case_id: row.artifact_path }
}), compatibilityFiles, 'compatibility')
compatibility.files.forEach(function (row) {
  exactKeys(row, ['artifact_path', 'syntax_check', 'external_imports', 'dynamic_external_imports', 'forbidden_apis'], 'compatibility-row:' + row.artifact_path)
  if (row.syntax_check !== 'PASS') terminal('FAIL', 'E_COMPATIBILITY_SYNTAX ' + row.artifact_path)
  if (!Array.isArray(row.external_imports) || row.external_imports.length !== 0) terminal('FAIL', 'E_EXTERNAL_IMPORT ' + row.artifact_path)
  if (!Array.isArray(row.dynamic_external_imports) || row.dynamic_external_imports.length !== 0) terminal('FAIL', 'E_DYNAMIC_EXTERNAL_IMPORT ' + row.artifact_path)
  if (!Array.isArray(row.forbidden_apis) || row.forbidden_apis.length !== 0) terminal('FAIL', 'E_FORBIDDEN_API ' + row.artifact_path)

})
const scannedModules = new Set()
compatibilityFiles.forEach(function (artifactPath) {
  scanModuleGraph(path.join(ROOT, artifactPath), scannedModules)
})

const raw = readJsonl('phase1-baseline-raw.jsonl')
if (raw.length !== 15) terminal('FAIL', 'E_BASELINE_ROWS')
const scenarios = ['normal', 'failed_test', 'single_reviewer', 'stale_evidence', 'interruption']
scenarios.forEach(function (scenario) {
  const rows = raw.filter(function (row) { return row.scenario === scenario })
  if (rows.length !== 3) terminal('FAIL', 'E_BASELINE_SCENARIO ' + scenario)
  const runs = rows.map(function (row) { return row.run }).sort().join(',')
  if (runs !== '1,2,3') terminal('FAIL', 'E_BASELINE_RUN_IDS ' + scenario)
  rows.forEach(function (row) {
    if (row.fake_tokens !== 0 || row.token_measurement_mode !== 'synthetic_adapter') terminal('FAIL', 'E_TOKEN_MODE ' + scenario)
    if (typeof row.elapsed_ms !== 'number' || row.elapsed_ms < 0) terminal('FAIL', 'E_ELAPSED ' + scenario)
    if (scenario === 'normal' && (row.terminal !== 'workflow_complete' || row.unsafe_complete !== false)) terminal('FAIL', 'E_NORMAL')
    if (scenario === 'failed_test' && (row.terminal !== 'workflow_complete' || row.layer1 !== false || row.unsafe_complete !== true)) terminal('FAIL', 'E_FAILED_TEST')
    if (scenario === 'single_reviewer' && (row.terminal !== 'workflow_complete' || row.reviewers !== 1 || row.unsafe_complete !== true)) terminal('FAIL', 'E_SINGLE_REVIEWER')
    if (scenario === 'stale_evidence' && (row.terminal !== 'workflow_complete' || row.unsafe_complete !== true)) terminal('FAIL', 'E_STALE_EVIDENCE')
    if (scenario === 'interruption' && (row.terminal !== 'uncaught_error' || row.recoverable_state !== false)) terminal('FAIL', 'E_INTERRUPTION')
  })
})

const summary = readJson('phase1-baseline-summary.json')
exactKeys(summary, ['schema_version', 'source_sha256', 'token_measurement_mode', 'total_runs', 'safety_correct_runs', 'adverse_false_completions', 'adverse_completed_runs', 'scenario_pass3'], 'summary-root')
if (summary.schema_version !== '1.0.0' || summary.token_measurement_mode !== 'synthetic_adapter') terminal('FAIL', 'E_SUMMARY_MODE')
if (summary.source_sha256 !== 'a05d3e288d1022f63d58903f34ce95fdc9cc05778ed193fe38ca4d837b7c4dcc') terminal('FAIL', 'E_SUMMARY_SOURCE')
if (summary.total_runs !== 15 || summary.safety_correct_runs !== 3 || summary.adverse_false_completions !== 9 || summary.adverse_completed_runs !== 9) terminal('FAIL', 'E_SUMMARY_COUNTS')
if (summary.scenario_pass3.normal !== true) terminal('FAIL', 'E_SUMMARY_NORMAL')
exactKeys(summary.scenario_pass3, scenarios, 'summary-pass3')
scenarios.slice(1).forEach(function (scenario) {
  if (summary.scenario_pass3[scenario] !== false) terminal('FAIL', 'E_SUMMARY_PASS3 ' + scenario)
})

const live = readJson('phase1-live-surface-results.txt')
exactKeys(live, ['schema_version', 'baseline_file_sha256', 'manifest_rows', 'current_rows', 'diff_rows', 'result'], 'live-root')
if (live.baseline_file_sha256 !== 'a10fc0a8cf02f9f386b35c541fa04ef47449d1aed80b92ef801f540c731e6ddd') terminal('FAIL', 'E_LIVE_BASELINE')
if (live.manifest_rows !== 120 || live.current_rows !== 120 || live.diff_rows !== 0 || live.result !== 'PASS') terminal('FAIL', 'E_LIVE_RESULT')

const thisFile = fs.readFileSync(new URL(import.meta.url))
const selfSha = crypto.createHash('sha256').update(thisFile).digest('hex')
process.stdout.write('AUTHOR_VERIFIER_SHA256=' + selfSha + '\n')
terminal('PASS')
