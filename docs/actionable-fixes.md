# Dakota Actionable Issues

## #606 — Highlight/copy broken in ghostty
Ghostty clipboard/highlight behavior differs from GNOME Terminal. Workaround: use Ctrl+Shift+C/V or configure ghostty clipboard settings.

## #603 — firstboot-services.bst orphaned
The firstboot-services.bst file references a non-existent source. Need to either restore the source or remove the orphaned .bst reference.

## #536 — ujust report reduce friction
Agent-ready improvement: allow ujust report to pre-fill diagnostic data and reduce OTel collection time for quick submissions.

## #527 — Ghost lab BST gate fails resolving junction
BST gate failure resolving gnome-build-meta junction. Check junction URL is accessible from CI runner and retry with --pull.

## #524 — testlab automation requires manual runner
p0 bug: automate runner bring-up so manual intervention is not needed for each test run.

## #503 — CI: deduplicate bst2 pin check
Agent-ready: deduplicate bst2 pin check and config generation into composite actions. Refactor build.yml.

## #501 — CI: auto-merge junction bumps
Agent-ready: auto-merge junction bumps from mergeraptor. Configure auto-merge for PRs that pass CI.

## #180 — ujust devmode can't find image
p1 bug: devmode recipe should pull the image before switching. Fix: add `bootc switch --pull` or check image exists before attempting switch.
