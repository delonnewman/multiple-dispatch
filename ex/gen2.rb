# get some ideas from https://github.com/zkat/genfun, https://www.npmjs.com/package/protoduck, and https://www.npmjs.com/package/@zkat/protocols
module GenericFunctions
  Any = BasicObject
  DefaultArgs = [Any]

  def define_generic_method(name, *args, &blk)
    if args.empty?
      raise TypeError, "Useless use of a generic method, you should have some arguments, otherwise a normal method is preferrable"
    end

    generic_methods[name] ||= {}
    generic_methods[name][args] = blk

    if (respond_to?(:method_defined?) && !method_defined?(name)) || !respond_to?(name)
      define_method name do |*args|
        methods = generic_methods[name]
        fn = methods[args.map(&:class)] || methods[DefaultArgs]
        if fn
          args[0].instance_exec(*args, &fn)
        else
          raise TypeError, "#{name} is not defined for #{args.map { |x| "#{x.inspect}:#{x.class}" }.join(', ')}"
        end
      end
    end
  end
  alias generic define_generic_method
  
  def generic_methods
    @generic_methods ||= {}
  end

  def define_multi_dispatch_method(name, &blk)
    define_method name, &blk
  end
  alias multi define_multi_dispatch_method
end

include GenericFunctions

generic :test, Integer, String do |count, name|
  puts "This is a test #{count.inspect} #{name.inspect}"
end

generic :test, String do
  puts "This is a test #{self.inspect}"
end

generic :test, NilClass do
  puts "Nil"
end

generic :cool, String do
  puts "#{self} starts with A"
end

generic :cool, Integer do
  puts "#{self} is zero"
end

generic :cool, Any do
  puts "cool on #{self.inspect} is not well defined"
end

test 1, "Hey"
test "This is a test"
test nil

cool "Adventure"
cool 5
cool 0
cool 25
cool "Boat"
cool nil

multi :by_class, &:class

generic :by_class, Integer do
  puts "Integer #{self.inspect}"
end

generic :by_class, String do
  puts "String #{self.inspect}"
end

by_class 1
by_class "Hey there!"

module Cron
  include GenericFunctions

  class Job; end
  class HTTPJob < Job; end
  class ScriptJob < Job; end
  
  generic :run, HTTPJob do
    puts "Run #{self} via http"
  end
  
  generic :run, ScriptJob do
    puts "Run #{self} via script interface"
  end
  
  generic :run, Job do
    puts "Run #{self} via shell"
  end

  generic :run, Any do
    puts "Log error #{self} is not a valid Job type"
  end

  module_function :run
end

Cron.run Cron::Job.new
Cron.run Cron::HTTPJob.new
Cron.run Cron::ScriptJob.new
Cron.run 1
Cron.run Object.new