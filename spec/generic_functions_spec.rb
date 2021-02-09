RSpec.describe GenericFunctions do
  module Cron
    extend GenericFunctions
  
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

  class Identity
    include GenericFunctions

    generic :call do |x|
      x
    end

    multi :call, 1 do |x|
      "One"
    end

    multi :call, "One" do |x|
      1
    end
  end

  it 'should dispatch by what ever value is returned by the dispatcher' do
    ident = Identity.new
    expect(ident.(1)).to eq "One"
    expect(ident.("One")).to eq 1
  end
end
