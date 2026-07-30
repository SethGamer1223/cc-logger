#!/usr/bin/env bash
set -euo pipefail
# This script is CC0; feel free to remove this notice and modify the script however you like, with or without attribution.

# Get the root of your Git repository, for copying files into the environment later.
SOURCE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Create a temporary directory for storing CraftOS-PC data.
DATA_DIR="$(mktemp -d)"
mkdir -p "$DATA_DIR/computer/0"
COMPUTER_DIR="$DATA_DIR/computer/0"

# Copy your library into the testing environment.
cp "$SOURCE_DIR/logger.lua" "$COMPUTER_DIR"
# And your tests!
cp -r "$SOURCE_DIR/test" "$COMPUTER_DIR"

# Run CraftOS-PC in headless mode (no GUI) and with the data directory set to $DATA_DIR.
OUTPUT=$(craftos --headless --directory "$DATA_DIR" --exec \
    'shell.run("test/mcfly.lua test"); os.shutdown()' 2>&1)
# give results
echo $OUTPUT

SUMMARY=$(echo "$OUTPUT" | tail -n 1)

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
