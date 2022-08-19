module MultipleDispatch
  class GenericFunction
    Any = BasicObject.new

    DEFAULT_DISPATCH = lambda do |*args|
      if args.size == 1
        args.first.class
      else
        args.map(&:class)
      end
    end

    def initialize(dispatcher = DEFAULT_DISPATCH)
      @dispatcher = dispatcher
    end

    def arity
      @dispatcher.arity
    end

    def add_method(arguments, body)
      raise ArgumentError, "Methods must have the same amout of arguments as the dispatching function" if arity > 0 && arguments.size != arity

      if arguments.size == 1
        method_lookup[arguments[0]] = body
      else
        scope = method_lookup
        arguments.each_with_index do |arg, i|
          unless i == arguments.size - 1
            scope[arg] = {} unless scope.key?(arg)
            scope = scope[arg]
          end
        end
        scope[arguments.last] = body
      end

      self
    end

    def call(*args)
      value = @dispatcher.call(*args)
      if arity == 1 || (!value.respond_to?(:each) && arity < 0)
        method = method_lookup[value]
        raise ArgumentError, "wrong arguments, given #{fmt_args(args)}, expected #{fmt_arglists}" if method.nil?
      else
        raise "Dispatching function should return the same number of values as it takes arguments" if arity > 0 && value.size != args.size
        method = method_lookup
        value.each do |value|
          method = method[value]
          raise ArgumentError, "wrong arguments, given #{fmt_args(args)}, expected #{fmt_arglists}" if method.nil?
        end
      end
      method.call(*args)
    end

    def to_s
      "#<#{self.class} #{fmt_arglists}>"
    end
    alias inspect to_s

    private

    def fmt_arglists
      method_lookup.keys.map(&method(:fmt_args)).join(', ')
    end

    def fmt_args(args)
      if not Array === args
        "(#{args.inspect}:#{args.class})"
      elsif args.empty?
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
end