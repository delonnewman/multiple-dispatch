class Router
  extend MultipleDispatch
end

class Action
  def self.to_proc
    instance = new
    lambda do |*args|
      instance.call(*args)
    end
  end
end

class List < Action
  def call(x)
    "Hey there"
  end
end

class Item < Action
  def call(x)
    "Something"
  end
end

class Routes < Router
  multi :get, '/', &List
  multi :get, '/', Integer, &Item
end
