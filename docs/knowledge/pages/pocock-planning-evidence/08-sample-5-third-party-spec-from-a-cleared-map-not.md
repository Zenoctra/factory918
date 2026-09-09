<!-- lines: 8 | source: pages/pocock-planning-evidence.md | part 8/17 | title: Pocock Planning Evidence (brief) — Sample 5: third-party spec from a cleared map, not yet built (allisonmahmood/patchy-cloud #135) -->

## Contents (line numbers are for the Read tool's offset)
- L6: Sample 5: third-party spec from a cleared map, not yet built (allisonmahmood/patchy-cloud #135)

## Sample 5: third-party spec from a cleared map, not yet built (allisonmahmood/patchy-cloud #135)

Opened 2026-09-05 (today), no `ready-for-agent` label on the spec itself but on its ten sub-issues #136–#145. 40 user stories, 13 numbered implementation decisions. Opening line: "Charted on the Auth map (2026-09-02 to 2026-09-05). This issue is the auth spec: every shape decision the build implements, assembled from the map's Notes and its closed tickets, which hold the detail." Implementation decision 1 verbatim: "Clerk holds the browser session; Patchy issues exactly one credential, the machine token; every bearer is a user." Testing decisions: "assert caller-visible outputs: response status, headers, cookies, body, database rows, and command exit codes. Never mock Clerk or test SQL directly." Status: 0/10 sub-issues done. Included as the freshest full-chain instance; outcome unknown.
