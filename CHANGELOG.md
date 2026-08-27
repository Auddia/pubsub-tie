# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-08-27

### Added
- Support for keyless Application Default Credentials (ADC) on Google Cloud environments (Cloud Run, Cloud Functions, GKE). When `keyfile` is omitted, `nil`, or empty in configuration, `Google::Cloud::PubSub.new` initializes automatically using ADC via the instance metadata server without requiring a static service account key file.
- Support for absolute keyfile paths (e.g., `/secrets/...`) for mounted secret volumes, alongside relative paths within `<app_root>/config`.
- Resolution for `project_id` via `config['project_id']`, `ENV['GOOGLE_CLOUD_PROJECT']`, `ENV['PUBSUB_PROJECT']`, or automatic Google Cloud metadata server discovery.
- Comprehensive unit tests covering both relative/absolute `keyfile` modes and keyless ADC mode.

### Security & Maintenance
- Remediated dependency security vulnerabilities in `Gemfile.lock` across `google-protobuf`, `uri`, `faraday`, `activesupport`, `addressable`, `jwt`, and `concurrent-ruby`.
- Added `arm64-darwin` platform support to lockfile.
- Relaxed bundler development dependency constraint to `>= 2.0`.

## [1.4.0] - Earlier Release
- Initial stable release with event validation, async publishing, and batching.
