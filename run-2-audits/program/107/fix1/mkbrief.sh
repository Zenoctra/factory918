#!/usr/bin/env bash
# mkbrief.sh <entries>: a brief whose Reading pack holds two early entries, then <entries> filler entries.
echo "## Diff"; echo; echo "## Reading pack"; echo
echo "### pk/early.md, whole, 1 line"; echo; echo '`````'; echo x; echo '`````'; echo
echo "### pk/gone.txt, deleted at HEAD: no text"; echo
awk -v c="$1" 'BEGIN { for (i = 1; i <= c; i++) { print "### f" i ", whole, 1 line"; print ""; print "```"; printf "filler line %d padded to take some room in the section........\n", i; print "```"; print "" } }'
echo "## Standards"
