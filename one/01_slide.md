!SLIDE title
# Celluloid::IO<br/>Object Oriented & Evented I/O in Ruby #
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
## Links & Supervisors ##

!SLIDE
## Execution modes ##
* Exclusive as in [Erlang](http://www.erlang.org) and [Akka](http://akka.io/)
* Pipeline as in [ATOM](http://python.org/workshops/1997-10/proceedings/atom/)
  (default)

!SLIDE
## DCell ##
* Celluloid + ZeroMQ
* Erlang OTP in Ruby 

!SLIDE
## Celluloid::IO ##
* Celluloid actors cannot respond to incoming messages
  during a blocking I/O operation.
* Creating an actor for each incoming connection might
  be expensive.

!SLIDE
## References ##
