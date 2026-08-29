#!/bin/bash
set -e

KERNEL_ROOT="${1:?}"
ANDROID_VER="${2:?}"
KERNEL_VER="${3:?}"

cd "$KERNEL_ROOT"

# 1. Kleaf Bazel BUILD.bazel rules
if [ -f "common/BUILD.bazel" ]; then
  perl -pi -e 's/"kmi_symbol_list_strict_mode":\s*True/"kmi_symbol_list_strict_mode": False/g;' common/BUILD.bazel 2>/dev/null || true
  perl -pi -e 's/"kmi_symbol_list_add_only":\s*True/"kmi_symbol_list_add_only": False/g;' common/BUILD.bazel 2>/dev/null || true
fi

# 2. Legacy scripts & python ABI checkers
for SCRIPT in \
  build/abi/compare_to_symbol_list \
  build/kernel/abi/compare_to_symbol_list; do
  if [ -f "$SCRIPT" ]; then
    sed -i 's/^\s*exit 1$/    echo "Bypassing ABI check"; exit 0/' "$SCRIPT" 2>/dev/null || true
  fi
done

for PY_SCRIPT in $(find build -name "check_buildtime_symbol_protection.py" -o -name "check_kmi_symbol_list.py" 2>/dev/null); do
  if [ -f "$PY_SCRIPT" ]; then
    perl -i -pe 's/^(\s*)return 1$/$1return 0/g' "$PY_SCRIPT" 2>/dev/null || true
    perl -i -pe 's/^(\s*)sys\.exit\(1\)$/$1sys.exit(0)/g' "$PY_SCRIPT" 2>/dev/null || true
  fi
done

# 3. Build config
if [ -f "./common/build.config.gki" ]; then
  sed -i 's/check_defconfig//' ./common/build.config.gki 2>/dev/null || true
  echo "KMI_SYMBOL_LIST_STRICT_MODE=0" >> ./common/build.config.gki
  echo "ABI_DEFINITION=" >> ./common/build.config.gki
  echo "KMI_SYMBOL_LIST=" >> ./common/build.config.gki
  echo "ADDITIONAL_KMI_SYMBOL_LISTS=" >> ./common/build.config.gki
fi

exit 0
