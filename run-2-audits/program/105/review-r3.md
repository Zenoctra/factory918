round: 3 of 3
comment: https://github.com/Zenoctra/factory918/pull/120#issuecomment-5788792937
act-on items: 0
restart: no
would-break fixed after f8105426da8226ba7780ba8f0a64c7334d096c1e: printed (round 4, fix-only, fixed point f810542, is owed)
item 1 [P1] Feature steps 2/7 and Refactoring step 3 (architect/interrogate fan-out) lacked the poll pointer; fixed: e090a3880f1914fc327822c1618492dbad59ccf8 (verified on origin/feat/speed-lessons, diff adds the pointer)
cause (round-3 look): each round's hard finding is a rule changed in one doc and left stale in a sibling; a hand sweep with no grep listing every site
