RSpec.describe GenericFunctions do
  class Identity
    extend GenericFunctions

    generic :call do |x|
      [x]
    end

    multi :call, 1 do |x|
      "One"
    end

    multi :call, "One" do |x|
      1
    end
  end

  it 'should dispatch by the identity argument' do
    ident = Identity.new
    expect(ident.(1)).to eq "One"
    expect(ident.("One")).to eq 1
  end

  class Router
    extend GenericFunctions

    generic :get do |route|
      [route]
    end
  end

  class Routes < Router
    multi :get, '/' do |x|
      "List"
    end

    multi :get, '/:id' do |x|
      "Item"
    end
  end

  it 'should match the route' do
    r = Routes.new

    expect(r.get('/')).to eq "List"
    expect(r.get('/:id')).to eq "Item"
  end
end