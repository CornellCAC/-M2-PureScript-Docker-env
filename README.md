This file contains our docker files for creating a Macaulay2 development image
with PureScript and PureScript-Native build tools

Based on Macaulay2 container work from
[InteractiveShell](https://github.com/fhinkel/InteractiveShell/tree/master/docker-m2-container)
and PureScript container work from
[purescript-hodgepodge](https://github.com/bbarker/purescript-hodgepodge).

# Example usage

## Installed M2 Binaries


```
./psc.sh M2
```

FIXME: perssion issue with home directory

## Bash shell

```
./psc.sh bash
```

## PureScript REPL (PSCi)

We use `spago` to run PSCi in a spago project. A barebones project is provided
in **FIXME**.

