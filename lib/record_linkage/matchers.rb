require 'fuzzystringmatch'

module RecordLinkage
  # A module to hold the various matcher logic which can be declared
  # with a String or a Symbol
  module Matchers
    JAROW = ::FuzzyStringMatch::JaroWinkler.create(:native)

    def self.fuzzy_string_matcher(value1, value2, options = {})
      score = JAROW.getDistance(value1.downcase, value2.downcase)
      score > (options[:threshold] || 0.0) ? score : 0
    end

    def self.exact_string_matcher(value1, value2, _options = {})
      value1.to_s.strip.downcase == value2.to_s.strip.downcase ? 1.0 : 0.0
    end

    def self.number_nearness_matcher(value1, value2, options = {})
      max = options[:max]
      fail ArgumentError if !max.is_a?(Numeric)

      difference = (value1 - value2).abs

      if difference > max
        0.0
      else
        (max - difference).to_f / max.to_f
      end
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
      end.flatten.inject(:+)
    end

    def self.call_matcher(matcher_name, value1, value2, options = {})
      instance_eval do
        matcher_proc(matcher_name).call(value1, value2, options)
      end
    end

    def self.matcher_proc(matcher_name)
      if !Matchers.respond_to?("#{matcher_name}_matcher")
        fail ArgumentError, "Matcher `#{matcher_name}` is not defined"
      end

      Matchers.method("#{matcher_name}_matcher")
    end
  end
end
