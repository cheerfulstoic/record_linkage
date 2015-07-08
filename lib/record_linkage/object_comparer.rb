require 'fuzzystringmatch'

module RecordLinkage
  # Can be use to create an object with certian rules which can then
  # be used to compare objects to each other
  class ObjectComparer
    # Matcher objects represent how to handle individual rules
    # to compare one field to another
    class Matcher
      # A module to hold the various matcher logic which can be declared
      # with a String or a Symbol
      module Matchers
        JAROW = ::FuzzyStringMatch::JaroWinkler.create(:native)

        def self.fuzzy_string_matcher(value1, value2, options = {})
          if value1.to_s.strip.size < 3 || value2.to_s.strip.size < 3
            0.0
          else
            score = JAROW.getDistance(value1.downcase, value2.downcase)
            score > options[:threshold] ? score : 0
          end
        end

        def self.exact_string_matcher(value1, value2, _options = {})
          value1 = value1.to_s.strip.downcase
          value2 = value2.to_s.strip.downcase
          (value1.size >= 1 && value1 == value2) ? 1.0 : 0.0
        end

        def self.array_fuzzy_string_matcher(array1, array2, options = {})
          array_matcher(:fuzzy_string_matcher, array1, array2, options)
        end

        def self.array_exact_string_matcher(array1, array2, options = {})
          array_matcher(:exact_string_matcher, array1, array2, options)
        end

        def self.array_matcher(single_matcher, array1, array2, options = {})
          array1.map do |value1|
            array2.map do |value2|
              send(single_matcher, value1, value2, options)
            end
          end.flatten.sum
        end
      end

      attr_reader :property1, :property2

      def initialize(property1, property2, definition, options = {})
        @property1 = property1
        @property2 = property2
        @block = self.class.match_block_from_definition(definition)
        @options = options
      end

      def score_objects(object1, object2, default_threshold, default_weight)
        value1 = object1.send(@property1)
        value2 = object2.send(@property2)

        threshold = @options[:threshold] || default_threshold
        weight = @options[:weight] || default_weight

        @block.call(value1, value2, threshold: threshold) * weight
      end

      def self.match_block_from_definition(definition)
        case definition
        when String, Symbol
          if !Matchers.respond_to?("#{definition}_matcher")
            fail ArgumentError, "Matcher `#{definition}` is not defined"
          end

          Matchers.method("#{definition}_matcher")
        when Proc then definition
        else
          fail ArgumentError, "Invalid matcher definition: #{matcher.inspect}"
        end
      end
    end

    # Object given to `initialize` block to allow API
    # for configuring matchers / values
    class Config
      attr_accessor :default_threshold, :default_weight
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
                                default_threshold,
                                default_weight)
      end
    end

    def default_threshold
      config.default_threshold || 0.0
    end

    def default_weight
      config.default_weight || 1.0
    end
  end
end
