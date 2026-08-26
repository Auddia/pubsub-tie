# Learnings & PRAR Log

## 2026-08-26: Dependency Security Remediation

### Context
Resolved 7 security vulnerabilities (CVE-2024-7254, CVE-2025-27221, CVE-2025-61594, CVE-2026-54297, CVE-2026-33637, CVE-2026-25765, CVE-2026-33170, CVE-2026-33169, CVE-2026-33176, CVE-2026-35611, CVE-2026-45363, CVE-2026-54904, CVE-2026-54906, CVE-2026-54905) across `google-protobuf`, `uri`, `faraday`, `activesupport`, `addressable`, `jwt`, and `concurrent-ruby`.

### PRAR Cycle
- **Perceive:** Identified direct vs transitive dependency graph in `Gemfile.lock` and `pubsub_tie.gemspec`. Noted `signet` constraint on `addressable` and platform requirement for `arm64-darwin`.
- **Reason:** Relaxed `bundler` development dependency in gemspec to `>= 2.0` to avoid version locks, updated `signet`/`googleauth` to unlock `addressable 2.9.0`, and upgraded all vulnerable gems to safe patched versions.
- **Act:** Ran `bundle lock --add-platform arm64-darwin` and `bundle update` for target packages. Verified the full test suite (`12 examples, 0 failures`).
- **Refine:** Confirmed lockfile compatibility across platforms (`arm64-darwin`, `ruby`, `x86_64-darwin`, `x86_64-linux`).
