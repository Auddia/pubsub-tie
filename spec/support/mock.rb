module PubSubTie
  module Google
    module PubSub
      module Mock
        extend self

        def topic(name)
          Topic
        end
      end

      module Topic
        extend self

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
