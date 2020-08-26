require_relative 'generic_functions/version'

module GenericFunctions
  class GenericFunction
    DEFAULT_DISPATCH = lambda do |*args|
      args.map(&:class)
    end
  
    def initialize(dispacher = DEFAULT_DISPATCH)
      @methods   = {}
      @dispacher = dispacher
    end
  
    def add_method(arguments, body)
      @methods[arguments.values] = Method.new(arguments.keys, body)
  
      self
    end
  
    def call(*args)
      method = @methods[@dispacher.call(*args)]
      raise ArgumentError, "wrong arguments (given #{fmt_args(args)}, expected #{arglists})" if method.nil?
  
      method.call(*args)
    end
  
    private
  
    def fmt_args(args)
      args.map { |x| "#{x.inspect}:#{x.class}" }.join(', ')
    end
  
    def arglists
      @methods.keys.map(&:inspect).join(', ')
    end
  
    class Method
      def initialize(names, body)
        names.each do |name|
          define_singleton_method name do
            instance_variable_get(:"@#{name}")
          end
        end
  
        @names = names
        @body  = body
      end
  
      def call(*args)
        @names.each_with_index do |name, i|
          instance_variable_set(:"@#{name}", args[i])
        end
  
        instance_exec(&@body)
      end
    end
  end

  def generic_functions
    generic_function_lookup.keys
  end

  def generic_function(name)
    generic_function_lookup[name]
  end

  def define_generic_dispatch(name, &block)
    generic_function_lookup[name] ||= GenericFunction.new(block)
  end
  alias multi define_generic_dispatch

  def define_generic_method(name, arguments, &block)
    generic_function_lookup[name] ||= GenericFunction.new
    generic_function_lookup[name].add_method(arguments, block)

    define_method name do |*args|
      generic_function_lookup.fetch(name).call(*args)
    end
  end
  alias generic define_generic_method

  private

  def generic_function_lookup
    @generic_functions ||= {}
  end
end

include GenericFunctions

def coerce(fn)
  return fn         if fn.respond_to?(:call)
  return fn.to_proc if fn.respond_to?(:to_proc)

  raise "Don't know how to coerce #{fn.inspect} into a proc"
end

generic :reduce, fn: Symbol, col: Array do
  reduce(fn).call(col)
end

generic :reduce, fn: Symbol do
  lambda do |col|
    fn   = fn.to_proc
    memo = col[0]
    col = col.drop(1)
  
    col.each do |x|
      memo = fn.call(memo, x)
    end
  
    memo
  end
end

#pp generic_function(:reduce)
pp generic_functions

pp reduce(:+, Array(1..20))