!SLIDE title
# Celluloid & Co<br/>Object Oriented Concurrency in Ruby #
<div class="title_desc">
  <ul>
    <li><a href="http://twitter.com/ebastien">Emmanuel Bastien</a></li>
    <li><a href="http://rivierarb.fr">Riviera.rb</a></li>
    <li>November 12, 2013</li>
  </ul>
</div>

!SLIDE
## is Ruby object oriented? ##

!SLIDE
## From objects ... ##

    I'm sorry that I long ago coined the
    term "objects" for this topic because
    it gets many people to focus on the
    lesser idea.

    The big idea is "messaging" --
    that is what the kernel of Smalltalk/Squeak
    is all about.

    -- Alan Kay

!SLIDE
## ... to concurrency ##

    Erlang might be the only object oriented
    language because the 3 tenets of object
    oriented programming are that it's based
    on message passing, that you have isolation
    between objects and have polymorphism.

    -- Joe Armstrong

!SLIDE
## is Ruby object oriented? ##
* Message passing? Kind of...
* Isolation? Nope.
* At least we have polymorphism!

!SLIDE
## Celluloid ##
* Each Ruby object is a unit of concurrency, called _actor_
  or _cell_.
* It is running in its own thread.
* Methods are called through transparent thread-safe queues
  called _mailboxes_.

!SLIDE
## Concurrent Duck ##
    @@@ruby
    class Duck
      include Celluloid
      def quack
        "Quaaaaaack!"
      end
    end

    >> d = Duck.new
     => #<Celluloid::ActorProxy(Duck:0x5260)>
    >> d.quack
     => "Quaaaaaack!"

!SLIDE
## Concurrent Duck (cont.) ##
    @@@ruby
    class SlowDuck
      include Celluloid
      def quack
        sleep 10
        "Quaaaaaack!"
      end
    end

    >> d = SlowDuck.new
     => #<Celluloid::ActorProxy(Duck:0x5458)>
    >> d.quack
     ...
     => "Quaaaaaack!"

!SLIDE
## Asynchronous method call ##
    @@@ruby
    >> d = SlowDuck.new
     => #<Celluloid::ActorProxy(Duck:0x5458)>
    >> d.async.quack
     => nil

* Caller does not block anymore...
* How to get our hands on the return value?

!SLIDE
## Futures! ##

    @@@ruby
    >> d = SlowDuck.new
     => #<Celluloid::ActorProxy(Duck:0x5458)>
    >> q = d.future.quack
    ...
    >> q.value # Blocking call
     => "Quaaaaaack!"

!SLIDE
## Links ##

    @@@ruby
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

!SLIDE
## Links (cont.) ##

    @@@ruby
    >> p = ParentDuck.new
    >> p.quack
      ...
      E, [...] ERROR -- : Duckling crashed!
      ...
      E, [...] ERROR -- : ParentDuck crashed!

!SLIDE
## Supervisors ##

    @@@ruby
    class Farmyard < Celluloid::SupervisionGroup
      pool SlowDuck, as: :duck_family, size: 5
    end

    >> Farmyard.run!
    >> f = (0..8).to_a.map { |n| Celluloid::Actor[:duck_family].future.quack }
    >> f.map(&:value)
     => ["Quaaaaaack!", "Quaaaaaack!", "Quaaaaaack!",
         "Quaaaaaack!", "Quaaaaaack!", "Quaaaaaack!",
         "Quaaaaaack!", "Quaaaaaack!", "Quaaaaaack!"]

!SLIDE
## Execution modes ##
* Exclusive as in [Erlang](http://www.erlang.org) and [Akka](http://akka.io/)
* Pipeline as in [ATOM](http://python.org/workshops/1997-10/proceedings/atom/)
  (default)

!SLIDE
## DCell ##
* Celluloid + ZeroMQ
* You basically get Erlang OTP in Ruby

!SLIDE
## Celluloid::IO ##
* Celluloid actors cannot respond to incoming messages
  during a blocking I/O operation.
* Creating an actor for each incoming connection might
  be expensive.

!SLIDE
## Celluloid::IO (cont.) ##

    @@@ruby
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

!SLIDE
## Celluloid::IO (cont.) ##

    @@@ruby
    >> s = DuckServer.new

!SLIDE
## References ##
* [Celluloid](https://github.com/celluloid/celluloid)
* [DCell](https://github.com/celluloid/dcell)
* [Celluloid::ZMQ](https://github.com/celluloid/celluloid-zmq)
* [Celluloid::IO](https://github.com/celluloid/celluloid-io)
* [Erlang](http://www.erlang.org)
* [Akka](http://akka.io/)
* [ATOM](http://python.org/workshops/1997-10/proceedings/atom/)
