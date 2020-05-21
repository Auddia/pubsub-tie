module RspecPubSubTieHelper
  RSpec.configure do |config|
    config.prepend_before(:each) do
      allow(PubSubTie::Publisher).
          to receive(:google_pubsub).
          and_return(PubSubTie::Google::PubSub::Mock)
    end
  end
end
