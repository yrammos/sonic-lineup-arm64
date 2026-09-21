#!/bin/sh
# Build quietly; on failure print only the first error with context.
# Full output: build.log

export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
log=build.log
pat='error:|^ld: |Undefined symbols|\*\*\* '

if make -j"$(sysctl -n hw.ncpu)" "$@" >"$log" 2>&1; then
    echo "BUILD OK ($(grep -c 'warning:' "$log") warnings, see $log)"
    exit 0
fi

line=$(grep -nE -m1 "$pat" "$log" | cut -d: -f1)
echo "BUILD FAILED, first error at $log:${line:-?}"
if [ -n "$line" ]; then
    start=$((line > 5 ? line - 5 : 1))
    sed -n "${start},$((line + 25))p" "$log"
else
    tail -n 40 "$log"
fi
exit 1
