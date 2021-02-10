RSpec.describe MultipleDispatch do
  module Cron
    extend MultipleDispatch
  
    class Job; end
    class HTTPJob < Job; end
    class ScriptJob < Job; end
    
    multi :run, HTTPJob do |job|
      "Run #{job} via http"
    end
    
    multi :run, ScriptJob do |job|
      "Run #{job} via script interface"
    end
    
    multi :run, Job do |job|
      "Run #{job} via shell"
    end
  
    module_function :run
  end

  it 'should dispatch by class by default' do
    expect(Cron.run Cron::Job.new).to match(/shell/)
    expect(Cron.run Cron::HTTPJob.new).to match(/http/)
    expect(Cron.run Cron::ScriptJob.new).to match(/script/)

    expect { Cron.run Object.new }.to raise_error(ArgumentError)
  end

#  module Requests
#    extend GenericFunctions
#
#    module_function
#
#    generic :submit do |request|
#      request[:tag]
#    end
#
#    multi :submit, :wfh do |request|
#      raise "A comment is required" unless request[:comment]
#      request.merge(status: :submitted, submitted_at: Time.now)
#    end
#
#    multi :submit, Any do |request|
#      request.merge(status: :submitted, submitted_at: Time.now)
#    end
#  end
end
