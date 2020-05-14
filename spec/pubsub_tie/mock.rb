module PubSubTie
  module Google
    module PubSub
      class Mock
        def topic(name)
          Topic.new(name)
        end
      end

      class Topic
        def initialize(name)
          @name = name
        end

        def publish_async(json, args={}, &block)
          yield(Result)
        end
      end

      class Result
        def self.succeeded?
          true
        end

        def self.error
          nil
        end
      end
    end
  end
end
