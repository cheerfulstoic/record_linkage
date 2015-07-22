require 'record_linkage/matchers'

module RecordLinkage
  # Matcher objects represent how to handle individual rules
  # to compare one field to another
  class Matcher
    attr_reader :property1, :property2

    def initialize(property1, property2, definition, options = {})
      @property1 = property1
      @property2 = property2
      @block = self.class.match_block_from_definition(definition)
      @options = options
    end

    def score_objects(object1, object2, default_weight)
      value1 = object1.send(@property1)
      value2 = object2.send(@property2)

      weight = @options[:weight] || default_weight

      options = @options.merge(object1: object1, object2: object2)
      @block.call(value1, value2, options) * weight
    end

    def self.match_block_from_definition(definition)
      case definition
      when String, Symbol then Matchers.matcher_proc(definition)
      when Proc then definition
      else
        fail ArgumentError, "Invalid matcher definition: #{matcher.inspect}"
      end
    end
  end

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
