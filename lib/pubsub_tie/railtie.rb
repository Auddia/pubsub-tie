module PubSubTie
  class Railtie < Rails::Railtie
    initializer 'configure PubSubTie' do
      PubSubTie.configure
    end
  end
end
