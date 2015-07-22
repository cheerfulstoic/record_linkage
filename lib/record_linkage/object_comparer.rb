require 'record_linkage/matcher'

module RecordLinkage
  # Can be use to create an object with certian rules which can then
  # be used to compare objects to each other
  class ObjectComparer
    # Object given to `initialize` block to allow API
    # for configuring matchers / values
    class Config
      attr_accessor :default_weight
      attr_reader :matchers

      def add_matcher(property1, property2, definition, options = {})
        matchers << Matcher.new(property1, property2, definition, options)
      end

      def matchers
        @matchers ||= []
      end
    end

    def initialize
      yield config
    end

    def config
      @config ||= Config.new
    end

    def classify_hash(object1, object2)
      config.matchers.each_with_object({}) do |matcher, result|
        result[[matcher.property1, matcher.property2]] =
          matcher.score_objects(object1,
                                object2,
                                default_weight)
      end
    end

    def default_weight
      config.default_weight || 1.0
    end
  end
end
