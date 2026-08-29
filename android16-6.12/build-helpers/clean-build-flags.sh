#!/bin/bash
set -e

KERNEL_ROOT="${1:?}"
KERNEL_VER="${2:?}"
SUFFIX="${3:-SukiSU}"

cd "$KERNEL_ROOT"

if [ -f "build/build.sh" ]; then
  [ -f "./common/scripts/setlocalversion" ] && sed -i 's/-dirty//' ./common/scripts/setlocalversion 2>/dev/null || true
else
  [ -f "./build/kernel/kleaf/impl/stamp.bzl" ] && sed -i "/stable_scmversion_cmd/s/-maybe-dirty//g" ./build/kernel/kleaf/impl/stamp.bzl 2>/dev/null || true
  [ -f "./common/scripts/setlocalversion" ] && sed -i 's/-dirty//' ./common/scripts/setlocalversion 2>/dev/null || true
  for exp in ./common/android/abi_gki_protected_exports_*; do [ -f "$exp" ] && : > "$exp"; done 2>/dev/null || true
  if [ -f "./common/BUILD.bazel" ]; then
    perl -pi -e 's/^\s*"protected_exports_list"\s*:\s*"android\/abi_gki_protected_exports_aarch64",\s*$//g;' ./common/BUILD.bazel 2>/dev/null || true
    if ! grep -q "sukisu_gki.fragment" ./common/BUILD.bazel 2>/dev/null; then
      echo 'exports_files(glob(["arch/arm64/configs/**", "android/**"]))' >> ./common/BUILD.bazel 2>/dev/null || true
    fi
  fi
fi

if [ -d "common" ]; then
  cd common
  git config user.name "github-actions[bot]" 2>/dev/null || true
  git config user.email "github-actions[bot]@users.noreply.github.com" 2>/dev/null || true
  git add -A 2>/dev/null || true
  git commit -m "${SUFFIX}: Clean Build" 2>/dev/null || true
fi

exit 0
