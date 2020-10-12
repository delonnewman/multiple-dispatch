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
      meth = :"_method_#{arguments.hash}"
      define_singleton_method(meth, &body)
      @methods[meth] = arguments

      self
    end
  
    def call(*args)
      meth = :"_method_#{@dispacher.call(*args).hash}"
      raise ArgumentError, "wrong arguments (given #{fmt_args(args)}, expected #{arglists})" unless respond_to?(meth)
  
      send(meth, *args)
    end

    def to_s
      "#<#{self.class} #{arglists}>"
    end
    alias inspect to_s
  
    private
  
    def fmt_args(args)
      if args.empty?
        'no arguments'
      else
        args.map { |x| "#{x.inspect}:#{x.class}" }.join(', ')
      end
    end
  
    def arglists
      @methods.values.map(&:inspect).join(', ')
    end
  end

  Any = BasicObject

  def generic_functions
    generic_function_lookup.keys
  end

  def generic_function(name)
    generic_function_lookup[name]
  end

  def define_generic_dispatch(name, &block)
    generic_function_lookup[name] ||= GenericFunction.new(block)
  end
  alias generic define_generic_dispatch

  def define_generic_method(name, *arguments, &block)
    generic_function_lookup[name] ||= GenericFunction.new
    generic_function_lookup[name].add_method(arguments, block)

    define_method name do |*args|
      generic_function_lookup.fetch(name).call(*args)
    end
  end
  alias multi define_generic_method

  private

  def generic_function_lookup
    @generic_functions ||= {}
  end
end