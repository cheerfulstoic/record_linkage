# To run coverage via travis
require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rspec/its'

# Introduces `let_context` helper method
# This allows us to simplify the case where we want to
# have a context which contains one or more `let` statements
module LetContextHelpers
  # Supports giving either a Hash or a String and a Hash as arguments
  # In both cases the Hash will be used to define `let` statements
  # When a String is specified that becomes the context description
  # If String isn't specified, Hash#inspect becomes the context description
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
  c.extend LetContextHelpers
end
