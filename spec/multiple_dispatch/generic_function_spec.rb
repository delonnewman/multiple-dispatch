require 'spec_helper'

RSpec.describe MultipleDispatch::GenericFunction do
  it 'should dispatch on multiple arguments' do
    function = described_class.new
    function.add_method([String, Integer], ->(str, count) { str * 3 })
    function.add_method([String, String], ->(a, b) { a + b })

    expect(function.call("yada", 3)).to eq "yadayadayada"
    expect(function.call("yada", "yada")).to eq "yadayada"
  end

  it 'should dispatch by what ever value is returned by the dispatcher' do
    ident = described_class.new(->(x) { x })
    ident.add_method([1], ->(_) { "One" })
    ident.add_method(["One"], ->(_) { 1 })

    expect(ident.(1)).to eq "One"
    expect(ident.("One")).to eq 1
  end
end
