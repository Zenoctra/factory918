## Walk

1. `/to-spec` now names the scenario table as the Testing decisions shape for stateful work.
2. `architect`'s runner prompt asks each candidate for the table, its contract, and its test list before the type sketch; stateless code that crosses a function boundary gets the usage and signature sketch.
3. The runner prompt keeps out-of-path inputs as refusal cells and requires an observed refusal before cutting one.
4. The Ticket playbook directs the architect step to append the synthesized artifact to the ticket before implementation, with the required first line and an optional human checkpoint.
5. The four implementation playbooks direct the writer to test the table's cells in order before implementation and to report a cell it cannot implement.
6. `review-brief.sh` reads the ticket body, so the posted artifact reaches the Spec reviewer as ticket text.
7. The knowledge build registers the sixth core page, copies it into the project template, and indexes it for `/knowledge scenario table`.
8. Both new vendor patches apply to their pinned sources; `python3 tools/check_knowledge.py` reports `knowledge ok: 119 files`.

## Would break

## Fails open

## Not asked for

hard findings: 0
