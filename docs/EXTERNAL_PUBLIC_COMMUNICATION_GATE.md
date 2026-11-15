# External-public communication — explicit owner consent gate

**Owner:** OpenSiro Upstream Contributions S1 under [issue #6](https://github.com/opensiro/upstream/issues/6), respecting the Organization S5 parent. **Effective operator correction:** 2026-11-15, **explicit instruction in the active owner conversation** after an unauthorized technical comment to [Akmatori #48](https://github.com/akmatori/akmatori/issues/48). This is an attributable in-chat decision, **not** a fabricated public GitHub approval or retroactive rewrite of earlier releases.

**Normative rule (prospective protocol v0.10.0):** prepare and test autonomously within existing stage authority, but **do not send anything publicly to a third-party project without first showing the exact action, external destination, and final text/code scope and receiving a new explicit, action-specific confirmation from the owner in the current conversation**. If confirmation is absent, ambiguous, revoked, stale, or covers different text/destination/action, **STOP** the outward write. Prefer a reviewable internal OpenSiro draft/PR and report `AWAITING_OWNER_EXTERNAL_PUBLICATION_APPROVAL`; do not ask permission to continue harmless analysis.

## Actions that are public communication (owner approval required)

- Create, update or publish a **third-party PR**, including draft PR, PR body edits that notify maintainers and a PR-as-CLA-assent flow.
- Create or edit an external issue, **comment or reply** on external issues/PRs, post code/design questions, submit PR reviews, discussions, mention third-party maintainers, change externally visible state or send any third-party outreach.
- Open a **public fork-local PR** used to solicit outside review or stage a public target-facing proposal (public fork-local PR creation is also visible; keep purely local drafts otherwise).
- **Any similar external POST/PATCH/PUT** with public side effects, including via `gh`, GitHub MCP, API, web browser, or another agent. Tool availability never implies consent.

**Outside this additional gate:** read-only source inspections, internal OpenSiro PRs/issues and review under their own permissions, offline tests and local drafts, and already authorized ordinary preparation of code branches in OpenSiro-owned forks **without third-party outreach/notification**. Other legal, fork, license, S5 and destination-native rules still apply. A comment to an OpenSiro-owned issue is *internal*; an unsolicited comment to another organization's issue is *external*, even if it is only a technical question.

## Before any external write

1. Collect the exact destination URL/repository/issue/PR, **specific action** (new issue, comment, edit, PR, review, etc.), **complete proposed public text** or the PR title/body and verified source branch/diff/pin. Disclose AI involvement when required. State that submitting will notify or contact outside maintainers.
2. **Show the proposed content to the owner** in conversation *before* contacting the third party. Ask whether to publish **this exact action**, and wait for an explicit affirmative reply. `continue`, `продолжай`, `upstream auto`, a batch assignment, a historical standing mandate or general encouragement is **not** approval for external communication.
3. Bind the approval to **this one action, target and text/diff**, in the **active conversation**. If text, destination, authorization state, source branch or intended action materially changes, re-present and re-confirm. Never reuse an approval as blanket consent for another comment/issue/PR, separate outreach, or future wave.
4. Re-check source, license, legal CLA/DCO, native tests, actor rights, current contributor policy and destination PR form. The new consent is **necessary, not sufficient**; external maintainer approval/merge is never granted by the owner.
5. Only then execute using the exact host-supported action, read back the actual result and log an attributable receipt. On host restrictions, error, ambiguous permission or unavailable consent provenance, **fail closed** with no external call. An agent-written YAML/JSON "approval" does not independently prove that the human authorized the action.

**Non-bypass invariant:** the 2026-11-11 standing external PR publication mandate remains part of the historical record, but its **no-per-PR-prompt mode is superseded** for prospective third-party public actions by this narrower 2026-11-15 owner instruction. An external request from a maintainer, a first-party issue, a valuable research result, `need/mechanism/counterfactual/scope=PASS`, PR readiness, existing fork, or `publish` action name does not waive this gate.

**OpenSiro-internal implementation is not enforcement over all third-party clients:** these repository rules and offline tests can reject an unsafe protocol path; they **cannot technically intercept arbitrary GitHub/browser tools**. The executing agent and host **must** enforce the approval before tool calls. Do not claim that a lint, static policy or local CLI proves runtime consent.

## Regression fixtures

| Scenario | Required disposition |
| --- | --- |
| `continue` batch 40; Akmatori #48 looks ready for a maintainer design question | **BLOCK public comment**; show proposed exact text and await owner |
| Prior grant to create external PRs; current candidate is otherwise qualified | **BLOCK public PR** until exact current owner approval |
| Owner approved a comment to Akmatori #48; agent wants to open a PR | **BLOCK**; different action |
| Owner approved comment v1; draft text materially changed | **BLOCK** until re-confirmed |
| Background wave, automation or connected account can POST | **BLOCK** external communication; tool capability is not consent |
| Ordinary local tests, source reading or internal OpenSiro PR | **ALLOW under the separate ordinary permission gates** |
| Signed/approved exact comment, exact target and action in current chat | **Eligible for other legal/native/actor gates**, never automatic success |

No new autonomous publication executor, S5 delegation, Index/Skills/Profile change, CLA/DCO acceptance or retroactive rewrite of frozen research is created.
