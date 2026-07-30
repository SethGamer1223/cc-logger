#!/usr/bin/env bash
set -euo pipefail
# This script is CC0; feel free to remove this notice and modify the script however you like.

SOURCE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

DATA_DIR="$(mktemp -d)"
mkdir -p "$DATA_DIR/computer/0"
COMPUTER_DIR="$DATA_DIR/computer/0"

cp "$SOURCE_DIR/logger.lua" "$COMPUTER_DIR"
cp -r "$SOURCE_DIR/test" "$COMPUTER_DIR"

OUTPUT=$(craftos --headless --directory "$DATA_DIR" --exec \
    'shell.run("test/mcfly.lua test"); os.shutdown()' 2>&1)

# Clean up CraftOS-PC terminal control sequences for CI logs
CLEAN_OUTPUT=$(printf "%s" "$OUTPUT" \
    | sed 's/\x1B\[[0-9;?]*[a-zA-Z]//g' \
    | tr -d '\r')

echo "$CLEAN_OUTPUT"

SUMMARY=$(printf "%s\n" "$CLEAN_OUTPUT" \
    | grep -E "Ran [0-9]+ test\(s\), of which [0-9]+ passed" \
    | tail -n 1)

if [[ "$SUMMARY" =~ Ran\ ([0-9]+)\ test\(s\),\ of\ which\ ([0-9]+)\ passed ]]; then
    TOTAL="${BASH_REMATCH[1]}"
    PASSED="${BASH_REMATCH[2]}"

    if [[ "$TOTAL" -eq "$PASSED" ]]; then
        echo "All tests passed: $PASSED/$TOTAL"
        exit 0
    else
        echo "Tests failed: $PASSED/$TOTAL"
        exit 1
    fi
else
    echo "Could not parse test summary:"
    echo "$SUMMARY"
    exit 1
fi
