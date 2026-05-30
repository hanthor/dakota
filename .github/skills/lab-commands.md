# Lab Slash Commands

Lab commands control hardware validation for PRs. Only humans may issue them.

## The one rule agents must never break

> **Agents MUST NOT post `/lab` commands.** Not on behalf of a user. Not autonomously.
> Ever. Only a human with write+ access types a `/lab` command.

A question in a PR comment — "does this work?", "any lab results?" — is never a
command. Questions do not trigger lab actions. If an agent is unsure whether a
human issued a command, it does nothing and waits.

---

## Who can use lab commands

**Maintainers** (`@projectbluefin/maintainers`) and **wranglers** (write+ collaborators).

Anyone else: the command is silently ignored. No error comment, no action.

---

## Slash commands

Commands must appear on their own line, starting with `/lab`. Nothing else on
that line counts as a command.

| Command | Effect | Label applied |
|---------|--------|---------------|
| `/lab run` | Dispatch a new lab workflow for this PR | `lab:pending` → `lab:running` |
| `/lab reset` | Cancel any running workflow, dispatch a fresh run | `lab:pending` |
| `/lab skip <reason>` | Skip lab for this PR; reason required | `lab:skip` |
| `/lab pass` | Manual override: mark this PR lab-passed | `lab:pass` |
| `/lab fail` | Manual override: mark this PR lab-failed | `lab:fail` |

`<reason>` is mandatory for `/lab skip`. A skip without a reason is rejected.

---

## Label states

| Label | Meaning |
|-------|---------|
| `lab:pending` | Run queued, not yet dispatched |
| `lab:running` | Argo workflow in progress |
| `lab:pass` | Lab validated — image booted on hardware |
| `lab:fail` | Lab failed — see `<!-- lab-status -->` sentinel for details |
| `lab:skip` | Skipped with maintainer sign-off |

Labels form a state machine: `pending → running → pass|fail`. Any transition
backwards requires an explicit `/lab reset` or `/lab run`.

---

## Sentinel comment

Every PR that enters the lab pipeline has exactly one `<!-- lab-status -->`
sentinel comment. Agents that update lab state **PATCH that comment in-place**
via `gh api --method PATCH`. They never post a new lab comment. If the sentinel
does not exist, create it once — then only PATCH from that point on.

```bash
# PATCH existing sentinel — never POST a new one
COMMENT_ID=$(gh api repos/projectbluefin/dakota/issues/${PR}/comments \
  | python3 -c "import json,sys; cs=[c for c in json.load(sys.stdin) if '<!-- lab-status -->' in c['body']]; print(cs[0]['id'] if cs else '')")

gh api --method PATCH repos/projectbluefin/dakota/issues/comments/${COMMENT_ID} \
  -f body="⏳ **lab:running** — workflow \`${WORKFLOW_ID}\` dispatched \`$(date -u +%Y-%m-%dT%H:%M:%SZ)\`. <!-- lab-status -->"
```

---

## Examples

```
# Valid — maintainer requesting a run
/lab run

# Valid — cancelling a stale run and restarting
/lab reset

# Valid — skipping a trivial docs change
/lab skip docs-only change, no binary affected

# Invalid — this is a question, not a command
Is the lab run done yet?

# Invalid — agent cannot post this
/lab reset   ← agents are prohibited from posting this
```
