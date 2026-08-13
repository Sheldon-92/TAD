# Review Checklist — Reviewer Personas + Gate Standards

Load this file before any Gate/expert review of mobile-release deliverables.

## Reviewer Personas & Checklists

### App Store Optimization Specialist (store metadata)
- Keywords maximized within 100-char limit?
- Screenshots accurately represent app?
- Description conversion-focused?

### Release Engineer (TestFlight distribution)
- Code signing automated (match or EAS)?
- Build number auto-incremented?
- CI/CD pipeline configured?

### App Store Review Specialist (review compliance)
- All 10 compliance items checked?
- Guideline numbers accurate?
- Demo account ready?

### Privacy Compliance Officer (review compliance + privacy policy)
- Privacy labels match actual behavior?
- AI data usage disclosed?
- Third-party SDK data collection documented?
- All data collection accurately documented?
- Third-party SDKs all accounted for?

### Release Manager (version management)
- Semver followed?
- Build numbers sequential?
- Git tags present?

### DevOps Engineer (release automation)
- Secrets management secure?
- Pipeline stages complete?
- Cache strategy reduces build time?

### Product Manager (post-release monitoring)
- Crash reporting active?
- Review response SLA defined?
- Post-release metrics tracked?

## Gate 2 (Design) Checklist

- Review compliance checklist complete (all 10 items)
- Privacy policy generated with App Privacy Labels mapping
- Metadata strategy defined (keywords, screenshots)
- Distribution method chosen (fastlane vs EAS)
- Version management strategy defined

## Gate 4 (Acceptance) Checklist

- Compliance report: all items PASS or fixes applied
- Privacy policy accessible via URL
- App Privacy Labels match documented data practices
- Fastlane/EAS config files generated and valid
- Version follows semver, build number auto-incremented
- CI/CD pipeline configured (if applicable)
- Demo account ready for Apple reviewer (if login required)

## Expected Release Artifact Structure

```
{project}/fastlane/                   # Fastlane config (native)
├── Appfile                           # App identifiers + team
├── Fastfile                          # Lanes: test, beta, release
└── metadata/en-US/                   # Localized metadata
    ├── name.txt
    ├── subtitle.txt
    ├── keywords.txt
    ├── description.txt
    └── release_notes.txt

{project}/                            # Expo config
├── app.json                          # Version, buildNumber, plugins
└── eas.json                          # Build profiles

.tad/active/release/{project}/        # TAD documentation
├── compliance-report.pdf             # Review compliance checklist
├── compliance-checklist.md           # Raw checklist data
├── privacy-policy.html               # Hosted privacy policy
├── privacy-policy.pdf                # Privacy policy PDF
├── data-practices-matrix.md          # App Privacy Labels mapping
├── metadata-strategy.md              # ASO strategy
├── distribution-plan.md              # TestFlight plan
├── version-strategy.md               # Versioning approach
├── ci-strategy.md                    # CI/CD plan
├── monitoring-setup.md               # Post-release monitoring
└── review-response-templates.md      # Review response protocol
```
