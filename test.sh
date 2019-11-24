#!/bin/bash
#
# A simple test runner
#

if mix docception README.md; then
    echo >&2 "Expected 'mix docception README.md' to result in a non-zero return value"
    exit 1
fi

if ! mix docception <(echo ""); then
    echo >&2 "Expected 'mix docception <(echo \"\")' to result in a zero return value"
    exit 1
fi
