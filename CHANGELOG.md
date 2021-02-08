# 0.4.0

* Improve output in successful case (#9, thanks to @axelson)

# 0.3.6

* Attempt to make writing output more reliable (#7)

# 0.3.5

* Fix ExUnit failure on shutdown (#2)

# 0.3.4

* Ensure that modules and functions from the parent project are available in doctests
* Better handling of location of syntax errors

# 0.3.1-0.3.3

* Publish `docception` hex package

# 0.3.0

* Example project to showcase Docception
* The `group_leader` can take some time until it is finished writing errors (use sleep for now)
* Output proper filenames on errors

# 0.2.1

* Output which file is currently being checked
* Fix dialyzer warning
* Document output in test

# 0.2.0

* Generate forms directly instead of wrapping in `@moduledoc`

# 0.1.0

* Initial implementation: Wrap markdown files in `@moduledoc` and run through `Code.compile_string/1`
