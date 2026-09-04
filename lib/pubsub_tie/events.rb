module PubSubTie
  module Events
    extend self

    def configure(config)
      @prefix = config['app_prefix']
      common_fields = config['common'] || []

      evs = config['events'].map{|e| e['name']}
      @events = Hash[evs.map(&:to_sym).zip(config['events'])]
      @events.each do |k, evt|
        # Inject root-level common fields into each event's definitions
        common_fields.each do |cf|
          mode_key = cf['mode'] == 'REQUIRED' ? 'required' : 'optional'
          evt[mode_key] ||= []
          unless evt[mode_key].any? { |field| field['name'] == cf['name'] }
            evt[mode_key] << cf
          end
        end

        fields = (evt['required'] || []) + 
            (evt['optional'] || []) +
            (evt['repeated'] || [])
        evt['fields'] = Hash[ fields.map {|f| [f['name'], f['type']]} ]
      end
    end

    # Full event name from symbol protecting from typos
    # Raises KeyError if bad symbol
    def full_name(sym)
      "#{@prefix}-#{name(sym)}"
    end

    def name(sym)
      value(sym, 'name')
    end

    def required(sym)
      field_names(sym, 'required')
    end

    def optional(sym)
      field_names(sym, 'optional') + repeated(sym)
    end

    def repeated(sym)
      field_names(sym, 'repeated')
    end

    def types(sym)
      value(sym, 'fields')
    end

  private
    def value(sym, key)
      @events.fetch(sym)[key]
    end

    def field_names(sym, mode)
      (value(sym, mode) || []).map {|field| field['name'].to_sym}
    end
  end
end
