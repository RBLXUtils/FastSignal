# [*Fast*Signal](https://github.com/RBLXUtils/FastSignal)

*Fast*Signal is a Signal library made with consistency and expectable behaviour in mind, it is efficient, easy to use, and widely compatible.

## What about GoodSignal?

GoodSignal while being an interesting implementation (that even helped *Fast*Signal be developed), it suffers from some issues.

* GoodSignal does not support .Connected.

* GoodSignal is made only for Immediate mode, and does not have a Deferred mode option, while sleitnick's fork has `:FireDeferred`, it's not a very optimal solution as it's not a toggle, you have to go out of your way to use Deferred and it's inconvienient.

* GoodSignal has no :Destroy, only :DisconnectAll which means you can’t stop new connections from being created.

* GoodSignal’s :DisconnectAll does not call :Disconnect on connections, this causes an [inconsistency with RBXScriptSignals.](https://github.com/stravant/goodsignal/issues/4)

* GoodSignal’s connections and linked list nodes are the same reference, which causes issues such as disconnected connections can leak the connection’s function, signal, and other connections if not cleared properly.

* GoodSignal’s classes are strict, meaning you can index members that don’t exist, this is pretty useless, and means that empty fields in a class are false, and not nil, which is something that makes forking a bit harder and it takes a bit of time to process.

* GoodSignal’s connections are not immediately compatible with Janitor, or Maid.

* GoodSignal’s methods don’t have any type declaration at all, which would make it way nicer to use.

*Fast*Signal fixes all these issues.
*Fast*Signal's selling point is parity with RBXScriptSignal's API and *familiarity*.

*Fast*Signal has a familiar API and behaviour to RBXScriptSignals and other signal libraries, which help you work faster, these help you not have headaches while using *Fast*Signal.

## Installation

### From GitHub

You can get a `.rbxmx` file from a release on GitHub, you can do that by visiting [FastSignal's releases.](https://github.com/RBLXUtils/FastSignal/releases)

### From Roblox

You can get FastSignal directly from Roblox, via its Roblox Model.
You can find it [here.](https://www.roblox.com/library/6532460357)

### From Wally

You can get FastSignal as a dependancy on Wally.
Add `lucasmzreal/fastsignal` in your dependencies and you're done.

```toml
Signal = "lucasmzreal/fastsignal@10.2.0"
```

<a href="https://github.com/LucasMZReal/FastSignal/releases">
    <img alt="Releases" src="https://img.shields.io/github/v/release/LucasMZReal/FastSignal">
    </img>
</a>

<a href="https://github.com/LucasMZReal/FastSignal">
    <img alt="" src="https://img.shields.io/github/downloads/LucasMZReal/FastSignal/total">
    </img>
</a>
