#!/usr/bin/env bash
# negative.sh <helpers> <brief>: each case must miss; prints the ones that pass wrongly.
set -euo pipefail
. "$1"
n=0
bad=0
( fence "$2" "### pk/early.md, whole, 1 line" '````' x > /dev/null ) && { echo "fence accepted a 4-tick fence"; bad=1; }
( fence "$2" "### nowhere" '`````' x > /dev/null ) && { echo "fence accepted a missing header"; bad=1; }
( fence "$2" "## Reading pack" '`````' x > /dev/null ) && { echo "fence accepted a header whose next-but-one line is not the fence"; bad=1; }
( notext "$2" "### nowhere" x > /dev/null ) && { echo "notext accepted a missing line"; bad=1; }
( notext "$2" "### f1, whole, 1 line" x > /dev/null ) || { echo "notext rejected a line followed by a blank"; bad=1; }
( notext "$2" "filler line 1 padded to take some room in the section........" x > /dev/null ) && { echo "notext accepted a line followed by a fence"; bad=1; }
( x="$(at "$2" 'no such line')"; [ -n "$x" ] ) && { echo "at found a missing line"; bad=1; }
echo "negative cases done, bad=$bad"
