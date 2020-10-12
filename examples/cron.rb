module Cron
  include GenericFunctions

  class Job; end
  class HTTPJob < Job; end
  class ScriptJob < Job; end
  
  generic :run do |type, *args|
    [type.class, args]
  end

  multi :run, HTTPJob do |job|
    puts "Run #{job} via http"
  end
  
  multi :run, ScriptJob do |job|
    puts "Run #{job} via script interface"
  end
  
  mutli :run, Job do |job|
    puts "Run #{job} via shell"
  end

  multi :run, Any do |obj|
    puts "Log error #{obj} is not a valid Job type"
  end

  module_function :run
end

Cron.run Cron::Job.new
Cron.run Cron::HTTPJob.new
Cron.run Cron::ScriptJob.new
Cron.run 1
Cron.run Object.new