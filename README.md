# cargo-rlib-separate-dep-tree-example

This repo contains an example of how to use Rust's rlib crate-type to build a dependency with its own fixed dependency graph independent of the dependency graph of other crates so that version resolution occurrs in isolation for each.

In the example the `bridge` program imports `rlib1` and `rlib2` that are crates with the same name `rlib`.

`rlib1` depends on `stellar-xdr 21.0.0`.

`rlib2` depends on `stellar-xdr 21.0.1` and has an observable difference in behavior.

```
 ┌──────────────────┐  ┌──────────────────┐ 
 │stellar-xdr 21.0.0│  │stellar-xdr 21.0.1│ 
 └──────────────────┘  └──────────────────┘ 
           ▲                    ▲           
           │                    │           
        ┌──┴──┐              ┌──┴──┐        
        │rlib1│              │rlib2│        
        └─────┘              └─────┘        
           ▲                    ▲           
           │                    │           
           │      ┌──────┐      │           
           └──────┤bridge├──────┘           
                  └──────┘                  
```

Normally Cargo would merge the `stellar-xdr` dependencies and import only one of them to service the requirements of the two `rlib` crates.

The `rlib` crates are built in isolation and so the version resolution occurs in isolation.

When `bridge` is built it uses the predetermined and prebuilt rlibs for both the directly imported dependencies `rlib1` and `rlib2` as well as the transitive dependency `stellar-xdr` and its dependencies.

## How

1. Set the `crate-type` of the dependency to `rlib` (e.g. [rlib1/Cargo.toml](./rlib1/Cargo.toml#L7), [rlib2/Cargo.toml](./rlib2/Cargo.toml#L7))
2. Build the rlibs (e.g. [Makefile](./Makefile#L2-L3))
3. Provide the rlibs both direct and deps to rustc (e.g. [Makefile](./Makefile#L4-L8))
4. Don't import the rlibs (e.g. [bridge/Cargo.toml](./bridge/Cargo.toml))
5. Use the extern libs (e.g. [bridge/src/main.rs](./bridge/src/main.rs#L2-L3))

## Test

To test this example, run the `make test` command. It will build the `rlib` crates, then build the `bridge` program and execute it.

The output will show the output of calling functions on each rlib command that output data from each respective stellar-xdr crate that was different between the patch versions.

```
$ make test
cd rlib1 && cargo build --release
   Compiling rlib v1.0.0 (rlib1)
    Finished `release` profile [optimized] target(s) in 0.45s
cd rlib2 && cargo build --release
   Compiling rlib v2.0.0 (rlib2)
    Finished `release` profile [optimized] target(s) in 0.06s
cd bridge && cargo rustc --release -- \
                --extern rlib1=../rlib1/target/release/librlib.rlib \
                --extern rlib2=../rlib2/target/release/librlib.rlib \
                -L dependency=../rlib1/target/release/deps \
                -L dependency=../rlib2/target/release/deps
   Compiling bridge v0.1.0 (bridge)
    Finished `release` profile [optimized] target(s) in 0.14s
./bridge/target/release/bridge
rlib1: 26
rlib2: 25
```
