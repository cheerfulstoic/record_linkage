# To run coverage via travis
require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rspec/its'

module TestHelpers
  def let_context(*args, &block)
    classes = args.map(&:class)
    context_string, hash =
      case classes
      when [String, Hash] then ["#{args[0]} #{args[1]}", args[1]]
      when [Hash] then args + args
      end

    context(context_string) do
      hash.each { |var, value| let(var) { value } }

      instance_eval(&block)
    end
  end
end

RSpec.configure do |c|
  c.extend TestHelpers
end
