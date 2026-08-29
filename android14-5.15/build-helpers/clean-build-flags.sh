#!/bin/bash
set -euo pipefail

KERNEL_ROOT="${1:?}"
KERNEL_VER="${2:?}"
SUFFIX="${3:-SukiSU}"

cd "$KERNEL_ROOT"

if [ -f "./common/scripts/setlocalversion" ]; then
  if [[ "$KERNEL_VER" == "5."* ]] || [[ "$KERNEL_VER" == "6.1" ]]; then
    perl -i -0777 -pe "s/(.*)echo \"\\\\\$res\"/\$1echo \"\\\\\$res-${SUFFIX}\"/s" ./common/scripts/setlocalversion || true
  else
    perl -i -0777 -pe 's/(.*)echo "\$\{KERNELVERSION\}\$\{file_localversion\}\$\{config_localversion\}\$\{LOCALVERSION\}\$\{scm_version\}"/$1echo "\${KERNELVERSION}\${file_localversion}\${config_localversion}\${LOCALVERSION}-'"${SUFFIX}"'\${scm_version}"/s' ./common/scripts/setlocalversion || true
  fi
fi

if [ -f "build/build.sh" ]; then
  [ -f "./common/scripts/setlocalversion" ] && sed -i 's/-dirty//' ./common/scripts/setlocalversion || true
else
  [ -f "./build/kernel/kleaf/impl/stamp.bzl" ] && sed -i "/stable_scmversion_cmd/s/-maybe-dirty//g" ./build/kernel/kleaf/impl/stamp.bzl || true
  [ -f "./common/scripts/setlocalversion" ] && sed -i 's/-dirty//' ./common/scripts/setlocalversion || true
  rm -f ./common/android/abi_gki_protected_exports_* 2>/dev/null || true
  [ -f "./common/BUILD.bazel" ] && perl -pi -e 's/^\s*"protected_exports_list"\s*:\s*"android\/abi_gki_protected_exports_aarch64",\s*$//;' ./common/BUILD.bazel || true
fi

if [ -d "common" ]; then
  cd common
  git config user.name "github-actions[bot]" 2>/dev/null || true
  git config user.email "github-actions[bot]@users.noreply.github.com" 2>/dev/null || true
  git add -A 2>/dev/null || true
  git commit -m "${SUFFIX}: Clean Build" 2>/dev/null || true
fi
