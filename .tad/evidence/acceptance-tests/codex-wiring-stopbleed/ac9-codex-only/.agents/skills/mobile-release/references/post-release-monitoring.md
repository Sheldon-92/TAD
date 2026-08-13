# Post-Release Monitoring — Crashes, Ratings, Reviews, Downloads

Monitor app health after release. Docs to `.tad/active/release/{project}/` (monitoring-setup.md, alert-config.md, review-response-templates.md, post-release-analysis.md).

## Step 1: Set Up Monitoring Tools

1. Crash reporting: Sentry or Firebase Crashlytics (integrate SDK)
2. Analytics: App Store Connect analytics (built-in)
3. Review monitoring: App Store Connect API or third-party (AppFollow)
4. Performance: Sentry performance monitoring

## Step 2: Define Alert Thresholds

1. Crash-free rate: alert if < 99%
2. Rating: alert if drops below 4.0
3. 1-star reviews: alert on each (respond within 48h)
4. Download trend: alert if drops > 30% week-over-week

## Step 3: Respond to Feedback

Review response protocol (from rshankras research):

1. Respond to all 1-2 star reviews within 48 hours
2. Thank positive reviewers (brief, authentic)
3. For bug reports in reviews: acknowledge + fix timeline
4. Never argue with reviewers

**A human reviews and approves responses before posting.**

## Step 4: Iterate on the Release

Based on monitoring data:

1. Top crashes → hotfix release (version X.Y.Z+1)
2. Feature requests → add to backlog
3. Poor ratings on specific feature → investigate and prioritize
4. Track: crash-free rate, DAU, retention, rating trend

## Quality Criteria (pass/fail)

- Crash reporting configured and tested
- Review response protocol defined (48h SLA)
- Alert thresholds set for crash rate and rating
- Fabricated monitoring data or invented crash rates = FAIL
