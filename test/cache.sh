#!/bin/bash

# Verify that a second invocation of the action is served from the
# cache instead of building the kernel a second time.
#
# The script runs once after each of two consecutive invocations, with
# the cache state that invocation is expected to have seen as its sole
# argument ("miss" or "hit").
#
# Inputs are provided via the environment:
#   BUILD_DIR     the action's `build-dir` output
#   KERNEL_IMAGE  the action's `kernel-image` output

set -eu -o pipefail

: "${BUILD_DIR:?}"
: "${KERNEL_IMAGE:?}"

state=${1:?}
# Kept outside of the build directory, which is wiped below.
checksum=image.sha256

fail() {
  echo "::error::${1}"
  exit 1
}

case "${state}" in
  miss)
    # The kernel source is only ever checked out for a build that
    # actually runs, which makes its presence the signal to go by.
    [ -d linux ] || fail "no kernel source tree; no build appears to have run"
    [ -f "${KERNEL_IMAGE}" ] || fail "no kernel image was built"
    sha256sum "${KERNEL_IMAGE}" | cut -d' ' -f1 > "${checksum}"

    # Remove everything that the next invocation could conceivably
    # reuse, so that whatever it comes up with has to have come from
    # the cache.
    rm -rf linux/ kbuild/ "${BUILD_DIR}"
    ;;
  hit)
    [ ! -e linux ] || fail "kernel source was checked out; the kernel was built again"
    [ -f "${KERNEL_IMAGE}" ] || fail "no kernel image was restored from the cache"

    before=$(cat "${checksum}")
    after=$(sha256sum "${KERNEL_IMAGE}" | cut -d' ' -f1)
    [ "${before}" = "${after}" ] \
      || fail "restored kernel image differs from the built one (${after} != ${before})"
    ;;
  *)
    fail "unexpected cache state '${state}'"
    ;;
esac
