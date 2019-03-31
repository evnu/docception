# Docception Example

An example project using Docception. This example illustrates how to use an alias
in order to run Docception automatically when running `mix test`. The following will be
executed and output written to stdout:

    iex> true
    false

Docctest is able to detect multiple erroneous tests. The following is detected as well:

    iex> false
    true

The output should be similar to this:

    $ mix test
    Docception: README.md
    Docception: Giving the group_leader 1000 ms to write

    00:39:19.983 [error] Process #PID<0.115.0> raised an exception
    ** (ExUnit.AssertionError)

    Doctest failed
    code:  true === false
    left:  true
    right: false

    README.md:8: :"Elixir.Docception.README.md" (module)

The tests can also use functions from modules defined in the application:

    iex> Example.hello()
    :world
