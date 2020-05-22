require 'google/cloud/pubsub'

module PubSubTie
  module Publisher
    extend self

    def configure(config)
      @pubsub = google_pubsub(config)
    end

    def google_pubsub(config)
      keyfile = File.join(PubSubTie.app_root, 'config', config['keyfile'])
      creds = Google::Cloud::PubSub::Credentials.new keyfile

      Google::Cloud::PubSub.new(project_id: config['project_id'],
                                credentials: creds)
    end

    def publish(topic_sym, data, resource)
      @pubsub.
        topic(Events.name topic_sym).
        # publish(message(data, resource), publish_time: Time.now.utc)
        publish_async(message(validate_data(topic_sym, data), resource),
                      publish_time: Time.now.utc) do |result|
          unless result.succeeded?
            Rails.logger.error(
              "Failed to publish #{data} to #{topic_name} on #{resource} due to #{result.error}")
          end
        end
    end

  private
    def message(data, resource)
      # TODO: embed resource in message
      data.to_json
    end

    def validate_data(sym, data)
      missing = missing_required(sym, data)
      unless missing.empty?
        raise ArgumentError.new(
          "Missing event required args for #{sym}: #{missing}")
      end

      data.slice(*(Events.required(sym) + Events.optional(sym)))
    end

    def missing_required(sym, data)
      Events.required(sym) - data.keys
    end
  end
end
