# Docception

Run doctests on arbitrary markdown files.

## Usage

    $ mix docception files

## Disclaimer

This tool executes any Elixir doctest it encounters (think `eval`). Ensure that it does not
encounter any harmful code!

## Line numbers

Docception needs to wrap the markdown file in `defmodule` to make this work. Hence, the line
numbers in reported errors are slightly larger than the actual line.

## Example

This file can also be checked with docception. The following example is run through doctest and
results in an error:

    iex> :hello
    :crash

```
$ mix docception README.md
** (ExUnit.AssertionError)

Doctest failed
code:  :hello === :crash
left:  :hello
right: :crash
```

The following example works:

    iex> :hello
    :hello

## TODOs

* [ ] Clean up temporary directory where `.beam` files are stored
* [ ] Do not hard-code the temporary directory
* [ ] Fix "wrong indent" warnings for heredocs
* [ ] Check if this also works when a doctest refers to dependencies of the project
* [ ] Document how to use it with an alias in order to simplify running it in CI
* [ ] Check if anybody is actually interested in this
