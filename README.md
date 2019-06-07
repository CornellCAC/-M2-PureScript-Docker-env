This file contains our docker files for creating a Macaulay2 development image
with PureScript and PureScript-Native build tools

Based on Macaulay2 container work from
[InteractiveShell](https://github.com/fhinkel/InteractiveShell/tree/master/docker-m2-container)
and PureScript container work from
[purescript-hodgepodge](https://github.com/bbarker/purescript-hodgepodge).

# Example usage

## Docker Hub vs Locally Built Image

To use the DockerHub image just run `./psc.sh <command>`.

To build the image locally (will take a while!) do `make all`. Then to run it,
`DHUB_PREFIX="" ./psc.sh <command>`.


## Installed M2 Binaries


```
./psc.sh M2
```


## Bash shell

```
./psc.sh bash
```

## PureScript REPL (PSCi)

Note that this is currently just for the **JavaScript** backend.

We use [spago](https://github.com/spacchetti/spago) to run PSCi in a spago
project. A barebones project is provided in `/spagoex`, so you can just do:


```
$ cd /spagoex/ && spago repl
PSCi, version 0.12.5
Type :? for help

> import Prelude
> map (\x -> x * 2) [2, 4, 6]
[4,8,12]

> :quit
See ya!
()

```

