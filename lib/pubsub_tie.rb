require 'yaml'
require 'logger'

require 'pubsub_tie/events'
require 'pubsub_tie/publisher'

module PubSubTie
  extend self

  attr_writer :logger

  def configure
    configure_publisher
    configure_events
  end

  def app_root
    Dir.pwd
  end

  def logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

  def env
    @env ||= defined?(Rails) ? Rails.env : ENV["ENV"] || 'development'
  end

  def configure_publisher
    config = load_yaml_file(File.join(app_root, 'config', 'gcp.yml'))[env]
    Publisher.configure(config)
  end

  def configure_events
    config = load_yaml_file(File.join(app_root, 'config', 'events.yml'))[env]
    Events.configure(config)
  end

  def load_yaml_file(file_path)
    if defined?(Psych::VERSION) && Gem::Version.new(Psych::VERSION) >= Gem::Version.new('4.0.0')
      YAML.load_file(file_path, aliases: true)
    else
      YAML.load_file(file_path)
    end
  end

  def publish(topic, data, resource: nil)
    Publisher.publish(topic, data, resource)
  end

  def batch(topic, data, resource: nil)
    Publisher.batch(topic, data, resource)
  end
end

require 'pubsub_tie/railtie' if defined? Rails::Railtie
