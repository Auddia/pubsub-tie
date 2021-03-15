# pubsub-tie
Basic hook for Google PubSub to enforce a number of auto-imposed basic rules on publication of events via PubSub messages:

1. Only white-listed events may be published
2. Enforce presence of required fields on events
3. Exclude fields nor required or optional
4. Check field type

## Installation
```shell
gem install pubsub_tie
```

## Usage
Publish white-listed events by symbol (name) passing hash structure of attributes. Events are published to topic named after event name and prefixed by app-level prefix
```ruby
require 'pubsub_tie'
evt = {'id' => 1, 'name' => 'John', 'email' => 'john@me.com'}
PubSubTie.publish(:user_updated, evt)
# published on topic 'my_app_name-user_updated'
```
## Configuration
There are two required configuration files that are expected at config/gcp.yml and config/events.yml

gcp.yml contains Google Cloud Platform project name and service account's credentials file by environment
```yaml
development:
  project: 'gcp-project'
  keyfile: 'name-of-google-credentials-file-to-be-found-on-config-directory'
production:
  ...
```

events.yml contains definition of valid events
```yaml
app_prefix: my_app_name
events:
  - name: evt_name_0
    summary: 'what happened at 0'
    required:
      - name: one_required_field
        type: STRING|INT|FLOAT|TIMESTAMP|DATETIME
      - name: another_required_field
        type: STRING|INT|FLOAT|TIMESTAMP|DATETIME
    optional:
      - name: one_optional_field
        type: STRING|INT|FLOAT|TIMESTAMP|DATETIME
  - name: evt_name_1
    summary: 'what happened at 1'
    required:
      - name: only_required_field
        type: STRING|INT|FLOAT|TIMESTAMP|DATETIME
```
