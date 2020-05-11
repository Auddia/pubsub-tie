module PubSubTie
  module Events
    extend self

    def configure(config)
      @prefix = config['app_prefix']

      evs = config['events'].map{|e| e['name']}
      @events = Hash[evs.map(&:to_sym).zip(config['events'])]
    end

    # Full event name from symbol protecting from typos
    # Raises KeyError if bad symbol
    def name(sym)
      "#{@prefix}-#{value(sym, 'name')}"
    end

    def required(sym)
      (value(sym, 'required') || []).map(&:to_sym)
    end

    def optional(sym)
      (value(sym, 'optional') || []).map(&:to_sym)
    end

  private
    def value(sym, key)
      @events.fetch(sym)[key]
    end
  end
end
