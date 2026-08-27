# Learnings & PRAR Log

## 2026-08-26: Dependency Security Remediation

### Context
Resolved 7 security vulnerabilities (CVE-2024-7254, CVE-2025-27221, CVE-2025-61594, CVE-2026-54297, CVE-2026-33637, CVE-2026-25765, CVE-2026-33170, CVE-2026-33169, CVE-2026-33176, CVE-2026-35611, CVE-2026-45363, CVE-2026-54904, CVE-2026-54906, CVE-2026-54905) across `google-protobuf`, `uri`, `faraday`, `activesupport`, `addressable`, `jwt`, and `concurrent-ruby`.

### PRAR Cycle
- **Perceive:** Identified direct vs transitive dependency graph in `Gemfile.lock` and `pubsub_tie.gemspec`. Noted `signet` constraint on `addressable` and platform requirement for `arm64-darwin`.
- **Reason:** Relaxed `bundler` development dependency in gemspec to `>= 2.0` to avoid version locks, updated `signet`/`googleauth` to unlock `addressable 2.9.0`, and upgraded all vulnerable gems to safe patched versions.
- **Act:** Ran `bundle lock --add-platform arm64-darwin` and `bundle update` for target packages. Verified the full test suite (`12 examples, 0 failures`).
- **Refine:** Confirmed lockfile compatibility across platforms (`arm64-darwin`, `ruby`, `x86_64-darwin`, `x86_64-linux`).

## 2026-08-26: Keyless Application Default Credentials (ADC) Support

### Context
Updated `pubsub_tie` to support keyless ADC execution on Google Cloud platforms (Cloud Run, Cloud Functions, GKE) where `config['keyfile']` is omitted or empty.

### PRAR Cycle
- **Perceive:** Analyzed `Publisher.google_pubsub(config)`. Previously assumed `config['keyfile']` always existed, causing `File.join(..., nil)` to raise `TypeError` in keyless cloud environments.
- **Reason:** Supported both modes: when `keyfile` is present and non-empty, initialize with explicit `::Google::Cloud::PubSub::Credentials`; when omitted/empty, initialize `::Google::Cloud::PubSub.new(project_id: ...)` directly without credentials to invoke ADC via metadata server. Added project fallback to `ENV['GOOGLE_CLOUD_PROJECT']` and `'cfr-projects'`.
- **Act:** Modified `lib/pubsub_tie/publisher.rb`, updated `lib/pubsub_tie/version.rb` to `1.5.0`, created `CHANGELOG.md`, and added comprehensive unit tests covering all credential pathways.
- **Refine:** Ran `bundle exec rspec` (20 examples, 0 failures) and verified `gem build pubsub_tie.gemspec` successfully generated `pubsub_tie-1.5.0.gem`.
