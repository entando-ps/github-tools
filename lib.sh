# Start configuration phase
function configure.start() {
  {
    echo "~>"
    echo "~> Configuring \"$1\""
    echo "~>"
  } 1>&2

  declare -a CONFIGURED_VARS
}

# Complete configuration by exporting variables to bash env and to GITHUB_ENV
function configure.complete() {
  echo "~> Configuration complete; new or updated variables:" 1>&2
  for v in "${CONFIGURED_VARS[@]}"; do
    if [ -v "${v}" ]; then
      {
        export "$v"
        printf '%s=%s\n' "${v}" "${!v}" >> $GITHUB_ENV
        printf '~>   %-20s %s\n' "${v}:" "${!v}" 1>&2
      } || true
    fi
  done
  echo "~>" 1>&2
}

# Exports a variables to GITHUB_OUTPUT
function gh.job.outputVar() {
  printf '%s=%s\n' "${1}" "${!1}" >> $GITHUB_OUTPUT
}


# Finds the PR to which the given commit belongs
function gh.pr.get-by-commit() {
  (
    if [ -n "${1:-}" ]; then
      GH_COMMIT_ID="$1"
    else
      GH_COMMIT_ID="$(git rev-parse HEAD)"
    fi
    GH_CONFIG_SRC_DESC+=" (FETCHED)"
    gh api "search/issues?q=${GH_COMMIT_ID}+type:pr" | jq -r '.items[0] | [.title, .number] | .[]'
  )
}
