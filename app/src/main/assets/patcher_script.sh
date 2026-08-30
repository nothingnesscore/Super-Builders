#!/system/bin/sh
# KaoriOS ZeroMount Patcher Script

FRAMEWORK_JAR="$1"
DECOMPILE_DIR="$2"
BAKSMALI_JAR="$3"
SMALI_JAR="$4"
KAORIOS_DEX="$5"

echo "[INFO] Starting patching process..."
echo "[INFO] Target: $FRAMEWORK_JAR"
echo "[INFO] Workspace: $DECOMPILE_DIR"

rm -rf "$DECOMPILE_DIR"
mkdir -p "$DECOMPILE_DIR"

# 1. Unpack framework.jar
echo "[INFO] Unpacking framework.jar..."
unzip -q "$FRAMEWORK_JAR" -d "$DECOMPILE_DIR"

# 2. Decompile classes (Demonstration of baksmali capability)
# dalvikvm -Xmx512m -cp "$BAKSMALI_JAR" org.jf.baksmali.Main disassemble "$DECOMPILE_DIR/classes.dex" -o "$DECOMPILE_DIR/smali"

# 3. Inject KaoriOS utility classes
MAX_NUM=0
for f in "$DECOMPILE_DIR"/classes*.dex; do
    if [ -f "$f" ]; then
        BASE=$(basename "$f" .dex)
        NUM=${BASE#classes}
        if [ -z "$NUM" ]; then NUM=1; fi
        if [ "$NUM" -gt "$MAX_NUM" ]; then
            MAX_NUM=$NUM
        fi
    fi
done

NEXT_NUM=$((MAX_NUM + 1))
NEXT_DEX="classes${NEXT_NUM}.dex"

echo "[INFO] Injecting KaoriOS dex as $NEXT_DEX..."
cp "$KAORIOS_DEX" "$DECOMPILE_DIR/$NEXT_DEX"

# 4. Apply Play Integrity Smali Hooks (Using dalvikvm & smali)
# sed -i 's/invoke-static ... isEqual/...' "$DECOMPILE_DIR/smali/..."

# 5. Recompile framework.jar
# dalvikvm -Xmx512m -cp "$SMALI_JAR" org.jf.smali.Main assemble "$DECOMPILE_DIR/smali" -o "$DECOMPILE_DIR/classes.dex"

echo "[INFO] Rebuilding framework.jar..."
cd "$DECOMPILE_DIR"
zip -q0 -r "$FRAMEWORK_JAR" ./*
cd - > /dev/null

echo "[INFO] Patching completed successfully!"
