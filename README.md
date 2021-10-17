<a href="https://github.com/LucasMZReal/FastSignal/releases">
    <img alt="Releases" src="https://img.shields.io/github/v/release/LucasMZReal/FastSignal">
</a> <a href="https://github.com/LucasMZReal/FastSignal">
    <img alt="" src="https://img.shields.io/github/downloads/LucasMZReal/FastSignal/total">
</a>

# *Fast*Signal

*Fast*Signal is a Signal library made with consistency and expectable behaviour in mind, it is efficient, easy to use, and widely compatible.

## What about GoodSignal?

GoodSignal while being an interesting implementation, sadly it suffers from some issues.

* GoodSignal does not support `.Connected`

* GoodSignal's `:Destroy` method is unproper, only "disconnecting" everything, but not preventing new connections from being connected

* GoodSignal's `:Destroy` does not `:Disconnect` connections properly.

* GoodSignal's connection and linked list nodes are the same thing, which causes issues such as disconnected connections leaking the connection's function, signal, and other connections.

* GoodSignal's classes are strict, this is pretty useless, and means that empty fields in a class are false, and not nil.

* GoodSignal's connections are not compatible with [Janitor.](https://GitHub.com/howmanysmall/Janitor)

* GoodSignal's methods don't have any type declaration at all, which would make it way nicer to use.

*Fast*Signal fixes all these issues.
*Fast*Signal's selling point is *consistency* and *familiarity*.

*Fast*Signal has a familiar API and behaviour to RBXScriptSignals and other signal libraries, which help you work faster, these help you not have headaches while using *Fast*Signal.
