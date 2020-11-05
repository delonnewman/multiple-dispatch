require_relative 'generic_functions/version'

module GenericFunctions
  class GenericFunction
    DEFAULT_DISPATCH = lambda do |*args|
      args.map(&:class).hash
    end

    attr_reader :dispatcher
  
    def initialize(dispatcher = DEFAULT_DISPATCH)
      @dispatcher = dispatcher
    end
  
    def add_method(arguments, body)
      meth = :"_method_#{arguments}"
      define_singleton_method(meth, &body)
      method_lookup[meth] = arguments

      self
    end
  
    def call(*args)
      meth = :"_method_#{dispatcher.call(*args)}"
      raise ArgumentError, "wrong arguments, given #{fmt_args(args)}, expected #{fmt_arglists}" unless respond_to?(meth)
  
      send(meth, *args)
    end

    def to_s
      "#<#{self.class} #{fmt_arglists}>"
    end
    alias inspect to_s
  
    private

    def fmt_arglists
      method_lookup.values.map(&method(:fmt_args)).join(', ')
    end
  
    def fmt_args(args)
      if args.empty?
        'no arguments'
      else
        "(#{args.map { |x| "#{x.inspect}:#{x.class}" }.join(', ')})"
      end
    end
  
    def arglists
      method_lookup.values.map(&:inspect).join(', ')
    end

    def method_lookup
      @method_lookup ||= {}
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

    define_method name do |*args|
      self.class.generic_function_lookup.fetch(name).call(*args)
    end

    name
  end
  alias generic define_generic_dispatch

  def define_generic_method(name, *arguments, &block)
    unless generic_function_lookup[name]
      define_generic_dispatch(name, &GenericFunction::DEFAULT_DISPATCH)
    end

    generic_function_lookup[name].add_method(arguments, block)

    name
  end
  alias multi define_generic_method

  def generic_function_lookup
    @@generic_functions ||= {}
  end
end