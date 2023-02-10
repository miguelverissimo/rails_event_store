# frozen_string_literal: true

module RubyEventStore
  class Projection
    private_class_method :new

    def initialize(initial_state = nil)
      @handlers = {}
      @init = -> { initial_state }
    end

    def self.init(initial_state = nil)
      new(initial_state)
    end

    def on(*event_klasses, &block)
      raise(ArgumentError, 'No handler block given') unless block_given?

      event_klasses.each do |event_klass|
        name = event_klass.to_s

        @handlers[name] = ->(state, event) { block.call(state, event) }
      end
      self
    end

    def call(scope)
      return initial_state if handled_events.empty?

      scope.of_types(handled_events).reduce(initial_state, &method(:transition))
    end

    private

    def initial_state
      @init.call
    end

    def handled_events
      @handlers.keys
    end

    def transition(state, event)
      @handlers.fetch(event.event_type).call(state, event)
    end
  end
end
