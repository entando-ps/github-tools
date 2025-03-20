#!/bin/bash

function configure.start() {
  {
    echo "~>"
    echo "~> Configuring \"$1\""
    echo "~>"
  } 1>&2

  declare -a CONFIGURED_VARS
}

function configure.propagateVars() {
  {
    echo "~> Configuration complete; new or updated variables:"
    for v in "${CONFIGURED_VARS[@]}"; do
      if [ -v "${v}" ]; then
        {
          export "$v"
          printf '%s=%s' "${v}" "${!v}" >> $GITHUB_ENV
          printf '~>   %-20s %s\n' "${v}:" "${!v}"
        } || true
      fi
    done
    echo "~>"
  } 1>&2
}
