#!/bin/bash
set -euo pipefail

KERNEL_ROOT="${1:?}"
KERNEL_VER="${2:?}"
SUFFIX="${3:-SukiSU}"

cd "$KERNEL_ROOT"

if [[ "$KERNEL_VER" == "5."* ]] || [[ "$KERNEL_VER" == "6.1" ]]; then
  [ -f "./common/scripts/setlocalversion" ] && perl -i -0777 -pe "s/(.*)echo "\\$res"/\$1echo "\\$res-${SUFFIX}"/s" ./common/scripts/setlocalversion || true
else
  [ -f "./common/scripts/setlocalversion" ] && perl -i -0777 -pe "s/(.*)echo "\\$\{KERNELVERSION\}\\$\{file_localversion\}\\$\{config_localversion\}\\$\{LOCALVERSION\}\\$\{scm_version\}"/\$1echo "\\${KERNELVERSION}\\${file_localversion}\\${config_localversion}\\${LOCALVERSION}-${SUFFIX}\\${scm_version}"/s" ./common/scripts/setlocalversion || true
fi

if [ -f "build/build.sh" ]; then
  [ -f "./common/scripts/setlocalversion" ] && sed -i 's/-dirty//' ./common/scripts/setlocalversion || true
else
  [ -f "./build/kernel/kleaf/impl/stamp.bzl" ] && sed -i "/stable_scmversion_cmd/s/-maybe-dirty//g" ./build/kernel/kleaf/impl/stamp.bzl || true
  [ -f "./common/scripts/setlocalversion" ] && sed -i 's/-dirty//' ./common/scripts/setlocalversion || true
  for exp in ./common/android/abi_gki_protected_exports_*; do [ -f "$exp" ] && : > "$exp"; done || true
  if [ -f "./common/BUILD.bazel" ]; then
    perl -pi -e 's/^\s*"protected_exports_list"\s*:\s*"android\/abi_gki_protected_exports_aarch64",\s*$//g;' ./common/BUILD.bazel
    if ! grep -q "sukisu_gki.fragment" ./common/BUILD.bazel; then
      echo 'exports_files(glob(["arch/arm64/configs/**", "android/**"]))' >> ./common/BUILD.bazel
    fi
  fi
fi

if [ -d "common" ]; then
  cd common
  git config --global user.name "github-actions[bot]"
  git config --global user.email "github-actions[bot]@users.noreply.github.com"
  git add -A
  git commit -m "${SUFFIX}: Clean Build" || true
fi
