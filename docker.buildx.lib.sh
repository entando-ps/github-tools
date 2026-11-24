# Shared helpers for the multi-platform (buildx) docker scripts.
#
# Platforms are taken, in order of precedence, from:
#   1. the explicit argument passed to the script
#   2. the DOCKER_PLATFORMS environment variable
#   3. the default: linux/amd64,linux/arm64

DOCKER_BUILDX_DEFAULT_PLATFORMS="linux/amd64,linux/arm64"

# Resolves the platform list (see above) and prints it
function buildx.platforms() {
  local p="${1:-${DOCKER_PLATFORMS:-$DOCKER_BUILDX_DEFAULT_PLATFORMS}}"
  echo "${p// /}"
}

# Fails if the current buildx builder can't build every requested platform.
# Without this check a missing QEMU/binfmt setup only surfaces later as an
# obscure "exec format error" in the middle of a RUN step.
function buildx.assertPlatforms() {
  local platforms="$1"
  local supported
  # Bootstrap first: on a fresh builder, "inspect --bootstrap" reports the
  # node before it is running, i.e. with an empty platform list.
  docker buildx inspect --bootstrap >/dev/null
  supported="$(docker buildx inspect | sed -n 's/^Platforms: *//p' | head -n 1)"
  supported=",${supported// /},"

  local p missing=()
  IFS=',' read -r -a req <<< "$platforms"
  for p in "${req[@]}"; do
    [[ "$supported" == *",$p,"* || "$supported" == *",$p/"* ]] || missing+=("$p")
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo "::error::The current buildx builder does not support: ${missing[*]} (supported: ${supported:1:-1})." \
      "Set up QEMU (docker/setup-qemu-action) and a buildx builder (docker/setup-buildx-action) first." 1>&2
    return 1
  fi
}

# Short arch name of a platform ("linux/arm64/v8" -> "arm64")
function buildx.archOf() {
  local a="${1#*/}"
  echo "${a%%/*}"
}
