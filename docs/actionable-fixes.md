# Dakota Actionable Issues

## #606 — Highlight/copy broken in ghostty
Ghostty clipboard/highlight behavior differs from GNOME Terminal. Workaround: use Ctrl+Shift+C/V or configure ghostty clipboard settings.

## #603 — firstboot-services.bst not wired into build
Fixed by adding `firstboot-services.bst` to `elements/bluefin/deps.bst`. This ensures its installed service artifacts land in images during the BST build.

## #536 — ujust report reduce friction
Agent-ready improvement: allow ujust report to pre-fill diagnostic data and reduce OTel collection time for quick submissions.

## #527 — Ghost lab BST gate fails resolving junction
BST gate failure during dispatch: `project.conf` / ref-lock resolution fails when the gnome-build-meta junction ref is stale. Fix: update the junction ref in `project.conf` to a commit that resolves cleanly, then re-dispatch the gate workflow.

## #524 — testlab automation requires manual runner
p0 bug: automate runner bring-up so manual intervention is not needed for each test run.

## #503 — CI: deduplicate bst2 pin check
Agent-ready: deduplicate bst2 pin check and config generation into composite actions. Refactor build.yml.

## #501 — CI: auto-merge junction bumps
Agent-ready: auto-merge junction bumps from mergeraptor. Configure auto-merge for PRs that pass CI.

## #180 — ujust devmode can't find image
p1 bug: devmode recipe should pull the image before switching. Fix: add `bootc switch --pull` or check image exists before attempting switch.
