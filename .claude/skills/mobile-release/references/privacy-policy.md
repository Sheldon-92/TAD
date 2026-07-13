# Privacy Policy & App Privacy Labels

Generate privacy policy + App Privacy Labels — legally required, rejection-preventing. Outputs to `.tad/active/release/{project}/`: privacy-audit.md, data-practices-matrix.md, developer-privacy-answers.md, privacy-policy.md, privacy-policy.html + privacy-policy.pdf.

## Step 1: Identify Privacy Requirements

For THIS app:

1. What user data is collected? (account info, location, photos, analytics, etc.)
2. What third-party SDKs are used? (each SDK collects data)
3. Does the app use AI/ML? (must disclose data sharing with AI providers)
4. Is the app for children? (COPPA requirements apply)

Search: "Apple App Privacy labels requirements 2026".

**Quality bar: must identify ALL data collection including third-party SDKs.**

## Step 2: Analyze Data Practices

For each data type collected, document a matrix — these map directly to App Privacy Labels in App Store Connect:

| Data Type | Collected By | Purpose | Linked to User? | Used for Tracking? |
|---|---|---|---|---|

Apple's label categories: Contact Info, Health, Financial, Location, Sensitive, Contacts, User Content, Browsing History, Search History, Identifiers, Usage Data, Diagnostics, Other Data.

**Quality bar: every SDK must be checked for data collection. Missing one = privacy label mismatch = rejection.**

## Step 3: Interrogate the Developer (BLOCKING GATE)

BEFORE generating a privacy policy, ask the developer:

1. List ALL third-party SDKs in your project (check package.json/Podfile)
2. Does the app collect user accounts? What fields?
3. Does the app use location/camera/microphone? When?
4. Does the app use AI/ML? Is data sent to a cloud API?
5. Is this app for children (under 13)?
6. Do you have a URL to host the privacy policy?

**DO NOT PROCEED without the developer's answers. A privacy policy with wrong data categories is legally worse than no privacy policy.** Developer must confirm the SDK list and data practices before any generation.

## Step 4: Derive Privacy Policy Content

Based on the developer's answers:

1. What data we collect (from audit above)
2. Why we collect it (purpose per data type)
3. How we store it (encryption, retention period)
4. Who we share it with (third-party list)
5. User rights (access, deletion, opt-out)
6. Contact info for privacy questions
7. AI/ML disclosure (if applicable)
8. Children's privacy (COPPA if applicable)

**Quality bar: privacy policy must be specific to THIS app, not a generic template.**

## Step 5: Generate Final Documents

1. Privacy policy page (HTML for hosting)
2. Privacy policy PDF (for records)
3. App Privacy Labels mapping (for App Store Connect entry)

Host the privacy policy at an accessible URL (required by Apple).

## Quality Criteria (pass/fail)

- All data collection identified (including third-party SDKs)
- App Privacy Labels match actual data practices exactly
- Privacy policy accessible via URL (not just in-app)
- AI/ML data disclosure included (if applicable)
- Fabricated privacy claims or invented data practices = FAIL
