# frozen_string_literal: true

module MultipleDispatch
  require_relative 'multiple_dispatch/version'
  require_relative 'multiple_dispatch/generic_function'

  class Error < RuntimeError; end

  def self.included(base)
    base.include(InstanceMethods)
    base.extend(ClassMethods)
  end

  def self.extended(base)
    base.extend(ClassMethods)
  end

  module InstanceMethods
    private
    def generic_function_lookup
      self.class.generic_function_lookup
    end
  end

  module ClassMethods
    # List the symbol names of the generic functions for this module
    #
    # @return [Array<Symbol>]
    def generic_functions
      generic_function_lookup.keys
    end

    # Return the named generic function or nil if it's not present
    #
    # @param name [Symbol]
    #
    # @return [GenericFunction, nil]
    def generic_function(name)
      generic_function_lookup[name]
    end

    # Define a generic function
    #
    # @example
    #   generic(:name) { |named| named.class }
    #   multi(:name, String) { |name| name }
    #   multi(:name, Person) { |p| p.name }
    #
    # @param name [Symbol]
    #
    # @return [Symbol] the name of the generic function
    def define_generic_function(name, &block)
      generic_function_lookup[name] ||= GenericFunction.new(block)
  
      define_method name do |*args|
        gf = generic_function_lookup.fetch(name) do
          raise Error, "undefined generic function `#{name}`"
        end

        gf.call(*args)
      end
  
      name
    end
    alias generic define_generic_function

    # Define a method on a generic function.
    #
    # @example
    #   generic(:name) { |named| named.class }
    #   multi(:name, String) { |name| name }
    #   multi(:name, Person) { |p| p.name }
    #
    # @param name [Symbol]
    #
    # @return [Symbol] the name of the generic function
    def define_generic_method(name, *arguments, &block)
      unless generic_function_lookup.key?(name)
        define_generic_function(name, &GenericFunction::DEFAULT_DISPATCH)
      end
  
      generic_function_lookup[name].add_method(arguments, block)
  
      name
    end
    alias multi define_generic_method

    private

    def generic_function_lookup
      @@generic_functions ||= {}
    end
  end
end
