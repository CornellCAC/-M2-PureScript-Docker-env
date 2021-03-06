This repository contains our docker files for creating a Macaulay2 development
image with PureScript and PureScript-Native build tools

Based on Macaulay2 container work from
[InteractiveShell](https://github.com/fhinkel/InteractiveShell/tree/master/docker-m2-container)
and PureScript container work from
[purescript-hodgepodge](https://github.com/bbarker/purescript-hodgepodge).

# What is included

The idea is to provide the following:

1. An M2 binary for convenient testing.
2. PureScript (JavaScript) for testing and a PureScript shell.
3. PureScript-Native, and dependencies to build it in case tweaking is needed.
4. Dependencies to build Macaulay2, so M2 can be tailored to interact with PureScript-Native.

In total, this makes for a fairly large Docker image.


# Example usage

## Prerequisites

1. Clone the [standard library FFI](https://github.com/andyarvanitis/purescript-native-ffi).
2. Clone the Macualy2 repository and check out branch TODO.
3. Copy `config.sh.example` to `config.sh` and set required variables accordingly.

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

## Building a PureScript-Native Example

```
./psc.sh bash
b8832abb93d5a47294a61b6cd3f38a309fab0f8959bc82726125c64342a616ed
brandon@b8832abb93d5:/wd$ cd Examples/GMP/
brandon@b8832abb93d5:/wd/Examples/GMP$ psc-package install
Install complete
brandon@b8832abb93d5:/wd/Examples/GMP$ make release
make[1]: Entering directory '/wd/Examples/GMP'
Linking output/bin/main
make[1]: Leaving directory '/wd/Examples/GMP'
brandon@b8832abb93d5:/wd/Examples/GMP$ ./output/bin/main 
Hello, World!
```

For more details, see [Getting
Started](https://github.com/andyarvanitis/purescript-native#getting-started) in
the PureScript-Native README.

# References

##  PureScript Native

1. An introductory tutorial involving a [game engine](https://medium.com/@lettier/how-to-create-3d-games-with-purescript-and-cpp-faabf8f27fe6).
