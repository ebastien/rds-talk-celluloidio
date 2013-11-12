require 'celluloid'
require 'celluloid/io'

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

class Farmyard < Celluloid::SupervisionGroup
  pool SlowDuck, as: :duck_family, size: 5
end

class Duckling
  include Celluloid
  def quack
    raise RuntimeError, "Oops!"
  end
end

class ParentDuck
  include Celluloid
  def initialize
    @baby = Duckling.new_link
  end

  def quack
    @baby.async.quack
  end
end

class DuckServer
  include Celluloid::IO
  finalizer :shutdown

  def initialize
    @server = TCPServer.new('localhost', 3000)
    async.run
  end

  def shutdown
    @server.close if @server
  end

  def run
    loop { async.handle_connection @server.accept }
  end

  def handle_connection(socket)
    loop do
      socket.readpartial(4096)
      socket.puts "Quaaaaaack!"
    end
  rescue EOFError
    socket.close
  end
end
