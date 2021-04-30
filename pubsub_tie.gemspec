# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pubsub_tie/version'

Gem::Specification.new do |spec|
  spec.name         = "pubsub_tie"
  spec.version      = PubSubTie::VERSION
  spec.authors      = ["Pablo Calderon"]
  spec.email        = ["pablo@auddia.dev"]

  spec.summary      = "Hook for Google PubSub for publication of events enforcing autoimposed rules"
  spec.description  =  ""
  spec.homepage     = "https://github.com/ClipInteractive/pubsub-tie"
  spec.license      = "MIT"
  spec.required_ruby_version  = Gem::Requirement.new('>=2.1')

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end
  
  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_dependency 'google-cloud-pubsub', '~> 1.6'
  spec.add_dependency "activesupport"

  spec.add_development_dependency "rake", '~> 13.0'
  spec.add_development_dependency "bundler", '~> 2.1.4'
  spec.add_development_dependency "rspec", '~> 3.0'
end
