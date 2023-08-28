require "sidekiq"

module RubyEventStore
  class SidekiqScheduler
    def initialize(serializer:)
      @serializer = serializer
    end

    def call(klass, record)
      klass.perform_async(record.serialize(serializer).to_h.transform_keys(&:to_s))
    end

    def verify(subscriber)
      if Class === subscriber
        !!(subscriber < Sidekiq::Worker)
      else
        subscriber.instance_of?(Sidekiq::Job::Setter)
      end
    end

    private

    attr_reader :serializer
  end
end
