#!/usr/bin/env bash
# Fails when app code hard-codes a color, font size, or padding instead of
# using design_system tokens (DESIGN_SYSTEM.md §13.3), or reads the window
# size directly instead of using its size classes and panes (§6.3). Run
# from the repository root.
set -euo pipefail

# Prints app code (not tests or generated files) that matches $1.
find_in_apps() {
  grep -rnE "$1" apps --include='*.dart' \
    --exclude='*.g.dart' --exclude-dir=gen --exclude-dir=test || true
}

status=0

matches=$(find_in_apps 'Color\(0x|fontSize:|EdgeInsets\.all\([0-9]')
if [ -n "$matches" ]; then
  echo "$matches"
  echo "::error::Use design_system tokens (context.colors, context.appText, AppSpacing) instead of raw values in apps/. See DESIGN_SYSTEM.md §13.3."
  status=1
fi

matches=$(find_in_apps 'MediaQuery\.(sizeOf|widthOf|orientationOf)|MediaQuery\.of\([^)]*\)\.(size|orientation)')
if [ -n "$matches" ]; then
  echo "$matches"
  echo "::error::Use WindowSizeClass.of for the whole window, or PaneLayout and ReadingColumn for the space a screen gets, instead of reading the window size in apps/. See DESIGN_SYSTEM.md §6.3."
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "No raw colors, font sizes, padding, or window sizes in apps/."
fi
exit "$status"
