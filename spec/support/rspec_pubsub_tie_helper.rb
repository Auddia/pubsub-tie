module RspecPubSubTieHelper
  RSpec.configure do |config|
    config.prepend_before(:each) do
      allow(PubSubTie::Publisher).to receive(:configure) do
        PubSubTie::Google::PubSub::Mock.new
      end
    end
  end
end
