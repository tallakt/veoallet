# Veollet

The simplest safe Amoveo Wallet

NOTE: THIS SOFTWARE IS YET UNTESTED

## Introduction


The concept of Veoallet is to provide a simple way of signing transactions for
the amoveo blockchain, without having to trust the web page with your private
key. To make it safe, the source code is so short that you may read through the
code to assert that it does not contain any backdoors.

You can run `veoallet` from the command line and it will ask for a private key
and a raw transaction. Then it prints a signed transaction to the screen.

You may supply a file name as a command line parameter, and that file is read
as the private key. The format is like exported by the Amoveo web pages, a
simple text file with a hexadecimal string representing the 256 byte private
key.

The raw transaction may be generated by any Amoveo wallet web page by supplying
only your public key. The public key is printed when you run `veoallet`. Copy
the raw transaction to `veoallet`, then paste the signed transaction back to
the web wallet and press the publich transaction button on the page.


## Installation

You will need Elixir installed in order to compile Veollet. The Elixir version
is locked in the file `mix.exs`, but you may change that to a newer version if
necessary.

Get the repository from git, then use a text editor to verify no backdoors in
the source code.

Run the following commands to compile the `veoallet` command

```
$ MIX_ENV=prod mix deps.get
$ MIX_ENV=prod mix escript.build
$ MIX_ENV=prod mix escript.install
```

Follow the instructions onscreen.

