# Counter

A muli-node aware CRDT-backed counter.

This is a second step in a continuing example.

See the tag `lesson_1` to see the complete code for Lesson 1.

In the first lesson, I use a GenServer to create a counter.  It demonstrated the
basic design and use of a GenServer, breaking responsiblities into different files
to simplify the design structure as much as possible.

In the second lesson, I introduce new concepts:

  * Use `libcluster` to have nodes join together
  * Replace the simple Model with a conflict-free, replicated data type.
  * Use `handle_info` to repeatedly schedule an event to send our data to other nodes.
  * Introduce a Distributor to send messages across nodes.

This system is not a "leader/follower" design.  Instead, all GenServers are peers.

## Setup

`mix deps.get`

## Testing

`mix test`

`mix credo`

`mix dialyzer`

## Run from iex
in different terminals:
`iex --sname one -S mix`

`iex --sname two -S mix`

*Session Example*

```
iex> Counter.inc()
:ok
iex> Counter.read()
1
```
