# Docception

[![CircleCI](https://circleci.com/gh/evnu/docception.svg?style=svg)](https://circleci.com/gh/evnu/docception)

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

* [x] Clean up temporary directory where `.beam` files are stored
* [x] Do not hard-code the temporary directory
* [ ] Fix "wrong indent" warnings for heredocs
* [ ] Try to fix wrong line number reports (the offset is always the same!)
* [ ] Check if this also works when a doctest refers to dependencies of the project
* [ ] Document how to use it with an alias in order to simplify running it in CI
* [ ] Check if anybody is actually interested in this
* [ ] Publish

## How..?

Docception's approach is pretty simple:

1. Read in a markdown file
1. Escape `"""`
1. Wrap it into a module and place the files content into a `@moduledoc`
1. Run it through `Code.compile_string/1`
1. Store the resulting `.beam` in the filesystem to make `Code.fetch_docs/1` work
1. Call into the undocumented-and-totally-not-for-public-use `ExUnit.DocTest.__doctests__/1`
   function
1. For each of the quoted doctests, spawn a process and call let it run the quoted doctest
1. Gather the results and raise on error

So, except for calling into `__doctests__/1`, this is pretty straight forward.
