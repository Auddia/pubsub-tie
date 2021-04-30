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

    # 
    # Publishes event data asynchronously to topic inferred from event_sym.
    # Data is augmented with event_name and event_time and validated against
    # loaded configuration 
    #
    def publish(event_sym, data, resource)
      message = augmented(data, event_sym)      

      @pubsub.
        topic(Events.full_name event_sym).
        # publish(message(payload, resource), publish_time: Time.now.utc)
        publish_async(payload(validate_data(event_sym, message), resource),
                      publish_time: Time.now.utc) do |result|
          unless result.succeeded?
            Rails.logger.error(
              "Failed to publish #{message} to #{event_sym} on #{resource} due to #{result.error}")
          end
        end
    end

    def batch(event_sym, messages, resource)
      topic = @pubsub.
          topic(Events.full_name event_sym)
      messages.each do |data|
        message = augmented(data, event_sym)
        topic.publish_async(payload(validate_data(event_sym, message), resource),
                            publish_time: Time.now.utc) do |result|
          unless result.succeeded?
            Rails.logger.error(
                "Failed to publish #{message} to #{event_sym} on #{resource} due to #{result.error}")
          end
        end
      end
      topic.async_publisher.stop.wait!
    end

  private
    def payload(data, resource)
      # TODO: embed resource in message
      data.to_json
    end

    def validate_data(sym, data)
      missing = missing_required(sym, data)
      unless missing.empty?
        raise ArgumentError.new(
          "Missing event required args for #{sym}: #{missing}")
      end

      validate_types(sym, 
                     data.slice(*(Events.required(sym) + Events.optional(sym))))
    end

    def missing_required(sym, data)
      Events.required(sym) - data.keys
    end

    def augmented(data, event_sym)
      {event_name: Events.name(event_sym), 
       event_time: Time.current.utc}.merge(data.to_hash.to_options)
    end

    def validate_types(sym, data)
      data.each do |field, val|
        validate_type(field, val, data, sym)
      end

      data
    end

    def validate_type(field, val, data, sym)
      types = Events.types(sym)

      case val
      when String
        bad_type(field, data) unless types[field.to_s] == "STRING" 
      when Integer
        bad_type(field, data) unless ["INT", "FLOAT"].include? types[field.to_s]
      when Numeric
        bad_type(field, data) unless types[field.to_s] == "FLOAT"
      when Time
        bad_type(field, data) unless types[field.to_s] == "TIMESTAMP"
      when DateTime
        bad_type(field, data) unless types[field.to_s] == "DATETIME"
      when Array
        bad_type(field, data) unless Events.repeated(sym).include? field
        val.each {|elem| validate_type(field, elem, data, sym) }
      else
        bad_type(field, data)
      end
    end

    def bad_type(field, data)
      raise ArgumentError.new("Bad type for field #{field} in event #{data}")
    end
  end
end
