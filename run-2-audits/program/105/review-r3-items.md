# PR #120 review round 3: Act on items

1. template/.agents/skills/poteto-mode/playbooks/feature.md:6 (step 2, architect fan-out), feature.md step 7 (interrogate), refactoring.md:9 (step 3, architect): these steps launch lanes but carry no poll pointer. Add the sentence the delegate steps got ("Poll each lane's result file per the poll rule (Ticket step 0).") to each, and to any other playbook step that invokes architect, interrogate, arena or swarm fan-out (grep every playbook for those skill names). These are vendored poteto-mode playbooks: land it through the patches in patches/ (series + SOURCES.md) as the other poll sentences were, and confirm ./factory918.sh sync leaves git status clean. (Spec report P1, Would break, criterion 4.)

When pushed to origin/feat/speed-lessons, write .scratch/program/105/r3-fixed.md with the line: 1 <sha>
