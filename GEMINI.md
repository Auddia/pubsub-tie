# pubsub_tie

A Ruby gem that wraps Google Cloud Pub/Sub to provide schema validation and asynchronous event publication enforcing standardized naming conventions and schemas.

## Architecture & Core Components

- **`lib/pubsub_tie.rb`**: Top-level entrypoint module providing `.configure`, `.publish`, `.batch`, logger, and Rails Railtie integration.
- **`lib/pubsub_tie/events.rb`**: Manages event configuration, schema definition, required/optional/repeated fields, and type mapping.
- **`lib/pubsub_tie/publisher.rb`**: Handles connection to Google Cloud Pub/Sub, validates payload structure and data types against schema definitions, augments payloads with metadata (`event_name`, `event_time`), and publishes messages asynchronously.
- **`lib/pubsub_tie/railtie.rb`**: Rails integration hook.

## Setup & Testing

- Ruby version: `3.2.2` (managed via `.ruby-version`)
- Install dependencies: `bundle install`
- Run test suite: `bundle exec rspec`
