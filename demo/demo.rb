require 'celluloid'

class Duck
  include Celluloid
  def quack
    "Quaaaaaack!"
  end
end

class SlowDuck
  include Celluloid
  def quack
    sleep 10
    "Quaaaaaack!"
  end
end

class Solver
  include Celluloid
  def compute(n)
    sleep 10
    n + 1
  end
end
