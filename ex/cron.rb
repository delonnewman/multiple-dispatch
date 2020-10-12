module Cron
  include GenericFunctions

  class Job; end
  class HTTPJob < Job; end
  class ScriptJob < Job; end
  
  multi :run, HTTPJob do
    puts "Run #{self} via http"
  end
  
  multi :run, ScriptJob do
    puts "Run #{self} via script interface"
  end
  
  mutli :run, Job do
    puts "Run #{self} via shell"
  end

  multi :run, Any do
    puts "Log error #{self} is not a valid Job type"
  end

  module_function :run
end

Cron.run Cron::Job.new
Cron.run Cron::HTTPJob.new
Cron.run Cron::ScriptJob.new
Cron.run 1
Cron.run Object.new